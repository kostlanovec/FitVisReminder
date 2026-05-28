import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Drift table for persisted reminders.
/// Column names intentionally mirror the old Isar field names so any future
/// migration or backup-import logic stays compatible.
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get categoryIndex => integer()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get recurrenceRuleJson => text()();
  TextColumn get triggersJson => text()();
  TextColumn get description => text().nullable()();
  TextColumn get templateId => text().nullable()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get customIconCode => integer().nullable()();
  TextColumn get calendarEventId => text().nullable()();
}

@DriftDatabase(tables: [Reminders])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'life_track');
  }
}
