import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_vis_reminder/core/database/app_database.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/notification_service.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/widget_service.dart';
import 'package:fit_vis_reminder/features/notifications/domain/usecases/reminder_scheduler.dart';
import 'package:fit_vis_reminder/features/reminders/data/datasources/reminder_local_datasource.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:fit_vis_reminder/features/reminders/data/repositories/mock_reminder_repository.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fit_vis_reminder/features/settings/data/services/backup_service.dart';
import 'package:fit_vis_reminder/features/templates/data/datasources/template_datasource.dart';

// ── Infrastructure ─────────────────────────────────────────────────────────

/// Overridden in main() with the actual [AppDatabase] instance on non-web.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
      'Override databaseProvider with an AppDatabase instance');
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'Override sharedPreferencesProvider with SharedPreferences instance');
});

// ── Notification ───────────────────────────────────────────────────────────

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return kIsWeb ? WebNotificationService() : AwesomeNotificationService();
});

// ── Datasources ────────────────────────────────────────────────────────────

final reminderDatasourceProvider = Provider<ReminderLocalDatasource>((ref) {
  final db = ref.watch(databaseProvider);
  return DriftReminderDatasource(db);
});

final templateDatasourceProvider = Provider<TemplateDatasource>((ref) {
  final locale = ref.watch(localeProvider);
  return HardcodedTemplateDatasource(locale: locale.languageCode);
});

// ── Repositories ───────────────────────────────────────────────────────────

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  if (kIsWeb) {
    return MockReminderRepository();
  } else {
    final datasource = ref.watch(reminderDatasourceProvider);
    return ReminderRepositoryImpl(datasource);
  }
});

final backupServiceProvider = Provider<BackupService>((ref) {
  final repo = ref.watch(reminderRepositoryProvider);
  return BackupService(repo);
});

// ── Scheduling ─────────────────────────────────────────────────────────────

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return ReminderScheduler(
    notificationService: ref.watch(notificationServiceProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
    settings: ref.watch(notificationSettingsProvider),
    widgetService: ref.watch(widgetServiceProvider),
  );
});
