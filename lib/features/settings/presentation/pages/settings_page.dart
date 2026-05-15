import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_vis_reminder/core/constants/app_constants.dart';
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
    final lockSettings = ref.watch(appLockSettingsProvider);
    final l = AppLocalizations.of(context)!;
    final cs = Localizations.localeOf(context).languageCode == 'cs';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(l.settingsTitle),
            floating: true,
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _SettingsSection(
                title: l.settingsTheme,
                children: [
                  _ThemeModeTile(current: themeMode, l: l),
                  _LocaleTile(current: locale, l: l),
                ],
              ).animate().fadeIn(delay: 60.ms).slideY(begin: 0.05),
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
                            content: Text('OK'),
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
                            content: Text(l.settingsRescheduleAll),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notification_important_rounded),
                    title: Text(l.settingsTestNotification),
                    subtitle: Text(l.settingsTestNotificationDesc),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final svc = ref.read(notificationServiceProvider);
                      await svc.showTestNotification(
                        title: "FitVis Reminder 🧪",
                        body: l.settingsTestNotificationSent,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_off_outlined,
                      color: AppColors.accentRed,
                    ),
                    title: Text(
                      l.settingsCancelAll,
                      style: const TextStyle(color: AppColors.accentRed),
                    ),
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
              ).animate().fadeIn(delay: 130.ms).slideY(begin: 0.05),
              _SettingsSection(
                title: l.settingsSectionSecurity,
                children: [
                  SwitchListTile(
                    value: lockSettings.enabled && lockSettings.hasPin,
                    title: Text(l.settingsAppLock),
                    subtitle: Text(
                      lockSettings.enabled && lockSettings.hasPin
                          ? l.settingsAppLockEnabled(lockSettings.timeoutMinutes)
                          : l.settingsAppLockDisabled,
                    ),
                    onChanged: (enabled) async {
                      if (enabled) {
                        await _setupPin(context, ref, l);
                      } else {
                        await ref.read(appLockSettingsProvider.notifier).clearPin();
                        ref.read(appLockSessionProvider.notifier).unlock();
                      }
                    },
                  ),
                  ListTile(
                    enabled: lockSettings.enabled && lockSettings.hasPin,
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(l.settingsAppLockTimeout),
                    subtitle: Text(l.settingsAppLockTimeoutValue(lockSettings.timeoutMinutes)),
                    onTap: () => _setTimeout(context, ref, l, lockSettings.timeoutMinutes),
                  ),
                  ListTile(
                    enabled: lockSettings.enabled && lockSettings.hasPin,
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: Text(l.settingsAppLockNow),
                    onTap: () => ref.read(appLockSessionProvider.notifier).lockNow(),
                  ),
                ],
              ).animate().fadeIn(delay: 170.ms).slideY(begin: 0.05),
              _SettingsSection(
                title: l.settingsSectionBackup,
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_rounded),
                    title: Text(l.settingsBackupCloud),
                    onTap: () async {
                      try {
                        await ref.read(backupServiceProvider).shareBackup(
                          subject: l.backupShareSubject,
                          text: l.backupShareText,
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${l.errorTitle}: $e')),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l.settingsBackupExport),
                    subtitle: Text(l.settingsBackupExportHint),
                    onTap: () => _exportBackup(context, ref, l),
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file_rounded),
                    title: Text(l.settingsBackupImport),
                    subtitle: Text(l.settingsBackupImportHint),
                    onTap: () => _importBackup(context, ref, l),
                  ),
                ],
              ).animate().fadeIn(delay: 185.ms).slideY(begin: 0.05),
              _SettingsSection(
                title: l.settingsSectionPerformance,
                children: [
                  _NotificationHorizonTile(
                    current: ref.watch(notificationSettingsProvider).scheduleHorizonMonths,
                    l: l,
                  ),
                  _NotificationLimitTile(
                    current: ref.watch(notificationSettingsProvider).maxTriggersPerReminder,
                    l: l,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                    title: Text(l.settingsCalendarSync, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    subtitle: Text(l.settingsCalendarSyncHint, style: const TextStyle(fontSize: 12)),
                    value: ref.watch(notificationSettingsProvider).calendarSyncEnabled,
                    onChanged: (val) => ref.read(notificationSettingsProvider.notifier).setCalendarSync(val),
                  ),
                ],
              ).animate().fadeIn(delay: 195.ms).slideY(begin: 0.05),
              _SettingsSection(
                title: l.settingsAbout,
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(l.settingsVersion),
                    trailing: Text(
                      AppConstants.appVersion,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title: const Text(AppConstants.appName),
                    subtitle: Text(l.settingsAboutDesc),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _setupPin(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final pin = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsPinSet),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pin,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(labelText: l.settingsPinLabel),
            ),
            TextField(
              controller: confirm,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              decoration: InputDecoration(labelText: l.settingsPinConfirm),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.buttonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.buttonSave)),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;
    final p1 = pin.text.trim();
    final p2 = confirm.text.trim();
    if (p1.length < 4 || p1.length > 6 || p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.settingsPinInvalid)),
      );
      return;
    }
    await ref.read(appLockSettingsProvider.notifier).setPin(p1);
    ref.read(appLockSessionProvider.notifier).unlock();
  }

  Future<void> _setTimeout(BuildContext context, WidgetRef ref, AppLocalizations l, int current) async {
    int selected = current;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(l.settingsAppLockTimeout),
          content: DropdownButton<int>(
            value: selected,
            items: const [1, 3, 5, 10, 15]
                .map((e) => DropdownMenuItem(value: e, child: Text(l.settingsAppLockTimeoutValue(e))))
                .toList(),
            onChanged: (v) {
              if (v != null) setDialog(() => selected = v);
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.buttonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.buttonSave)),
          ],
        ),
      ),
    );
    if (ok == true) {
      await ref.read(appLockSettingsProvider.notifier).setTimeoutMinutes(selected);
    }
  }

  Future<void> _exportBackup(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.backupExportWebError)),
      );
      return;
    }
    final path = await ref.read(backupServiceProvider).exportToFile();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.settingsBackupExportSuccess(path))),
    );
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final confirmReplace = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsBackupImportConfirmTitle),
        content: Text(l.settingsBackupImportConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.buttonSave),
          ),
        ],
      ),
    );
    if (confirmReplace != true || !context.mounted) return;

    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsBackupImportDialogTitle),
        content: TextField(
          controller: ctrl,
          minLines: 8,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: l.settingsBackupImportDialogHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.buttonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.settingsBackupImport)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      final count = await ref.read(backupServiceProvider).importFromJson(ctrl.text);
      await ref.read(reminderSchedulerProvider).scheduleAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.settingsBackupImportSuccess(count))),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.settingsBackupImportError)),
      );
    }
  }

  Future<bool?> _confirm(BuildContext context, AppLocalizations l) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsCancelAll),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.buttonDelete),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 16, 10),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDarkElevated : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight.withOpacity(0.5)),
            boxShadow: cardShadow(isDark),
          ),
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
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text(l.settingsThemeSystem),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text(l.settingsThemeLight),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text(l.settingsThemeDark),
          ),
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
          DropdownMenuItem(
            value: const Locale('cs'),
            child: Text('🇨🇿  ${l.settingsLanguageCzech}'),
          ),
          DropdownMenuItem(
            value: const Locale('en'),
            child: Text('🇬🇧  ${l.settingsLanguageEnglish}'),
          ),
        ],
        onChanged: (locale) {
          if (locale != null) ref.read(localeProvider.notifier).setLocale(locale);
        },
      ),
    );
  }
}

class _NotificationHorizonTile extends ConsumerWidget {
  const _NotificationHorizonTile({required this.current, required this.l});
  final int current;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.timeline_rounded),
      title: Text(l.settingsNotifHorizon),
      subtitle: Text(l.settingsNotifHorizonValue(current)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showPicker(context, ref),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsNotifHorizon),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 3, 6, 12, 24, 36].map((m) {
            return RadioListTile<int>(
              title: Text(l.settingsNotifHorizonValue(m)),
              value: m,
              groupValue: current,
              onChanged: (v) {
                if (v != null) {
                  ref.read(notificationSettingsProvider.notifier).setHorizon(v);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NotificationLimitTile extends ConsumerWidget {
  const _NotificationLimitTile({required this.current, required this.l});
  final int current;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String label = current == 1 
      ? l.settingsNotifLimitOnlyNext 
      : (current == 0 ? l.settingsNotifLimitAll : l.settingsNotifLimitValue(current));
    
    return ListTile(
      leading: const Icon(Icons.low_priority_rounded),
      title: Text(l.settingsNotifLimit),
      subtitle: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showPicker(context, ref),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsNotifLimit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 3, 5, 10, 0].map((c) {
            String title = c == 1 
              ? l.settingsNotifLimitOnlyNext 
              : (c == 0 ? l.settingsNotifLimitAll : l.settingsNotifLimitValue(c));
            return RadioListTile<int>(
              title: Text(title),
              value: c,
              groupValue: current,
              onChanged: (v) {
                if (v != null) {
                  ref.read(notificationSettingsProvider.notifier).setLimit(v);
                  Navigator.pop(ctx);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

