import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fit_vis_reminder/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:fit_vis_reminder/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/pages/reminder_detail_page.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/pages/reminder_form_page.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/pages/reminders_list_page.dart';
import 'package:fit_vis_reminder/features/templates/presentation/pages/templates_page.dart';
import 'package:fit_vis_reminder/features/templates/domain/entities/reminder_template.dart';
import 'package:fit_vis_reminder/features/settings/presentation/pages/settings_page.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/features/reminders/presentation/pages/selective_import_page.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const dashboard = '/';
  static const remindersList = '/reminders';
  static const reminderDetail = '/reminders/:id';
  static const reminderAdd = '/reminders/add';
  static const reminderEdit = '/reminders/:id/edit';
  static const templates = '/templates';
  static const settings = '/settings';
  static const selectiveImport = '/import';

  static String reminderDetailPath(int id) => '/reminders/$id';
  static String reminderEditPath(int id) => '/reminders/$id/edit';
}

final routerProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    initialLocation:
        onboardingCompleted ? AppRoutes.dashboard : AppRoutes.onboarding,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) =>
            _fadeTransition(state, const OnboardingPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) =>
                _fadeTransition(state, const DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.remindersList,
            pageBuilder: (context, state) =>
                _fadeTransition(state, const RemindersListPage()),
          ),
          GoRoute(
            path: AppRoutes.templates,
            pageBuilder: (context, state) =>
                _fadeTransition(state, const TemplatesPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                _fadeTransition(state, const SettingsPage()),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.reminderAdd,
        pageBuilder: (context, state) {
          final tpl = state.extra as ReminderTemplate?;
          return _slideTransition(state, ReminderFormPage(initialTemplate: tpl));
        },
      ),
      GoRoute(
        path: AppRoutes.reminderDetail,
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _slideTransition(state, ReminderDetailPage(reminderId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.reminderEdit,
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _slideTransition(state, ReminderFormPage(reminderId: id));
        },
      ),
      GoRoute(
        path: AppRoutes.selectiveImport,
        pageBuilder: (context, state) {
          final reminders = state.extra as List<Reminder>;
          return _slideTransition(state, SelectiveImportPage(reminders: reminders));
        },
      ),
    ],
  );
});

CustomTransitionPage<T> _fadeTransition<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<T> _slideTransition<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      );
    },
  );
}

class _MainShell extends ConsumerWidget {
  const _MainShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final l = AppLocalizations.of(context)!;

    int selectedIndex = 0;
    if (location.startsWith(AppRoutes.remindersList)) selectedIndex = 1;
    if (location.startsWith(AppRoutes.templates)) selectedIndex = 2;
    if (location.startsWith(AppRoutes.settings)) selectedIndex = 3;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go(AppRoutes.dashboard);
            case 1:
              context.go(AppRoutes.remindersList);
            case 2:
              context.go(AppRoutes.templates);
            case 3:
              context.go(AppRoutes.settings);
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.checklist_outlined),
            selectedIcon: const Icon(Icons.checklist_rounded),
            label: l.navReminders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view_rounded),
            label: l.navTemplates,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}
