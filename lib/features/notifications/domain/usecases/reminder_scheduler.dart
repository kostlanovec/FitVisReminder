import 'package:fit_vis_reminder/features/notifications/data/datasources/notification_service.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/widget_service.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';

/// Central scheduling engine.
///
/// Schedules only the closest upcoming notifications (never hundreds at once)
/// to minimise battery usage and respect OS notification limits.
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

  static const _maxNotificationsToSchedule = 60;

  Future<void> scheduleAll(AppLocalizations l) async {
    await notificationService.cancelAll();
    final reminders = await reminderRepository.getActive();
    await _scheduleReminders(reminders, l);
    await widgetService.syncReminders(reminders);
  }

  Future<void> scheduleForReminder(Reminder reminder, AppLocalizations l) async {
    await notificationService.cancelAllForReminder(reminder.id);
    await _scheduleSingleReminder(reminder, l);
    final reminders = await reminderRepository.getActive();
    await widgetService.syncReminders(reminders);
  }

  Future<void> cancelForReminder(int reminderId) async {
    await notificationService.cancelAllForReminder(reminderId);
  }

  Future<void> onReminderCompleted(Reminder reminder, AppLocalizations l) async {
    await notificationService.cancelAllForReminder(reminder.id);

    if (!reminder.recurrenceRule.isRecurring) return;

    final next = reminder.recurrenceRule.nextOccurrence(reminder.dueDate);
    final updated = reminder.copyWith(dueDate: next, updatedAt: DateTime.now());
    await reminderRepository.updateDueDate(reminder.id, next);
    await _scheduleSingleReminder(updated, l);
  }

  Future<void> _scheduleReminders(List<Reminder> reminders, AppLocalizations l) async {
    final now = DateTime.now();
    final limit = now.add(Duration(days: settings.scheduleHorizonMonths * 30));

    final notificationSlots = <_NotificationSlot>[];

    for (final reminder in reminders) {
      if (!reminder.isActive) continue;

      // Only schedule up to user-defined limit per reminder
      final slots = _buildSlots(reminder, now, limit, l, limitCount: settings.maxTriggersPerReminder);
      notificationSlots.addAll(slots);
    }

    notificationSlots.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    // Even if we have many reminders, we stay within OS limits
    final toSchedule = notificationSlots.take(_maxNotificationsToSchedule).toList();

    for (final slot in toSchedule) {
      final reminder = reminders.firstWhere((r) => r.id == slot.reminderId);
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
  }

  Future<void> _scheduleSingleReminder(Reminder reminder, AppLocalizations l) async {
    final now = DateTime.now();
    final limit = now.add(Duration(days: settings.scheduleHorizonMonths * 30));
    // Only schedule up to user-defined limit
    final slots = _buildSlots(reminder, now, limit, l, limitCount: settings.maxTriggersPerReminder);

    for (final slot in slots) {
      await notificationService.schedule(
        id: slot.notificationId,
        title: slot.title,
        body: slot.body,
        scheduledAt: slot.scheduledAt,
        priority: reminder.priority,
        payload: {'reminderId': reminder.id.toString()},
        snoozeLabel: l.notificationActionSnooze,
        doneLabel: reminder.priority == ReminderPriority.high 
          ? l.notificationActionUnderstand 
          : l.notificationActionDone,
      );
    }
  }

  List<_NotificationSlot> _buildSlots(
    Reminder reminder,
    DateTime now,
    DateTime limit,
    AppLocalizations l, {
    int limitCount = 0,
  }) {
    final slots = <_NotificationSlot>[];
    final triggers = List<NotificationTrigger>.from(reminder.triggers);

    if (reminder.priority == ReminderPriority.high) {
      // Add standard high-priority sequence if not already present
      const highPrioOffsets = [30, 14, 7, 3, 2, 1, 0];
      for (final offset in highPrioOffsets) {
        if (!triggers.any((t) => t.offsetDays == offset)) {
          triggers.add(NotificationTrigger(offsetDays: offset, label: '$offset dní předem'));
        }
      }
    }

    if (triggers.isEmpty) {
      triggers.add(const NotificationTrigger.sameDay());
    }

    DateTime eventDate = reminder.dueDate;

    if (reminder.recurrenceRule.isRecurring) {
      while (eventDate.isBefore(now) && eventDate.isBefore(limit)) {
        eventDate = reminder.recurrenceRule.nextOccurrence(eventDate);
      }
    }

    final occurrencesToSchedule = reminder.recurrenceRule.isRecurring ? 2 : 1;
    int occurrencesScheduled = 0;

    while (occurrencesScheduled < occurrencesToSchedule && eventDate.isBefore(limit)) {
      for (int i = 0; i < triggers.length; i++) {
        final trigger = triggers[i];
        final scheduledAt = trigger.scheduledFor(eventDate);

        if (scheduledAt.isAfter(now) && scheduledAt.isBefore(limit)) {
          slots.add(
            _NotificationSlot(
              notificationId: _buildNotificationId(reminder.id, i, occurrencesScheduled),
              reminderId: reminder.id,
              title: _buildTitle(reminder, trigger),
              body: _buildBody(reminder, trigger, eventDate, l),
              scheduledAt: scheduledAt,
            ),
          );
        }
      }

      if (reminder.recurrenceRule.isRecurring) {
        eventDate = reminder.recurrenceRule.nextOccurrence(eventDate);
        occurrencesScheduled++;
      } else {
        break;
      }
      
      if (limitCount > 0 && slots.length >= limitCount) break;
    }

    if (limitCount > 0 && slots.length > limitCount) {
      slots.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return slots.take(limitCount).toList();
    }

    return slots;
  }

  int _buildNotificationId(int reminderId, int triggerIndex, int occurrence) {
    return ((reminderId * 100 + triggerIndex) * 10 + occurrence) % 2147483647;
  }

  String _buildTitle(Reminder reminder, NotificationTrigger trigger) {
    if (trigger.offsetDays == 0) return '${reminder.category.emoji} ${reminder.title}';
    return '${reminder.category.emoji} ${reminder.title} - ${trigger.label}';
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
    return l.notificationBodyRemind(_formatDate(eventDate), reminder.title);
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
