import 'package:isar/isar.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';

abstract interface class ReminderLocalDatasource {
  Stream<List<ReminderModel>> watchAll();
  Stream<List<ReminderModel>> watchByCategory(int categoryIndex);
  Stream<List<ReminderModel>> watchDueBefore(DateTime before);
  Stream<List<ReminderModel>> watchOverdue();
  Future<ReminderModel?> findById(int id);
  Future<List<ReminderModel>> getAll();
  Future<List<ReminderModel>> getActive();
  Future<int> upsert(ReminderModel model);
  Future<void> upsertAll(List<ReminderModel> models);
  Future<void> delete(int id);
  Future<void> update(int id, void Function(ReminderModel model) updater);
}

class IsarReminderDatasource implements ReminderLocalDatasource {
  IsarReminderDatasource(this._isar);

  final Isar _isar;

  @override
  Stream<List<ReminderModel>> watchAll() {
    return _isar.reminderModels
        .filter()
        .isActiveEqualTo(true)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ReminderModel>> watchByCategory(int categoryIndex) {
    return _isar.reminderModels
        .filter()
        .isActiveEqualTo(true)
        .categoryIndexEqualTo(categoryIndex)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ReminderModel>> watchDueBefore(DateTime before) {
    return _isar.reminderModels
        .filter()
        .isActiveEqualTo(true)
        .dueDateLessThan(before)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ReminderModel>> watchOverdue() {
    return _isar.reminderModels
        .filter()
        .isActiveEqualTo(true)
        .dueDateLessThan(DateTime.now())
        .watch(fireImmediately: true);
  }

  @override
  Future<ReminderModel?> findById(int id) async {
    return _isar.reminderModels.get(id);
  }

  @override
  Future<List<ReminderModel>> getAll() async {
    return _isar.reminderModels.where().findAll();
  }

  @override
  Future<List<ReminderModel>> getActive() async {
    return _isar.reminderModels
        .filter()
        .isActiveEqualTo(true)
        .sortByDueDate()
        .findAll();
  }

  @override
  Future<int> upsert(ReminderModel model) async {
    return _isar.writeTxn(() => _isar.reminderModels.put(model));
  }

  @override
  Future<void> upsertAll(List<ReminderModel> models) async {
    await _isar.writeTxn(() => _isar.reminderModels.putAll(models));
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.reminderModels.delete(id));
  }

  @override
  Future<void> update(int id, void Function(ReminderModel model) updater) async {
    await _isar.writeTxn(() async {
      final model = await _isar.reminderModels.get(id);
      if (model != null) {
        updater(model);
        await _isar.reminderModels.put(model);
      }
    });
  }
}
