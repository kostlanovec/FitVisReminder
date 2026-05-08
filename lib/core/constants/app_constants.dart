abstract final class AppConstants {
  static const String appName = 'LifeTrack';
  static const String appVersion = '1.0.0';
  static const String dbName = 'life_track.isar';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themeModeKey = 'theme_mode';
  static const String localeKey = 'locale';

  static const int maxScheduledNotifications = 64;
  static const int notificationChannelImportant = 1;
  static const int notificationChannelReminder = 2;
  static const int notificationChannelUpcoming = 3;

  static const Duration maxAdvanceSchedule = Duration(days: 365);
}
