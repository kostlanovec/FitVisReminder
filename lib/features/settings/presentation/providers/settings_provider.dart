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
    required this.calendarSyncEnabled,
    required this.notificationHours,
  });

  final bool calendarSyncEnabled;

  /// Sorted list of hours (0–23) at which notifications fire each day.
  /// Default: [9] (9 AM). Max 5.
  final List<int> notificationHours;

  /// Convenience getter used by background_handler which still reads a single
  /// "preferred" hour (the first one in the list).
  int get preferredNotificationHour =>
      notificationHours.isEmpty ? 9 : notificationHours.first;
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  static const _calendarSyncKey = 'notif_calendar_sync';
  static const _notifHoursKey = 'notif_hours';   // comma-separated: "9,18"
  static const _legacyHourKey = 'notif_preferred_hour';

  @override
  NotificationSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return NotificationSettings(
      calendarSyncEnabled: prefs.getBool(_calendarSyncKey) ?? false,
      notificationHours: _loadHours(prefs),
    );
  }

  static List<int> _loadHours(dynamic prefs) {
    // New key takes precedence
    final stored = prefs.getString(_notifHoursKey);
    if (stored != null && stored.isNotEmpty) {
      final parsed = stored
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .where((h) => h >= 0 && h <= 23)
          .toList()
        ..sort();
      if (parsed.isNotEmpty) return parsed;
    }
    // Migrate from legacy single-int key
    final legacy = prefs.getInt(_legacyHourKey);
    if (legacy != null) return [legacy];
    return [9];
  }

  Future<void> setCalendarSync(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_calendarSyncKey, enabled);
    state = NotificationSettings(
      calendarSyncEnabled: enabled,
      notificationHours: state.notificationHours,
    );
  }

  Future<void> addHour(int hour) async {
    if (state.notificationHours.contains(hour)) return;
    if (state.notificationHours.length >= 5) return; // cap at 5
    final updated = [...state.notificationHours, hour]..sort();
    await _saveHours(updated);
  }

  Future<void> removeHour(int hour) async {
    final updated = state.notificationHours.where((h) => h != hour).toList();
    if (updated.isEmpty) return; // keep at least one
    await _saveHours(updated);
  }

  Future<void> _saveHours(List<int> hours) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_notifHoursKey, hours.join(','));
    state = NotificationSettings(
      calendarSyncEnabled: state.calendarSyncEnabled,
      notificationHours: hours,
    );
  }
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
