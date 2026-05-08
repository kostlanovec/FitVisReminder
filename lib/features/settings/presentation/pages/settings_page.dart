import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(l.settingsTitle)),
          SliverList(
            delegate: SliverChildListDelegate([
              // Appearance
              _SettingsSection(
                title: l.settingsTheme,
                children: [
                  _ThemeModeTile(current: themeMode, l: l),
                  _LocaleTile(current: locale, l: l),
                ],
              ),

              // Notifications
              _SettingsSection(
                title: l.settingsNotifications,
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_active_rounded),
                    title: Text(l.settingsNotificationsPermission),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final svc = ref.read(notificationServiceProvider);
                      final allowed = await svc.isAllowed();
                      if (!allowed) {
                        await svc.requestPermission();
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ OK'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.schedule_rounded),
                    title: Text(l.settingsRescheduleAll),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      await ref.read(reminderSchedulerProvider).scheduleAll();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ ${l.settingsRescheduleAll}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_off_outlined, color: AppColors.accentRed),
                    title: Text(l.settingsCancelAll, style: const TextStyle(color: AppColors.accentRed)),
                    onTap: () async {
                      final confirmed = await _confirm(context, l);
                      if (confirmed == true) {
                        await ref.read(notificationServiceProvider).cancelAll();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.settingsCancelAll)),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),

              // About
              _SettingsSection(
                title: l.settingsAbout,
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(l.settingsVersion),
                    trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const ListTile(
                    leading: Icon(Icons.verified_outlined),
                    title: Text('LifeTrack'),
                    subtitle: Text('Life Maintenance System'),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirm(BuildContext context, AppLocalizations l) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsCancelAll),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.buttonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile({required this.current, required this.l});
  final ThemeMode current;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(_iconFor(current)),
      title: Text(l.settingsTheme),
      trailing: DropdownButton<ThemeMode>(
        value: current,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        items: [
          DropdownMenuItem(value: ThemeMode.system, child: Text(l.settingsThemeSystem)),
          DropdownMenuItem(value: ThemeMode.light, child: Text(l.settingsThemeLight)),
          DropdownMenuItem(value: ThemeMode.dark, child: Text(l.settingsThemeDark)),
        ],
        onChanged: (mode) {
          if (mode != null) ref.read(themeModeProvider.notifier).setTheme(mode);
        },
      ),
    );
  }

  IconData _iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.dark => Icons.dark_mode_rounded,
    _ => Icons.brightness_auto_rounded,
  };
}

class _LocaleTile extends ConsumerWidget {
  const _LocaleTile({required this.current, required this.l});
  final Locale current;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.language_rounded),
      title: Text(l.settingsLanguage),
      trailing: DropdownButton<Locale>(
        value: current,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        items: [
          DropdownMenuItem(value: const Locale('cs'), child: Text('🇨🇿  ${l.settingsLanguageCzech}')),
          DropdownMenuItem(value: const Locale('en'), child: Text('🇬🇧  ${l.settingsLanguageEnglish}')),
        ],
        onChanged: (locale) {
          if (locale != null) ref.read(localeProvider.notifier).setLocale(locale);
        },
      ),
    );
  }
}
