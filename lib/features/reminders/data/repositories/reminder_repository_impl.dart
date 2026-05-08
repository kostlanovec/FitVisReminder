import 'package:fit_vis_reminder/features/reminders/data/datasources/reminder_local_datasource.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl(this._datasource);

  final ReminderLocalDatasource _datasource;

  @override
  Stream<List<Reminder>> watchAll() {
    return _datasource.watchAll().map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Stream<List<Reminder>> watchByCategory(ReminderCategory category) {
    return _datasource
        .watchByCategory(category.index)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Stream<List<Reminder>> watchDueSoon({int withinDays = 30}) {
    final before = DateTime.now().add(Duration(days: withinDays));
    return _datasource
        .watchDueBefore(before)
        .map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Stream<List<Reminder>> watchOverdue() {
    return _datasource.watchOverdue().map((models) => models.map((m) => m.toDomain()).toList());
  }

  @override
  Future<Reminder?> findById(int id) async {
    final model = await _datasource.findById(id);
    return model?.toDomain();
  }

  @override
  Future<List<Reminder>> getAll() async {
    final models = await _datasource.getAll();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<List<Reminder>> getActive() async {
    final models = await _datasource.getActive();
    return models.map((m) => m.toDomain()).toList();
  }

  @override
  Future<int> save(Reminder reminder) async {
    final model = ReminderModel.fromDomain(reminder);
    return _datasource.upsert(model);
  }

  @override
  Future<void> saveAll(List<Reminder> reminders) async {
    final models = reminders.map(ReminderModel.fromDomain).toList();
    await _datasource.upsertAll(models);
  }

  @override
  Future<void> delete(int id) => _datasource.delete(id);

  @override
  Future<void> markCompleted(int id, DateTime completedAt) async {
    await _datasource.update(id, (model) {
      model.lastCompletedAt = completedAt;
      model.updatedAt = DateTime.now();
    });
  }

  @override
  Future<void> updateDueDate(int id, DateTime newDueDate) async {
    await _datasource.update(id, (model) {
      model.dueDate = newDueDate;
      model.updatedAt = DateTime.now();
    });
  }
}
