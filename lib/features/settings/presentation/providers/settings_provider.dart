import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_vis_reminder/core/constants/app_constants.dart';
import 'package:fit_vis_reminder/core/di/providers.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(AppConstants.themeModeKey);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.themeModeKey, mode.name);
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(AppConstants.localeKey);
    return stored != null ? Locale(stored) : const Locale('cs');
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.localeKey, locale.languageCode);
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

final onboardingCompletedProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
});

Future<void> completeOnboarding(WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  await prefs.setBool(AppConstants.onboardingCompletedKey, true);
  ref.invalidate(onboardingCompletedProvider);
}

class AppLockSettings {
  const AppLockSettings({
    required this.enabled,
    required this.pinHash,
    required this.timeoutMinutes,
  });

  final bool enabled;
  final String? pinHash;
  final int timeoutMinutes;

  bool get hasPin => (pinHash ?? '').isNotEmpty;
}

class AppLockSettingsNotifier extends Notifier<AppLockSettings> {
  @override
  AppLockSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppLockSettings(
      enabled: prefs.getBool(AppConstants.appLockEnabledKey) ?? false,
      pinHash: prefs.getString(AppConstants.appLockPinKey),
      timeoutMinutes: prefs.getInt(AppConstants.appLockTimeoutMinutesKey) ?? 3,
    );
  }

  Future<void> setEnabled(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.appLockEnabledKey, value);
    state = AppLockSettings(
      enabled: value,
      pinHash: state.pinHash,
      timeoutMinutes: state.timeoutMinutes,
    );
  }

  Future<void> setPin(String pin) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final hash = _hashPin(pin);
    await prefs.setString(AppConstants.appLockPinKey, hash);
    state = AppLockSettings(
      enabled: true,
      pinHash: hash,
      timeoutMinutes: state.timeoutMinutes,
    );
    await prefs.setBool(AppConstants.appLockEnabledKey, true);
  }

  bool verifyPin(String pin) {
    final hash = state.pinHash;
    if (hash == null || hash.isEmpty) return false;
    return _hashPin(pin) == hash;
  }

  Future<void> setTimeoutMinutes(int minutes) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(AppConstants.appLockTimeoutMinutesKey, minutes);
    state = AppLockSettings(
      enabled: state.enabled,
      pinHash: state.pinHash,
      timeoutMinutes: minutes,
    );
  }

  Future<void> clearPin() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(AppConstants.appLockPinKey);
    await prefs.setBool(AppConstants.appLockEnabledKey, false);
    state = AppLockSettings(
      enabled: false,
      pinHash: null,
      timeoutMinutes: state.timeoutMinutes,
    );
  }

  String _hashPin(String pin) {
    const seed = 2166136261;
    const prime = 16777619;
    final input = '$pin|LifeTrack:v1'.codeUnits;
    var hash = seed;
    for (final unit in input) {
      hash ^= unit;
      hash = (hash * prime) & 0x7fffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

final appLockSettingsProvider =
    NotifierProvider<AppLockSettingsNotifier, AppLockSettings>(
  AppLockSettingsNotifier.new,
);

class AppLockSessionNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  DateTime? _lastBackgroundAt;

  void unlock() => state = true;

  void lockNow() => state = false;

  void markBackgrounded() {
    _lastBackgroundAt = DateTime.now();
  }

  void markResumed(int timeoutMinutes) {
    final last = _lastBackgroundAt;
    if (last == null) return;
    final elapsed = DateTime.now().difference(last);
    if (elapsed.inMinutes >= timeoutMinutes) {
      state = false;
    }
  }
}

final appLockSessionProvider = NotifierProvider<AppLockSessionNotifier, bool>(
  AppLockSessionNotifier.new,
);

class NotificationSettings {
  const NotificationSettings({
    required this.scheduleHorizonMonths,
    required this.maxTriggersPerReminder,
    required this.calendarSyncEnabled,
  });

  final int scheduleHorizonMonths;
  final int maxTriggersPerReminder;
  final bool calendarSyncEnabled;
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  static const _horizonKey = 'notif_horizon_months';
  static const _limitKey = 'notif_limit_per_reminder';
  static const _calendarSyncKey = 'notif_calendar_sync';

  @override
  NotificationSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationSettings(
      scheduleHorizonMonths: prefs.getInt(_horizonKey) ?? 12,
      maxTriggersPerReminder: prefs.getInt(_limitKey) ?? 1,
      calendarSyncEnabled: prefs.getBool(_calendarSyncKey) ?? false,
    );
  }

  Future<void> setHorizon(int months) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_horizonKey, months);
    state = NotificationSettings(
      scheduleHorizonMonths: months,
      maxTriggersPerReminder: state.maxTriggersPerReminder,
      calendarSyncEnabled: state.calendarSyncEnabled,
    );
  }

  Future<void> setLimit(int limit) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_limitKey, limit);
    state = NotificationSettings(
      scheduleHorizonMonths: state.scheduleHorizonMonths,
      maxTriggersPerReminder: limit,
      calendarSyncEnabled: state.calendarSyncEnabled,
    );
  }

  Future<void> setCalendarSync(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_calendarSyncKey, enabled);
    state = NotificationSettings(
      scheduleHorizonMonths: state.scheduleHorizonMonths,
      maxTriggersPerReminder: state.maxTriggersPerReminder,
      calendarSyncEnabled: enabled,
    );
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
