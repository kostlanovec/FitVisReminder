import 'package:fit_vis_reminder/core/constants/app_constants.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/notification_service.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';

/// Central scheduling engine.
///
/// Schedules only the closest upcoming notifications (never hundreds at once)
/// to minimise battery usage and respect OS notification limits.
class ReminderScheduler {
  ReminderScheduler({
    required this.notificationService,
    required this.reminderRepository,
  });

  final NotificationService notificationService;
  final ReminderRepository reminderRepository;

  static const _maxNotificationsToSchedule = 60;

  // ── Public API ────────────────────────────────────────────────────────

  Future<void> scheduleAll() async {
    final reminders = await reminderRepository.getActive();
    await _scheduleReminders(reminders);
  }

  Future<void> scheduleForReminder(Reminder reminder) async {
    await notificationService.cancelAllForReminder(reminder.id);
    await _scheduleSingleReminder(reminder);
  }

  Future<void> cancelForReminder(int reminderId) async {
    await notificationService.cancelAllForReminder(reminderId);
  }

  Future<void> onReminderCompleted(Reminder reminder) async {
    await notificationService.cancelAllForReminder(reminder.id);

    if (!reminder.recurrenceRule.isRecurring) return;

    final next = reminder.recurrenceRule.nextOccurrence(reminder.dueDate);
    final updated = reminder.copyWith(dueDate: next, updatedAt: DateTime.now());
    await reminderRepository.updateDueDate(reminder.id, next);
    await _scheduleSingleReminder(updated);
  }

  // ── Internal ──────────────────────────────────────────────────────────

  Future<void> _scheduleReminders(List<Reminder> reminders) async {
    final now = DateTime.now();
    final limit = now.add(AppConstants.maxAdvanceSchedule);

    final notificationSlots = <_NotificationSlot>[];

    for (final reminder in reminders) {
      if (!reminder.isActive) continue;

      final slots = _buildSlots(reminder, now, limit);
      notificationSlots.addAll(slots);
    }

    // Sort by date, take closest ones to not exceed OS limit
    notificationSlots.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final toSchedule = notificationSlots.take(_maxNotificationsToSchedule).toList();

    for (final slot in toSchedule) {
      await notificationService.schedule(
        id: slot.notificationId,
        title: slot.title,
        body: slot.body,
        scheduledAt: slot.scheduledAt,
        payload: {'reminderId': slot.reminderId.toString()},
      );
    }
  }

  Future<void> _scheduleSingleReminder(Reminder reminder) async {
    final now = DateTime.now();
    final limit = now.add(AppConstants.maxAdvanceSchedule);
    final slots = _buildSlots(reminder, now, limit);

    for (final slot in slots) {
      await notificationService.schedule(
        id: slot.notificationId,
        title: slot.title,
        body: slot.body,
        scheduledAt: slot.scheduledAt,
        payload: {'reminderId': reminder.id.toString()},
      );
    }
  }

  List<_NotificationSlot> _buildSlots(
    Reminder reminder,
    DateTime now,
    DateTime limit,
  ) {
    final slots = <_NotificationSlot>[];
    final triggers = reminder.triggers;

    if (triggers.isEmpty) {
      triggers.add(const NotificationTrigger.sameDay());
    }

    DateTime eventDate = reminder.dueDate;

    // For recurring reminders, advance past-due dates to the next occurrence
    if (reminder.recurrenceRule.isRecurring) {
      while (eventDate.isBefore(now) && eventDate.isBefore(limit)) {
        eventDate = reminder.recurrenceRule.nextOccurrence(eventDate);
      }
    }

    // Schedule next 2 occurrences for recurring reminders
    final occurrencesToSchedule = reminder.recurrenceRule.isRecurring ? 2 : 1;
    int occurrencesScheduled = 0;

    while (occurrencesScheduled < occurrencesToSchedule && eventDate.isBefore(limit)) {
      for (int i = 0; i < triggers.length; i++) {
        final trigger = triggers[i];
        final scheduledAt = trigger.scheduledFor(eventDate);

        if (scheduledAt.isAfter(now) && scheduledAt.isBefore(limit)) {
          slots.add(_NotificationSlot(
            notificationId: _buildNotificationId(reminder.id, i, occurrencesScheduled),
            reminderId: reminder.id,
            title: _buildTitle(reminder, trigger),
            body: _buildBody(reminder, trigger, eventDate),
            scheduledAt: scheduledAt,
          ));
        }
      }

      if (reminder.recurrenceRule.isRecurring) {
        eventDate = reminder.recurrenceRule.nextOccurrence(eventDate);
        occurrencesScheduled++;
      } else {
        break;
      }
    }

    return slots;
  }

  int _buildNotificationId(int reminderId, int triggerIndex, int occurrence) {
    // Deterministic, collision-resistant ID
    return ((reminderId * 100 + triggerIndex) * 10 + occurrence) % 2147483647;
  }

  String _buildTitle(Reminder reminder, NotificationTrigger trigger) {
    if (trigger.offsetDays == 0) return '${reminder.category.emoji} ${reminder.title}';
    return '${reminder.category.emoji} ${reminder.title} – ${trigger.label}';
  }

  String _buildBody(
    Reminder reminder,
    NotificationTrigger trigger,
    DateTime eventDate,
  ) {
    final days = trigger.offsetDays;
    if (days == 0) return 'Dnes nastává termín: ${reminder.title}';
    if (days == 1) return 'Zítra nastává termín: ${reminder.title}';
    if (days <= 7) return 'Za $days dní nastává termín: ${reminder.title}';
    if (days <= 31) return 'Za $days dní: ${reminder.title}';
    return 'Připomenutí: ${reminder.title} – ${_formatDate(eventDate)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
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
