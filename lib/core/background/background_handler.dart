import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:fit_vis_reminder/core/constants/app_constants.dart';
import 'package:fit_vis_reminder/core/di/database_provider.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/notification_service.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/widget_service.dart';
import 'package:fit_vis_reminder/features/notifications/domain/usecases/reminder_scheduler.dart';
import 'package:fit_vis_reminder/features/reminders/data/datasources/reminder_local_datasource.dart';
import 'package:fit_vis_reminder/features/reminders/data/repositories/reminder_repository_impl.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

/// Fully self-contained background reschedule.
///
/// Called from the awesome_notifications static callbacks when a notification
/// fires and there are no more pending alarms — meaning the current "batch"
/// is done and we need to find the next nearest batch.
///
/// Works even when the app is completely killed because it bootstraps its own
/// Drift + SharedPreferences without relying on Riverpod or Flutter's widget
/// tree.
@pragma('vm:entry-point')
Future<void> rescheduleNextBatch() async {
  if (kIsWeb) return;

  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Future.wait([
      initializeDateFormatting('cs', null),
      initializeDateFormatting('en', null),
    ]);

    final prefs = await SharedPreferences.getInstance();
    final db = openDatabase();

    final localeCode = prefs.getString(AppConstants.localeKey) ?? 'cs';
    final l = await AppLocalizations.delegate
        .load(Locale(localeCode));

    // Parse notification hours (new key) with fallback to legacy single-hour key
    final hoursRaw = prefs.getString('notif_hours');
    List<int> notifHours;
    if (hoursRaw != null && hoursRaw.isNotEmpty) {
      notifHours = hoursRaw
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .where((h) => h >= 0 && h <= 23)
          .toList();
      notifHours.sort();
    } else {
      notifHours = [prefs.getInt('notif_preferred_hour') ?? 9];
    }
    if (notifHours.isEmpty) notifHours = [9];

    final settings = NotificationSettings(
      calendarSyncEnabled:
          prefs.getBool('notif_calendar_sync') ?? false,
      notificationHours: notifHours,
    );

    final notifService = AwesomeNotificationService();

    // Channels must exist before any cancel/create call.
    // This is especially important when running from BootReceiver or the
    // notification display callback, where the plugin starts cold.
    await notifService.initialize();

    final scheduler = ReminderScheduler(
      notificationService: notifService,
      reminderRepository:
          ReminderRepositoryImpl(DriftReminderDatasource(db)),
      settings: settings,
      widgetService: WidgetService(),
    );

    await scheduler.scheduleAll(l);
  } catch (e) {
    // Silent — never crash the background process
    debugPrint('[BackgroundHandler] reschedule failed: $e');
  }
}

/// Workmanager background entry point.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'checkScheduledNotificationsTask') {
      try {
        final notifService = AwesomeNotificationService();
        await notifService.initialize();
        final pending = await notifService.listScheduled();
        if (pending.isEmpty) {
          await rescheduleNextBatch();
        }
      } catch (e) {
        debugPrint('[BackgroundHandler] Workmanager task failed: $e');
      }
    }
    return Future.value(true);
  });
}

/// Initialize Workmanager and schedule periodic health checks.
Future<void> initializeBackgroundWorkmanager() async {
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );
  await Workmanager().registerPeriodicTask(
    'check_scheduled_notifications_periodic',
    'checkScheduledNotificationsTask',
    frequency: const Duration(hours: 24),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

