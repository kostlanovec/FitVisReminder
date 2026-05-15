import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_vis_reminder/core/di/database_provider.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/notification_service.dart';
import 'package:fit_vis_reminder/features/settings/presentation/widgets/app_lock_gate.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:fit_vis_reminder/features/notifications/domain/usecases/reminder_scheduler.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/widget_service.dart';
import 'package:fit_vis_reminder/features/calendar/data/services/calendar_sync_service.dart';
import 'package:fit_vis_reminder/features/reminders/data/services/sharing_service.dart';
import 'package:app_links/app_links.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      debugPrint('Orientation lock not supported: $e');
    }
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Future.wait([
    initializeDateFormatting('cs', null),
    initializeDateFormatting('en', null),
  ]);

  final results = await Future.wait([
    if (!kIsWeb) openIsar() else Future.value(null),
    SharedPreferences.getInstance(),
  ]);

  final isar = results[0] as Isar?;
  final prefs = results[1] as SharedPreferences;

  final container = ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Load localizations
  final locale = container.read(localeProvider);
  final l = await AppLocalizations.delegate.load(locale);

  if (kIsWeb) {
    notificationService = WebNotificationService();
  } else {
    notificationService = AwesomeNotificationService();
  }

  await notificationService.initialize(
    channelNames: {
      'reminders': l.notificationChannelReminders,
      'important': l.notificationChannelImportant,
      'upcoming': l.notificationChannelUpcoming,
    },
    channelDescriptions: {
      'reminders': l.notificationChannelRemindersDesc,
      'important': l.notificationChannelImportantDesc,
      'upcoming': l.notificationChannelUpcomingDesc,
    },
  );

  if (!kIsWeb) {
    final isAllowed = await notificationService.isAllowed();
    if (!isAllowed) {
      await notificationService.requestPermission();
    }
  }

  // Final container with notification service
  final finalContainer = ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
  );

  if (!kIsWeb) {
    // Handle notification action buttons (Snooze / Mark Done) from the static callback
    AwesomeNotificationService.setActionCallback((action, reminderId) async {
      try {
        final repo = finalContainer.read(reminderRepositoryProvider);
        final reminder = await repo.findById(reminderId);
        if (reminder == null) return;

        final scheduler = finalContainer.read(reminderSchedulerProvider);
        final locale = finalContainer.read(localeProvider);
        final l = await AppLocalizations.delegate.load(locale);

        if (action == 'SNOOZE') {
          final days = reminder.priority == ReminderPriority.high ? 1 : 7;
          final newDate = reminder.dueDate.add(Duration(days: days));
          await repo.updateDueDate(reminderId, newDate);
          await scheduler.scheduleForReminder(reminder.copyWith(dueDate: newDate), l);
        } else if (action == 'MARK_DONE') {
          if (reminder.priority == ReminderPriority.high) {
            await scheduler.cancelForReminder(reminderId);
          } else {
            await repo.markCompleted(reminderId, DateTime.now());
            await scheduler.onReminderCompleted(reminder, l);
          }
        }
        } catch (_) {}

        // After mutation, update widget and calendar
        try {
          final repo = finalContainer.read(reminderRepositoryProvider);
          final active = await repo.getAllActive();
          final widgetService = finalContainer.read(widgetServiceProvider);
          await widgetService.updateWidget(active);

          final notifSettings = finalContainer.read(notificationSettingsProvider);
          if (notifSettings.calendarSyncEnabled) {
            final reminder = await repo.findById(reminderId);
            if (reminder != null && reminder.isActive) {
               final calendarSync = finalContainer.read(calendarSyncServiceProvider);
               final eventId = await calendarSync.syncReminder(reminder);
               if (eventId != null && eventId != reminder.calendarEventId) {
                 await repo.save(reminder.copyWith(calendarEventId: eventId));
               }
            }
          }
        } catch (_) {}
      });
    }

    try {
      final scheduler = finalContainer.read(reminderSchedulerProvider);
      await scheduler.scheduleAll(l);
      
      final repo = finalContainer.read(reminderRepositoryProvider);
      final active = await repo.getAllActive();
      await finalContainer.read(widgetServiceProvider).updateWidget(active);
    } catch (_) {}
  }

    runApp(
    UncontrolledProviderScope(
      container: finalContainer,
      child: const FitVisApp(),
    ),
  );

  // Handle incoming file links
  if (!kIsWeb) {
    final appLinks = AppLinks();
    final sharingService = SharingService();
    
    appLinks.allUriLinkStream.listen((uri) async {
      try {
        final path = uri.toFilePath();
        if (path.endsWith('.fvr') || path.endsWith('.json')) {
          final file = File(path);
          final content = await file.readAsString();
          final reminders = sharingService.parseSharedFile(content);
          
          if (reminders.isNotEmpty) {
            finalContainer.read(routerProvider).push(AppRoutes.selectiveImport, extra: reminders);
          }
        }
      } catch (e) {
        debugPrint('Error handling incoming link: $e');
      }
    });

    // Handle initial link
    try {
      final uri = await appLinks.getInitialLink();
      if (uri != null) {
        final path = uri.toFilePath();
        if (path.endsWith('.fvr') || path.endsWith('.json')) {
          final file = File(path);
          final content = await file.readAsString();
          final reminders = sharingService.parseSharedFile(content);
          if (reminders.isNotEmpty) {
             // Delay slightly to ensure router is ready
             Future.delayed(const Duration(milliseconds: 500), () {
               finalContainer.read(routerProvider).push(AppRoutes.selectiveImport, extra: reminders);
             });
          }
        }
      }
    } catch (_) {}
  }
}

class FitVisApp extends ConsumerWidget {
  const FitVisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'LifeTrack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) {
            return AppLockGate(
              child: child!,
            );
          },
        );
      },
    );
  }
}
