abstract final class AppConstants {
  static const String appName = 'FitVis Reminder';
  static const String appVersion = '1.0.0';
  static const String dbName = 'life_track.db';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String appLockEnabledKey = 'app_lock_enabled';
  static const String appLockPinKey = 'app_lock_pin_hash';
  static const String appLockTimeoutMinutesKey = 'app_lock_timeout_minutes';

  static const int maxScheduledNotifications = 64;
  static const int notificationChannelImportant = 1;
  static const int notificationChannelReminder = 2;
  static const int notificationChannelUpcoming = 3;

  static const Duration maxAdvanceSchedule = Duration(days: 365);
}
