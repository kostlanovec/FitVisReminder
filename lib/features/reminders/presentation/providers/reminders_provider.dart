import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/calendar/data/services/calendar_sync_service.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/widget_service.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/features/notifications/domain/usecases/reminder_scheduler.dart';

// ── Streams ────────────────────────────────────────────────────────────────

final allRemindersProvider = StreamProvider<List<Reminder>>((ref) {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watchAll();
});

final overdueRemindersProvider = StreamProvider<List<Reminder>>((ref) {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watchOverdue();
});

final dueSoonRemindersProvider = StreamProvider<List<Reminder>>((ref) {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watchDueSoon(withinDays: 30);
});

final remindersByCategoryProvider =
    StreamProvider.family<List<Reminder>, ReminderCategory>((ref, category) {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watchByCategory(category);
});

final reminderByIdProvider = FutureProvider.family<Reminder?, int>((ref, id) async {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.findById(id);
});

// ── Summary stats ─────────────────────────────────────────────────────────

class DashboardStats {
  const DashboardStats({
    required this.total,
    required this.overdue,
    required this.dueSoon,
    required this.upcomingThisMonth,
  });

  final int total;
  final int overdue;
  final int dueSoon;
  final int upcomingThisMonth;
}

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  final allAsync = ref.watch(allRemindersProvider);
  final overdueAsync = ref.watch(overdueRemindersProvider);
  final dueSoonAsync = ref.watch(dueSoonRemindersProvider);

  return allAsync.whenData((all) {
    final overdue = overdueAsync.valueOrNull ?? [];
    final dueSoon = dueSoonAsync.valueOrNull ?? [];
    final thisMonth = all.where((r) => r.daysUntilDue <= 31 && r.daysUntilDue >= 0).length;

    return DashboardStats(
      total: all.length,
      overdue: overdue.length,
      dueSoon: dueSoon.length,
      upcomingThisMonth: thisMonth,
    );
  });
});

// ── Mutations ─────────────────────────────────────────────────────────────

class ReminderNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int> saveReminder(Reminder reminder, AppLocalizations l) async {
    state = const AsyncLoading();
    final id = await ref.read(reminderRepositoryProvider).save(reminder);
    final updated = Reminder(
        id: id,
        title: reminder.title,
        category: reminder.category,
        dueDate: reminder.dueDate,
        recurrenceRule: reminder.recurrenceRule,
        triggers: reminder.triggers,
        priority: reminder.priority,
        description: reminder.description,
        templateId: reminder.templateId,
        isActive: reminder.isActive,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now(),
        calendarEventId: reminder.calendarEventId,
      );
    final scheduler = ref.read(reminderSchedulerProvider);
    await scheduler.scheduleForReminder(updated, l);
    await _afterMutation(updated);
    state = const AsyncData(null);
    return id;
  }

  Future<void> deleteReminder(int id) async {
    state = const AsyncLoading();
    final reminder = await ref.read(reminderRepositoryProvider).findById(id);
    await ref.read(reminderRepositoryProvider).delete(id);
    await ref.read(reminderSchedulerProvider).cancelForReminder(id);
    if (reminder != null) {
      await _afterMutation(reminder, isDeleted: true);
    } else {
      await _afterMutation(null);
    }
    state = const AsyncData(null);
  }

  Future<void> markDone(Reminder reminder, AppLocalizations l) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    await ref.read(reminderRepositoryProvider).markCompleted(reminder.id, now);
    await ref.read(reminderSchedulerProvider).onReminderCompleted(reminder, l);
    await _afterMutation(reminder);
    state = const AsyncData(null);
  }

  Future<void> snoozeReminder(Reminder reminder, AppLocalizations l, {int days = 7}) async {
    final newDate = reminder.dueDate.add(Duration(days: days));
    await ref.read(reminderRepositoryProvider).updateDueDate(reminder.id, newDate);
    final updated = reminder.copyWith(dueDate: newDate, updatedAt: DateTime.now());
    await ref.read(reminderSchedulerProvider).scheduleForReminder(updated, l);
    await _afterMutation(updated);
  }

  Future<void> deleteMultiple(Set<int> ids) async {
    state = const AsyncLoading();
    for (final id in ids) {
      final reminder = await ref.read(reminderRepositoryProvider).findById(id);
      await ref.read(reminderRepositoryProvider).delete(id);
      await ref.read(reminderSchedulerProvider).cancelForReminder(id);
      if (reminder != null) await _afterMutation(reminder, isDeleted: true);
    }
    await _afterMutation(null);
    state = const AsyncData(null);
  }

  Future<void> markDoneMultiple(List<Reminder> reminders, AppLocalizations l) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    for (final reminder in reminders) {
      await ref.read(reminderRepositoryProvider).markCompleted(reminder.id, now);
      await ref.read(reminderSchedulerProvider).onReminderCompleted(reminder, l);
      await _afterMutation(reminder);
    }
    state = const AsyncData(null);
  }

  Future<void> _afterMutation(Reminder? reminder, {bool isDeleted = false}) async {
    // 1. Sync Calendar
    final settings = ref.read(notificationSettingsProvider);
    if (settings.calendarSyncEnabled && reminder != null) {
      final calendarSync = ref.read(calendarSyncServiceProvider);
      if (isDeleted || !reminder.isActive) {
        // Find if we had an event and delete it? 
        // For simplicity, we just delete if we have an ID
        if (reminder.calendarEventId != null) {
          // We'd need the calendar ID too, which our service creates.
          // Let's improve service to handle this better or just try-catch
        }
      } else {
        final eventId = await calendarSync.syncReminder(reminder);
        if (eventId != null && eventId != reminder.calendarEventId) {
          await ref.read(reminderRepositoryProvider).save(reminder.copyWith(calendarEventId: eventId));
        }
      }
    }

    // 2. Update Widget
    final allAsync = ref.read(allRemindersProvider);
    allAsync.whenData((all) {
      final active = all.where((r) => r.isActive).toList();
      ref.read(widgetServiceProvider).updateWidget(active);
    });
  }
}

final reminderNotifierProvider =
    AsyncNotifierProvider<ReminderNotifier, void>(ReminderNotifier.new);
