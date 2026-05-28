import 'package:drift/drift.dart';
import 'package:fit_vis_reminder/core/database/app_database.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';

// ── Interface ──────────────────────────────────────────────────────────────

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

// ── Drift implementation ───────────────────────────────────────────────────

class DriftReminderDatasource implements ReminderLocalDatasource {
  DriftReminderDatasource(this._db);

  final AppDatabase _db;

  // ── Row ↔ model conversion ───────────────────────────────────────────────

  static ReminderData _rowToModel(ReminderRow row) {
    return ReminderData(
      id: row.id,
      title: row.title,
      categoryIndex: row.categoryIndex,
      dueDate: row.dueDate,
      recurrenceRuleJson: row.recurrenceRuleJson,
      triggersJson: row.triggersJson,
      description: row.description,
      templateId: row.templateId,
      isActive: row.isActive,
      lastCompletedAt: row.lastCompletedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      customIconCode: row.customIconCode,
      calendarEventId: row.calendarEventId,
    );
  }

  static RemindersCompanion _modelToCompanion(ReminderData model) {
    return RemindersCompanion(
      // id == 0 → let SQLite auto-assign; otherwise preserve existing id
      id: model.id == 0 ? const Value.absent() : Value(model.id),
      title: Value(model.title),
      categoryIndex: Value(model.categoryIndex),
      dueDate: Value(model.dueDate),
      recurrenceRuleJson: Value(model.recurrenceRuleJson),
      triggersJson: Value(model.triggersJson),
      description: Value(model.description),
      templateId: Value(model.templateId),
      isActive: Value(model.isActive),
      lastCompletedAt: Value(model.lastCompletedAt),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      customIconCode: Value(model.customIconCode),
      calendarEventId: Value(model.calendarEventId),
    );
  }

  // ── Watch (reactive streams) ─────────────────────────────────────────────

  @override
  Stream<List<ReminderData>> watchAll() {
    return (_db.select(_db.reminders)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch()
        .map((rows) => rows.map(_rowToModel).toList());
  }

  @override
  Stream<List<ReminderData>> watchByCategory(int categoryIndex) {
    return (_db.select(_db.reminders)
          ..where((t) =>
              t.isActive.equals(true) &
              t.categoryIndex.equals(categoryIndex))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch()
        .map((rows) => rows.map(_rowToModel).toList());
  }

  @override
  Stream<List<ReminderData>> watchDueBefore(DateTime before) {
    return (_db.select(_db.reminders)
          ..where((t) =>
              t.isActive.equals(true) &
              t.dueDate.isSmallerThanValue(before))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch()
        .map((rows) => rows.map(_rowToModel).toList());
  }

  @override
  Stream<List<ReminderData>> watchOverdue() {
    final now = DateTime.now();
    return (_db.select(_db.reminders)
          ..where((t) =>
              t.isActive.equals(true) & t.dueDate.isSmallerThanValue(now))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .watch()
        .map((rows) => rows.map(_rowToModel).toList());
  }

  // ── One-shot reads ───────────────────────────────────────────────────────

  @override
  Future<ReminderData?> findById(int id) async {
    final row = await (_db.select(_db.reminders)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _rowToModel(row);
  }

  @override
  Future<List<ReminderData>> getAll() async {
    final rows = await _db.select(_db.reminders).get();
    return rows.map(_rowToModel).toList();
  }

  @override
  Future<List<ReminderData>> getActive() async {
    final rows = await (_db.select(_db.reminders)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.dueDate)]))
        .get();
    return rows.map(_rowToModel).toList();
  }

  // ── Writes ───────────────────────────────────────────────────────────────

  @override
  Future<int> upsert(ReminderData model) async {
    return _db
        .into(_db.reminders)
        .insertOnConflictUpdate(_modelToCompanion(model));
  }

  @override
  Future<void> upsertAll(List<ReminderData> models) async {
    await _db.transaction(() async {
      for (final model in models) {
        await _db
            .into(_db.reminders)
            .insertOnConflictUpdate(_modelToCompanion(model));
      }
    });
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.reminders).go();
  }

  @override
  Future<void> update(
    int id,
    void Function(ReminderData model) updater,
  ) async {
    final existing = await findById(id);
    if (existing == null) return;
    updater(existing); // mutate in-place
    await (_db.update(_db.reminders)..where((t) => t.id.equals(id)))
        .write(_modelToCompanion(existing));
  }
}
