import 'package:fit_vis_reminder/features/notifications/data/datasources/notification_service.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/widget_service.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';

/// Chain-scheduling engine.
///
/// Principle (as described by the user):
///   1. Find the single nearest notification date across ALL active reminders.
///   2. Schedule ALL notifications that fall on that same day (STK + card + …).
///   3. When the app is next opened (or a reminder is acted on), call
///      scheduleNextBatch() again — it cancels whatever was there and
///      re-evaluates what the new "nearest day" is.
///
/// This keeps AlarmManager lean: at most one day's worth of alarms at a time
/// (typically 2–5 entries) instead of dozens pre-filled months in advance.
class ReminderScheduler {
  ReminderScheduler({
    required this.notificationService,
    required this.reminderRepository,
    required this.settings,
    required this.widgetService,
  });

  final NotificationService notificationService;
  final ReminderRepository reminderRepository;
  final NotificationSettings settings;
  final WidgetService widgetService;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Cancel everything and schedule the next day's batch.
  /// Called on app open (when 0 alarms found) or manual "reschedule all".
  /// Returns the number of notifications that were scheduled.
  Future<int> scheduleAll(AppLocalizations l) async {
    await notificationService.cancelAll();
    final reminders = await reminderRepository.getActive();
    final count = await _scheduleNextBatch(reminders, l);
    await widgetService.syncReminders(reminders);
    return count;
  }

  /// Re-evaluate after a single reminder is created/edited/snoozed.
  /// Cancels that reminder's pending alarms, then rebuilds the full batch
  /// (because the nearest date might have changed).
  Future<void> scheduleForReminder(Reminder reminder, AppLocalizations l) async {
    await notificationService.cancelAllForReminder(reminder.id);
    final reminders = await reminderRepository.getActive();
    await _scheduleNextBatch(reminders, l);
    await widgetService.syncReminders(reminders);
  }



  /// Cancel all notifications for a deleted reminder.
  /// The next app open will call scheduleAll() and rebuild the batch.
  Future<void> cancelForReminder(int reminderId) async {
    await notificationService.cancelAllForReminder(reminderId);
  }

  /// Mark done: advance the reminder to next occurrence, rebuild batch.
  Future<void> onReminderCompleted(
    Reminder reminder,
    AppLocalizations l,
  ) async {
    await notificationService.cancelAllForReminder(reminder.id);

    if (reminder.recurrenceRule.isRecurring) {
      final next = reminder.recurrenceRule.nextOccurrence(reminder.dueDate);
      await reminderRepository.updateDueDate(reminder.id, next);
    }

    // Rebuild batch — the completed reminder either rolled forward or is gone
    final reminders = await reminderRepository.getActive();
    await _scheduleNextBatch(reminders, l);
  }



  // ── Core batch builder ─────────────────────────────────────────────────────

  /// Collect the next notification slot for every active reminder,
  /// find the nearest date, then schedule only the slots that share that date.
  /// Returns the number of notifications scheduled.
  Future<int> _scheduleNextBatch(
    List<Reminder> reminders,
    AppLocalizations l,
  ) async {
    final now = DateTime.now();

    // 1. Gather the single next slot for every reminder
    final candidates = <_Candidate>[];
    for (final reminder in reminders) {
      if (!reminder.isActive) continue;
      final slot = _findNextSlot(reminder, now, l);
      if (slot != null) candidates.add(_Candidate(reminder: reminder, slot: slot));
    }

    if (candidates.isEmpty) return 0;

    // 2. Sort by scheduledAt → nearest first
    candidates.sort((a, b) => a.slot.scheduledAt.compareTo(b.slot.scheduledAt));
    final nearestDate = candidates.first.slot.scheduledAt;

    // 3. Collect ALL slots that fall within a 3-day buffer window starting from the nearest date.
    //    This ensures a temporal safety net in case background task execution is delayed or throttled.
    final batchSlots = <_Candidate>[];
    for (final candidate in candidates) {
      if (_inWindow(candidate.slot.scheduledAt, nearestDate, 3)) {
        batchSlots.add(candidate);
      }
    }

    // Also pull in any other triggers for these same reminders
    // that fall within the same 3-day window (e.g. advance notifications + extra hours).
    final batchReminderIds = batchSlots.map((c) => c.reminder.id).toSet();
    for (final reminder in reminders) {
      if (!batchReminderIds.contains(reminder.id)) continue;
      final extras = _allSlotsInWindow(reminder, nearestDate, 3, now, l);
      for (final slot in extras) {
        if (!batchSlots.any((c) =>
            c.slot.notificationId == slot.notificationId)) {
          batchSlots.add(_Candidate(reminder: reminder, slot: slot));
        }
      }
    }

    // 4. Schedule the batch
    for (final c in batchSlots) {
      await _dispatch(c.slot, c.reminder, l);
    }

    return batchSlots.length;
  }

  // ── Slot finders ───────────────────────────────────────────────────────────

  /// Returns the earliest upcoming notification slot for a reminder,
  /// considering every configured notification hour.
  _NotificationSlot? _findNextSlot(
    Reminder reminder,
    DateTime now,
    AppLocalizations l,
  ) {
    final triggers = _buildTriggers(reminder);
    final baseDate = _advancePastNow(reminder, now);
    final hours = _notifHours;

    // Try each trigger × each hour for the current occurrence
    for (int ti = 0; ti < triggers.length; ti++) {
      for (int hi = 0; hi < hours.length; hi++) {
        final at = triggers[ti].scheduledFor(_withHour(baseDate, hours[hi]));
        if (at.isAfter(now)) {
          return _makeSlot(reminder, triggers[ti], ti, _withHour(baseDate, hours[hi]), l, hi);
        }
      }
    }

    // All slots for this occurrence passed — advance to next occurrence
    if (reminder.recurrenceRule.isRecurring) {
      final nextBase = reminder.recurrenceRule.nextOccurrence(baseDate);
      for (int ti = 0; ti < triggers.length; ti++) {
        for (int hi = 0; hi < hours.length; hi++) {
          final at = triggers[ti].scheduledFor(_withHour(nextBase, hours[hi]));
          if (at.isAfter(now)) {
            return _makeSlot(reminder, triggers[ti], ti, _withHour(nextBase, hours[hi]), l, hi);
          }
        }
      }
    }

    return null;
  }

  /// Returns ALL slots for a reminder that land within the specified window,
  /// for every trigger × every configured hour combination.
  List<_NotificationSlot> _allSlotsInWindow(
    Reminder reminder,
    DateTime baseDate,
    int maxDays,
    DateTime now,
    AppLocalizations l,
  ) {
    final triggers = _buildTriggers(reminder);
    final eventBase = _advancePastNow(reminder, now);
    final hours = _notifHours;

    final results = <_NotificationSlot>[];
    for (int ti = 0; ti < triggers.length; ti++) {
      for (int hi = 0; hi < hours.length; hi++) {
        final eventAt = _withHour(eventBase, hours[hi]);
        final at = triggers[ti].scheduledFor(eventAt);
        if (at.isAfter(now) && _inWindow(at, baseDate, maxDays)) {
          results.add(_makeSlot(reminder, triggers[ti], ti, eventAt, l, hi));
        }
      }
    }
    return results;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Sorted list of notification hours from settings (at least [9]).
  List<int> get _notifHours {
    final h = settings.notificationHours;
    return h.isEmpty ? [9] : h;
  }

  /// Advance the reminder's dueDate past "now" for recurring reminders.
  DateTime _advancePastNow(Reminder reminder, DateTime now) {
    DateTime d = reminder.dueDate;
    if (reminder.recurrenceRule.isRecurring) {
      while (d.isBefore(now)) {
        d = reminder.recurrenceRule.nextOccurrence(d);
      }
    }
    return d;
  }

  /// Pin a date to a specific hour (minutes/seconds zeroed).
  DateTime _withHour(DateTime date, int hour) =>
      DateTime(date.year, date.month, date.day, hour, 0);

  bool _inWindow(DateTime date, DateTime baseDate, int maxDays) {
    final baseStart = DateTime(baseDate.year, baseDate.month, baseDate.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final diff = dateDay.difference(baseStart).inDays;
    return diff >= 0 && diff < maxDays;
  }

  List<NotificationTrigger> _buildTriggers(Reminder reminder) {
    final triggers = List<NotificationTrigger>.from(reminder.triggers);
    if (reminder.priority == ReminderPriority.high) {
      const highOffsets = [30, 14, 7, 3, 2, 1, 0];
      for (final offset in highOffsets) {
        if (!triggers.any((t) => t.offsetDays == offset)) {
          triggers.add(NotificationTrigger(
              offsetDays: offset, label: '$offset dní předem'));
        }
      }
    }
    if (triggers.isEmpty) triggers.add(const NotificationTrigger.sameDay());
    return triggers;
  }

  _NotificationSlot _makeSlot(
    Reminder reminder,
    NotificationTrigger trigger,
    int triggerIndex,
    DateTime eventDate,
    AppLocalizations l, [
    int hourIndex = 0,
  ]) {
    // ID formula: unique per (reminder, trigger, hour) triple
    return _NotificationSlot(
      notificationId:
          (reminder.id * 500 + triggerIndex * 10 + hourIndex) % 2147483647,
      reminderId: reminder.id,
      scheduledAt: trigger.scheduledFor(eventDate),
      title: trigger.offsetDays == 0
          ? '${reminder.category.emoji} ${reminder.title}'
          : '${reminder.category.emoji} ${reminder.title} – ${trigger.label}',
      body: _buildBody(reminder, trigger, eventDate, l),
    );
  }

  Future<void> _dispatch(
    _NotificationSlot slot,
    Reminder reminder,
    AppLocalizations l,
  ) async {
    await notificationService.schedule(
      id: slot.notificationId,
      title: slot.title,
      body: slot.body,
      scheduledAt: slot.scheduledAt,
      priority: reminder.priority,
      payload: {'reminderId': slot.reminderId.toString()},
      snoozeLabel: l.notificationActionSnooze,
      doneLabel: reminder.priority == ReminderPriority.high
          ? l.notificationActionUnderstand
          : l.notificationActionDone,
    );
  }

  String _buildBody(
    Reminder reminder,
    NotificationTrigger trigger,
    DateTime eventDate,
    AppLocalizations l,
  ) {
    final days = trigger.offsetDays;
    if (days == 0) return l.notificationBodyToday(reminder.title);
    if (days == 1) return l.notificationBodyTomorrow(reminder.title);
    if (days <= 31) return l.notificationBodyInDays(days, reminder.title);
    return l.notificationBodyRemind(
      '${eventDate.day}.${eventDate.month}.${eventDate.year}',
      reminder.title,
    );
  }

}

class _Candidate {
  const _Candidate({required this.reminder, required this.slot});
  final Reminder reminder;
  final _NotificationSlot slot;
}

class _NotificationSlot {
  const _NotificationSlot({
    required this.notificationId,
    required this.reminderId,
    required this.title,
    required this.body,
    required this.scheduledAt,
  });

  final int notificationId;
  final int reminderId;
  final String title;
  final String body;
  final DateTime scheduledAt;
}
