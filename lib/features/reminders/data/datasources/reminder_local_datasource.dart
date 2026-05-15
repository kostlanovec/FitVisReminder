import 'package:isar/isar.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';

abstract interface class ReminderLocalDatasource {
  Stream<List<ReminderData>> watchAll();
  Stream<List<ReminderData>> watchByCategory(int categoryIndex);
  Stream<List<ReminderData>> watchDueBefore(DateTime before);
  Stream<List<ReminderData>> watchOverdue();
  Future<ReminderData?> findById(int id);
  Future<List<ReminderData>> getAll();
  Future<List<ReminderData>> getActive();
  Future<int> upsert(ReminderData model);
  Future<void> upsertAll(List<ReminderData> models);
  Future<void> delete(int id);
  Future<void> clearAll();
  Future<void> update(int id, void Function(ReminderData model) updater);
}

class IsarReminderDatasource implements ReminderLocalDatasource {
  IsarReminderDatasource(this._isar);

  final Isar _isar;

  @override
  Stream<List<ReminderData>> watchAll() {
    return _isar.reminderDatas
        .filter()
        .isActiveEqualTo(true)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ReminderData>> watchByCategory(int categoryIndex) {
    return _isar.reminderDatas
        .filter()
        .isActiveEqualTo(true)
        .categoryIndexEqualTo(categoryIndex)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ReminderData>> watchDueBefore(DateTime before) {
    return _isar.reminderDatas
        .filter()
        .isActiveEqualTo(true)
        .dueDateLessThan(before)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<ReminderData>> watchOverdue() {
    return _isar.reminderDatas
        .filter()
        .isActiveEqualTo(true)
        .dueDateLessThan(DateTime.now())
        .watch(fireImmediately: true);
  }

  @override
  Future<ReminderData?> findById(int id) async {
    return _isar.reminderDatas.get(id);
  }

  @override
  Future<List<ReminderData>> getAll() async {
    return _isar.reminderDatas.where().findAll();
  }

  @override
  Future<List<ReminderData>> getActive() async {
    return _isar.reminderDatas
        .filter()
        .isActiveEqualTo(true)
        .sortByDueDate()
        .findAll();
  }

  @override
  Future<int> upsert(ReminderData model) async {
    return _isar.writeTxn(() => _isar.reminderDatas.put(model));
  }

  @override
  Future<void> upsertAll(List<ReminderData> models) async {
    await _isar.writeTxn(() => _isar.reminderDatas.putAll(models));
  }

  @override
  Future<void> delete(int id) async {
    await _isar.writeTxn(() => _isar.reminderDatas.delete(id));
  }

  @override
  Future<void> clearAll() async {
    await _isar.writeTxn(() => _isar.reminderDatas.clear());
  }

  @override
  Future<void> update(int id, void Function(ReminderData model) updater) async {
    await _isar.writeTxn(() async {
      final model = await _isar.reminderDatas.get(id);
      if (model != null) {
        updater(model);
        await _isar.reminderDatas.put(model);
      }
    });
  }
}
