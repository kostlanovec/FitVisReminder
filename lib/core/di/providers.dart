import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/notification_service.dart';
import 'package:fit_vis_reminder/features/notifications/domain/usecases/reminder_scheduler.dart';
import 'package:fit_vis_reminder/features/reminders/data/datasources/reminder_local_datasource.dart';
import 'package:fit_vis_reminder/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fit_vis_reminder/features/templates/data/datasources/template_datasource.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Override isarProvider with the opened Isar instance');
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider with SharedPreferences instance');
});

// ── Notification ───────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return AwesomeNotificationService();
});

// ── Datasources ────────────────────────────────────────────────────────────

final reminderDatasourceProvider = Provider<ReminderLocalDatasource>((ref) {
  final isar = ref.watch(isarProvider);
  return IsarReminderDatasource(isar);
});

final templateDatasourceProvider = Provider<TemplateDatasource>((ref) {
  return HardcodedTemplateDatasource();
});

// ── Repositories ───────────────────────────────────────────────────────────

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final datasource = ref.watch(reminderDatasourceProvider);
  return ReminderRepositoryImpl(datasource);
});

// ── Scheduling ─────────────────────────────────────────────────────────────

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(
    notificationService: ref.watch(notificationServiceProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
  );
});
