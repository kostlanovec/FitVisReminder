import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fit_vis_reminder/core/constants/app_constants.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/core/utils/app_router.dart';
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
                      final count = await ref.read(reminderSchedulerProvider).scheduleAll(l);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l.settingsRescheduleResult(count)),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                  _NotificationTimesTile(l: l),
                  ListTile(
                    leading: const Icon(Icons.notification_important_rounded),
                    title: Text(l.settingsTestNotification),
                    subtitle: Text(l.settingsTestNotificationDesc),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final svc = ref.read(notificationServiceProvider);
                      final allowed = await svc.isAllowed();
                      if (!allowed) {
                        await svc.requestPermission();
                        return;
                      }
                      try {
                        await svc.showTestNotification(
                          title: "FitVis Reminder 🧪",
                          body: l.settingsTestNotificationSent,
                        );
                      } catch (_) {}
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
                  SwitchListTile(
                    secondary: const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                    title: Text(l.settingsCalendarSync, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    subtitle: Text(l.settingsCalendarSyncHint, style: const TextStyle(fontSize: 12)),
                    value: ref.watch(notificationSettingsProvider).calendarSyncEnabled,
                    onChanged: (val) => ref.read(notificationSettingsProvider.notifier).setCalendarSync(val),
                  ),
                  const Divider(height: 1, indent: 56),
                  _BatteryOptimizationTile(l: l),
                  const Divider(height: 1, indent: 56),
                  _PreciseAlarmsTile(l: l),
                  const Divider(height: 1, indent: 56),
                  _RomGuideTile(l: l),
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
      final reminders = ref.read(backupServiceProvider).parseRemindersFromJson(ctrl.text);
      if (!context.mounted) return;
      // Navigate to SelectiveImportPage so the user can pick which to import
      context.push(AppRoutes.selectiveImport, extra: reminders);
    } catch (_) {
      if (!context.mounted) return;
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

// ── Notification times tile ───────────────────────────────────────────────────

/// Shows the list of configured notification hours and lets the user
/// add (via system TimePicker) or remove individual times.
class _NotificationTimesTile extends ConsumerWidget {
  const _NotificationTimesTile({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hours = ref.watch(notificationSettingsProvider).notificationHours;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              const Icon(Icons.schedule_rounded, size: 22, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.settingsNotificationTimesLabel,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      l.settingsNotificationTimesHint,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Time chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final hour in hours)
                _TimeChip(
                  hour: hour,
                  isDark: isDark,
                  canDelete: hours.length > 1,
                  onDelete: () async {
                    final notifier = ref.read(notificationSettingsProvider.notifier);
                    if (hours.length <= 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l.settingsNotificationTimeAtLeastOne),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    await notifier.removeHour(hour);
                  },
                ),
              // Add button — hidden when cap reached
              if (hours.length < 5)
                ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 16),
                  label: Text(l.settingsNotificationTimeAdd),
                  onPressed: () => _pickAndAdd(context, ref, hours),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAdd(
    BuildContext context,
    WidgetRef ref,
    List<int> current,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: current.last < 23 ? current.last + 1 : 8,
        minute: 0,
      ),
      helpText: l.settingsNotificationTimeAddHint,
    );
    if (picked == null || !context.mounted) return;

    final hour = picked.hour;
    if (current.contains(hour)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.settingsNotificationTimeAlreadyExists),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await ref.read(notificationSettingsProvider.notifier).addHour(hour);
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.hour,
    required this.isDark,
    required this.canDelete,
    required this.onDelete,
  });

  final int hour;
  final bool isDark;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = '${hour.toString().padLeft(2, '0')}:00';
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      avatar: const Icon(Icons.access_time_rounded, size: 15),
      backgroundColor:
          isDark ? AppColors.primary.withOpacity(0.18) : AppColors.primary.withOpacity(0.10),
      side: BorderSide(color: AppColors.primary.withOpacity(0.35)),
      deleteIcon: canDelete
          ? const Icon(Icons.close_rounded, size: 14)
          : null,
      onDeleted: canDelete ? onDelete : null,
      deleteIconColor: AppColors.textSecondary,
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 24, AppSpacing.lg, 10),
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
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDarkElevated : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
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
        borderRadius: BorderRadius.circular(AppRadius.md),
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
        borderRadius: BorderRadius.circular(AppRadius.md),
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

class _BatteryOptimizationTile extends StatefulWidget {
  const _BatteryOptimizationTile({required this.l});
  final AppLocalizations l;

  @override
  State<_BatteryOptimizationTile> createState() => _BatteryOptimizationTileState();
}

class _BatteryOptimizationTileState extends State<_BatteryOptimizationTile> with WidgetsBindingObserver {
  bool _isOptimizing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    if (kIsWeb) return;
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (mounted) {
        setState(() {
          _isOptimizing = !status.isGranted;
        });
      }
    } catch (_) {}
  }

  Future<void> _requestExemption() async {
    if (kIsWeb) return;
    try {
      if (_isOptimizing) {
        final status = await Permission.ignoreBatteryOptimizations.request();
        setState(() {
          _isOptimizing = !status.isGranted;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.l.settingsBatteryAlreadyAllowed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(
        _isOptimizing ? Icons.battery_saver_rounded : Icons.battery_charging_full_rounded,
        color: _isOptimizing ? AppColors.accentAmber : AppColors.primary,
      ),
      title: Text(widget.l.settingsBatteryOptimization),
      subtitle: Text(
        _isOptimizing
            ? widget.l.settingsBatteryOptimizationDisabled
            : widget.l.settingsBatteryOptimizationEnabled,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: _requestExemption,
    );
  }
}

class _PreciseAlarmsTile extends StatefulWidget {
  const _PreciseAlarmsTile({required this.l});
  final AppLocalizations l;

  @override
  State<_PreciseAlarmsTile> createState() => _PreciseAlarmsTileState();
}

class _PreciseAlarmsTileState extends State<_PreciseAlarmsTile> with WidgetsBindingObserver {
  bool _isAllowed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkStatus();
    }
  }

  Future<void> _checkStatus() async {
    if (kIsWeb) return;
    try {
      final status = await Permission.scheduleExactAlarm.status;
      if (mounted) {
        setState(() {
          _isAllowed = status.isGranted;
        });
      }
    } catch (_) {}
  }

  Future<void> _requestPermission() async {
    if (kIsWeb) return;
    if (_isAllowed) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.l.settingsPreciseAlarmsDialogTitle),
        content: Text(widget.l.settingsPreciseAlarmsDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(widget.l.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(widget.l.buttonSave),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await Permission.scheduleExactAlarm.request();
        _checkStatus();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(
        _isAllowed ? Icons.alarm_on_rounded : Icons.alarm_add_rounded,
        color: _isAllowed ? AppColors.primary : AppColors.accentAmber,
      ),
      title: Text(widget.l.settingsPreciseAlarms),
      subtitle: Text(
        _isAllowed
            ? widget.l.settingsPreciseAlarmsEnabled
            : widget.l.settingsPreciseAlarmsDisabled,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: _requestPermission,
    );
  }
}

// ── ROM guide tile ────────────────────────────────────────────────────────────

class _RomGuideTile extends StatelessWidget {
  const _RomGuideTile({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return ListTile(
      leading: const Icon(Icons.phone_android_rounded),
      title: Text(l.settingsRomGuideTitle),
      subtitle: Text(l.settingsRomGuideSubtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showGuide(context),
    );
  }

  void _showGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.phone_android_rounded, size: 22,
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.settingsRomGuideTitle,
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Text(
                  l.settingsRomGuideBody,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

