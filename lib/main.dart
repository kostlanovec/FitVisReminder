import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_vis_reminder/core/database/app_database.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
import 'package:fit_vis_reminder/features/settings/presentation/widgets/app_lock_gate.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/features/notifications/data/datasources/widget_service.dart'
    show widgetServiceProvider;
import 'package:fit_vis_reminder/core/background/background_handler.dart'
    show initializeBackgroundWorkmanager;
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
    try {
      await initializeBackgroundWorkmanager();
    } catch (e) {
      debugPrint('Workmanager init failed: $e');
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

  // Drift opens the database lazily — no async init needed.
  final AppDatabase? db = kIsWeb ? null : AppDatabase();
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      if (!kIsWeb) databaseProvider.overrideWithValue(db!),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Load localizations
  final locale = container.read(localeProvider);
  final l = await AppLocalizations.delegate.load(locale);

  // Final container with notification service
  final finalContainer = ProviderContainer(
    overrides: [
      if (!kIsWeb) databaseProvider.overrideWithValue(db!),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  if (!kIsWeb) {
    try {
      final notifService = finalContainer.read(notificationServiceProvider);

      // Always initialize channels first — without this no notification
      // can be created regardless of whether permission was granted.
      await notifService.initialize();

      final scheduler = finalContainer.read(reminderSchedulerProvider);

      // Only reschedule if the OS has no pending notifications left
      // (happens after phone restart or first launch).
      final existing = await scheduler.notificationService.listScheduled();
      if (existing.isEmpty) {
        await scheduler.scheduleAll(l);
      }

      final repo = finalContainer.read(reminderRepositoryProvider);
      final active = await repo.getActive();
      await finalContainer.read(widgetServiceProvider).updateWidget(active);
    } catch (_) {}
  }

  runApp(
    UncontrolledProviderScope(
      container: finalContainer,
      child: const FitVisApp(),
    ),
  );
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
