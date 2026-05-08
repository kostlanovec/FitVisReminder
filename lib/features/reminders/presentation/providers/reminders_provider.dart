import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';

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

  Future<int> saveReminder(Reminder reminder) async {
    state = const AsyncLoading();
    final id = await ref.read(reminderRepositoryProvider).save(reminder);
    final scheduler = ref.read(reminderSchedulerProvider);
    await scheduler.scheduleForReminder(
      Reminder(
        id: id,
        title: reminder.title,
        category: reminder.category,
        dueDate: reminder.dueDate,
        recurrenceRule: reminder.recurrenceRule,
        triggers: reminder.triggers,
        description: reminder.description,
        templateId: reminder.templateId,
        isActive: reminder.isActive,
        createdAt: reminder.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
    state = const AsyncData(null);
    return id;
  }

  Future<void> deleteReminder(int id) async {
    state = const AsyncLoading();
    await ref.read(reminderRepositoryProvider).delete(id);
    await ref.read(reminderSchedulerProvider).cancelForReminder(id);
    state = const AsyncData(null);
  }

  Future<void> markDone(Reminder reminder) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    await ref.read(reminderRepositoryProvider).markCompleted(reminder.id, now);
    await ref.read(reminderSchedulerProvider).onReminderCompleted(reminder);
    state = const AsyncData(null);
  }

  Future<void> snoozeReminder(Reminder reminder, {int days = 7}) async {
    final newDate = reminder.dueDate.add(Duration(days: days));
    await ref.read(reminderRepositoryProvider).updateDueDate(reminder.id, newDate);
    final updated = reminder.copyWith(dueDate: newDate, updatedAt: DateTime.now());
    await ref.read(reminderSchedulerProvider).scheduleForReminder(updated);
  }

  Future<void> deleteMultiple(Set<int> ids) async {
    state = const AsyncLoading();
    for (final id in ids) {
      await ref.read(reminderRepositoryProvider).delete(id);
      await ref.read(reminderSchedulerProvider).cancelForReminder(id);
    }
    state = const AsyncData(null);
  }

  Future<void> markDoneMultiple(List<Reminder> reminders) async {
    state = const AsyncLoading();
    final now = DateTime.now();
    for (final reminder in reminders) {
      await ref.read(reminderRepositoryProvider).markCompleted(reminder.id, now);
      await ref.read(reminderSchedulerProvider).onReminderCompleted(reminder);
    }
    state = const AsyncData(null);
  }
}

final reminderNotifierProvider =
    AsyncNotifierProvider<ReminderNotifier, void>(ReminderNotifier.new);
