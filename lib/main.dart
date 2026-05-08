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
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Future.wait([
    initializeDateFormatting('cs', null),
    initializeDateFormatting('en', null),
  ]);

  final results = await Future.wait([
    openIsar(),
    SharedPreferences.getInstance(),
  ]);

  final isar = results[0] as Isar;
  final prefs = results[1] as SharedPreferences;

  final notificationService = AwesomeNotificationService();
  await notificationService.initialize();

  final container = ProviderContainer(
    overrides: [
      isarProvider.overrideWithValue(isar),
      sharedPreferencesProvider.overrideWithValue(prefs),
      notificationServiceProvider.overrideWithValue(notificationService),
    ],
  );

  // Handle notification action buttons (Snooze / Mark Done) from the static callback
  AwesomeNotificationService.setActionCallback((action, reminderId) async {
    try {
      final repo = container.read(reminderRepositoryProvider);
      final reminder = await repo.findById(reminderId);
      if (reminder == null) return;

      if (action == 'SNOOZE') {
        final newDate = reminder.dueDate.add(const Duration(days: 7));
        await repo.updateDueDate(reminderId, newDate);
        final scheduler = container.read(reminderSchedulerProvider);
        await scheduler.scheduleForReminder(reminder.copyWith(dueDate: newDate));
      } else if (action == 'MARK_DONE') {
        await repo.markCompleted(reminderId, DateTime.now());
        final scheduler = container.read(reminderSchedulerProvider);
        await scheduler.onReminderCompleted(reminder);
      }
    } catch (_) {}
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LifeTrackApp(),
    ),
  );
}

class LifeTrackApp extends ConsumerWidget {
  const LifeTrackApp({super.key});

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
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            );
          },
        );
      },
    );
  }
}
