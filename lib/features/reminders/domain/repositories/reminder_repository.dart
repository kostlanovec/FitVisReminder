import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';

abstract interface class ReminderRepository {
  Stream<List<Reminder>> watchAll();
  Stream<List<Reminder>> watchByCategory(ReminderCategory category);
  Stream<List<Reminder>> watchDueSoon({int withinDays = 30});
  Stream<List<Reminder>> watchOverdue();

  Future<Reminder?> findById(int id);
  Future<List<Reminder>> getAll();
  Future<List<Reminder>> getActive();

  Future<int> save(Reminder reminder);
  Future<void> saveAll(List<Reminder> reminders);
  Future<void> delete(int id);
  Future<void> markCompleted(int id, DateTime completedAt);
  Future<void> updateDueDate(int id, DateTime newDueDate);
}
