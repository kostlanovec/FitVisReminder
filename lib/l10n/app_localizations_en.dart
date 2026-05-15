// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FitVis Reminder';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navSettings => 'Settings';

  @override
  String get navTemplates => 'Templates';

  @override
  String get onboardingWelcomeTitle => 'Welcome to FitVis Reminder';

  @override
  String get onboardingWelcomeSubtitle =>
      'Your personal assistant for life maintenance.\nNever forget your MOT, dentist appointment or passport expiry.';

  @override
  String get onboardingWelcomeHint =>
      'We\'ll go through each category so you can pick what to track.';

  @override
  String get onboardingFeatureNotifications => 'Smart advance notifications';

  @override
  String get onboardingFeatureRecurring => 'Recurring reminders';

  @override
  String get onboardingFeatureBattery => 'Battery-friendly';

  @override
  String get onboardingFeatureOffline => 'Works offline';

  @override
  String get onboardingNothingSelected => 'Nothing selected';

  @override
  String onboardingSelectedCount(int count, int total) {
    return 'Selected: $count of $total';
  }

  @override
  String get onboardingSelectAll => 'Select all';

  @override
  String get onboardingDeselectAll => 'Deselect all';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String get onboardingCustomCard => 'Add custom reminder';

  @override
  String get onboardingCustomHint =>
      'Something not in the list? Add it manually.';

  @override
  String get onboardingCustomTitle => 'Custom reminder';

  @override
  String get onboardingCustomNameHint => 'e.g. Car tax, dentist...';

  @override
  String get onboardingCustomNameLabel => 'Name';

  @override
  String get onboardingCustomCategoryLabel => 'Category';

  @override
  String get onboardingCustomRecurrenceLabel => 'Recurrence';

  @override
  String get onboardingCustomAdd => 'Add';

  @override
  String get onboardingCustomCancel => 'Cancel';

  @override
  String get dashboardGreeting => 'Good day 👋';

  @override
  String get dashboardTitle => 'Overview';

  @override
  String get dashboardSectionAttention => 'Needs attention';

  @override
  String get dashboardSectionThisMonth => 'This month';

  @override
  String get dashboardSectionCategories => 'Categories';

  @override
  String get dashboardAllGood => 'All good';

  @override
  String get dashboardNoUrgent => 'No urgent deadlines.';

  @override
  String get dashboardNothingThisMonth => 'Nothing else this month 🎉';

  @override
  String get dashboardStatOverdue => 'Overdue';

  @override
  String get dashboardStatSoon => 'Soon';

  @override
  String get dashboardStatTotal => 'Total';

  @override
  String get dashboardAddButton => 'Add';

  @override
  String get dashboardSeeAll => 'All';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersSearchHint => 'Search...';

  @override
  String get remindersEmpty => 'No reminders yet.';

  @override
  String get remindersEmptyHint => 'Tap + to add your first reminder.';

  @override
  String get remindersOverdue => 'Overdue';

  @override
  String get remindersUpcoming => 'Upcoming';

  @override
  String remindersCount(int count) {
    return '$count items';
  }

  @override
  String get reminderFormTitleNew => 'New reminder';

  @override
  String get reminderFormTitleEdit => 'Edit reminder';

  @override
  String get reminderFormSave => 'Save';

  @override
  String get reminderFormFieldTitle => 'Title *';

  @override
  String get reminderFormFieldTitleHint => 'e.g. MOT, dentist, passport...';

  @override
  String get reminderFormFieldTitleRequired => 'Title is required';

  @override
  String get reminderFormFieldDescription => 'Description';

  @override
  String get reminderFormFieldDescriptionHint => 'Optional description...';

  @override
  String get reminderFormFieldCategory => 'Category';

  @override
  String get reminderFormFieldDueDate => 'Due date';

  @override
  String get reminderFormFieldRecurrence => 'Recurrence';

  @override
  String get reminderFormFieldNotifications => 'Notifications';

  @override
  String get reminderFormTemplateSection => 'Template (optional)';

  @override
  String get reminderFormAllTemplates => 'All templates';

  @override
  String get reminderFormPickTemplate => 'Choose a template';

  @override
  String get recurrenceOnce => 'One-off';

  @override
  String get recurrenceDaily => 'Every day';

  @override
  String get recurrenceWeekly => 'Every week';

  @override
  String get recurrenceMonthly => 'Every month';

  @override
  String get recurrenceYearly => 'Every year';

  @override
  String recurrenceCustomDays(int days) {
    return 'Every $days days';
  }

  @override
  String get triggerMonthBefore => 'A month before';

  @override
  String get triggerWeekBefore => 'A week before';

  @override
  String get triggerDayBefore => 'A day before';

  @override
  String get triggerSameDay => 'On the day';

  @override
  String get reminderDetailMarkDone => 'Mark as done';

  @override
  String get reminderDetailDelete => 'Delete';

  @override
  String get reminderDetailDeleteConfirm => 'Delete this reminder?';

  @override
  String get reminderDetailDeleteCancel => 'Cancel';

  @override
  String get reminderDetailNextOccurrences => 'Upcoming occurrences';

  @override
  String get reminderDetailSchedule => 'Notification schedule';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageCzech => 'Czech';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsPermission => 'Notification permission';

  @override
  String get settingsRescheduleAll => 'Reschedule all';

  @override
  String get settingsCancelAll => 'Cancel all';

  @override
  String get settingsTestNotification => 'Test notification';

  @override
  String get settingsTestNotificationDesc => 'Send a trial notification';

  @override
  String get settingsTestNotificationSent => 'Test notification sent';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryCar => 'Car';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categorySubscriptions => 'Subscriptions';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryDigital => 'Digital';

  @override
  String get categoryPets => 'Pets';

  @override
  String get categoryMaintenance => 'Maintenance';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonBack => 'Back';

  @override
  String get onboardingFrequencyLabel => 'Reminder frequency:';

  @override
  String get onboardingRecommended => '(recommended)';

  @override
  String get settingsNotificationsTest => 'Test Notification';

  @override
  String get settingsNotificationsTestHint =>
      'Click to send an immediate notification to verify functionality';

  @override
  String get reminderPriorityLabel => 'Importance (Priority):';

  @override
  String get reminderPriorityNormal => 'Normal';

  @override
  String get reminderPriorityHigh => 'High (Critical)';

  @override
  String get reminderCustomRecurrence => 'Custom recurrence...';

  @override
  String get reminderCustomNotification => 'Custom notification...';

  @override
  String get reminderCustomDays => 'Days';

  @override
  String get reminderCustomMonths => 'Months';

  @override
  String get reminderCustomYears => 'Years';

  @override
  String get reminderCustomLabel => 'Custom';

  @override
  String get greetingMorning => 'Good morning ☀️';

  @override
  String get greetingAfternoon => 'Good afternoon 👋';

  @override
  String get greetingEvening => 'Good evening 🌙';

  @override
  String get reminderDetailSnooze => 'Snooze 1 week';

  @override
  String reminderDetailSnoozed(String date) {
    return 'Snoozed to $date';
  }

  @override
  String get reminderDetailLastCompleted => 'Last completed';

  @override
  String get reminderDetailNeverCompleted => 'Not completed yet';

  @override
  String get reminderDetailSectionUpcoming => 'Upcoming dates';

  @override
  String get reminderDetailSectionSchedule => 'Notification schedule';

  @override
  String get reminderDetailSectionInfo => 'Information';

  @override
  String get reminderDetailCreatedAt => 'Created';

  @override
  String selectionCount(int count) {
    return '$count selected';
  }

  @override
  String selectionDelete(int count) {
    return 'Delete ($count)';
  }

  @override
  String selectionMarkDone(int count) {
    return 'Done ($count)';
  }

  @override
  String get selectionCancel => 'Cancel';

  @override
  String selectionDeleteConfirm(int count) {
    return 'Delete $count reminders?';
  }

  @override
  String get selectionDeleteHint => 'This action cannot be undone.';

  @override
  String get settingsSectionSecurity => 'Security';

  @override
  String get settingsAppLock => 'App lock (PIN)';

  @override
  String settingsAppLockEnabled(int minutes) {
    return 'Enabled, timeout $minutes min';
  }

  @override
  String get settingsAppLockDisabled => 'Disabled';

  @override
  String get settingsAppLockTimeout => 'Auto-lock timeout';

  @override
  String settingsAppLockTimeoutValue(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get settingsAppLockNow => 'Lock now';

  @override
  String get settingsPinInvalid => 'PIN is invalid or does not match.';

  @override
  String get settingsPinSet => 'Set PIN';

  @override
  String get settingsPinLabel => 'PIN (4-6 digits)';

  @override
  String get settingsPinConfirm => 'Confirm PIN';

  @override
  String get appLockTitle => 'App is locked';

  @override
  String get appLockSubtitle => 'Enter your PIN to unlock.';

  @override
  String get appLockPinLabel => 'PIN';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockInvalidPin => 'Invalid PIN';

  @override
  String get settingsSectionBackup => 'Backup';

  @override
  String get settingsBackupExport => 'Export backup';

  @override
  String get settingsBackupExportHint => 'Saves a JSON file to app documents';

  @override
  String get settingsBackupImport => 'Import backup (JSON)';

  @override
  String get settingsBackupImportHint => 'Replaces current data';

  @override
  String settingsBackupExportSuccess(String path) {
    return 'Backup saved: $path';
  }

  @override
  String get settingsBackupImportConfirmTitle => 'Replace current data?';

  @override
  String get settingsBackupImportConfirmBody =>
      'Import will overwrite all current reminders. This action cannot be undone.';

  @override
  String get settingsBackupImportDialogTitle => 'Import JSON backup';

  @override
  String get settingsBackupImportDialogHint =>
      'Paste JSON backup content here...';

  @override
  String settingsBackupImportSuccess(int count) {
    return 'Imported $count reminders.';
  }

  @override
  String get settingsBackupImportError => 'Import failed. Check JSON format.';

  @override
  String get backupExportWebError =>
      'Export to file is not supported on web. Use JSON download instead.';

  @override
  String get templatesTitle => 'Template Library';

  @override
  String get templatesSearchHint => 'Search templates...';

  @override
  String get templatesEmpty => 'No templates found';

  @override
  String templatesAddSuccess(String title) {
    return 'Reminder \'$title\' added';
  }

  @override
  String dashboardStatusOverdue(int count) {
    return 'You have $count tasks to handle';
  }

  @override
  String get dashboardStatusAllGood => 'Everything is in perfect order ✨';

  @override
  String get appLockForgotPin => 'Forgot PIN?';

  @override
  String get filterHighPriority => 'HIGH PRIORITY';

  @override
  String get remindersFilterNoResults => 'No results';

  @override
  String get remindersFilterNoResultsHint => 'Try another filter or search';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorSubtitle => 'Please try again in a moment.';

  @override
  String get settingsSectionPerformance => 'Performance & Notifications';

  @override
  String get settingsNotifHorizon => 'Scheduling Horizon';

  @override
  String settingsNotifHorizonValue(int months) {
    return '$months months';
  }

  @override
  String get settingsNotifLimit => 'Max triggers per reminder';

  @override
  String get settingsNotifLimitOnlyNext => 'Only next (optimized)';

  @override
  String settingsNotifLimitValue(int count) {
    return '$count triggers';
  }

  @override
  String get settingsNotifLimitAll => 'No limit';

  @override
  String get settingsBackupCloud => 'Cloud Backup (Drive/iCloud)';

  @override
  String get notificationActionSnooze => 'Snooze';

  @override
  String get notificationActionDone => 'Done';

  @override
  String get notificationActionUnderstand => 'I understand ✓';

  @override
  String notificationBodyToday(Object title) {
    return 'Today is the deadline: $title';
  }

  @override
  String notificationBodyTomorrow(Object title) {
    return 'Tomorrow is the deadline: $title';
  }

  @override
  String notificationBodyInDays(int days, String title) {
    return 'In $days days is the deadline: $title';
  }

  @override
  String notificationBodyRemind(String date, String title) {
    return 'Reminder: $title - $date';
  }

  @override
  String get backupShareSubject => 'FitVis Reminder Backup';

  @override
  String get backupShareText => 'My reminders backup from FitVis Reminder';

  @override
  String get notificationChannelReminders => 'Reminders';

  @override
  String get notificationChannelRemindersDesc =>
      'General life maintenance reminders';

  @override
  String get notificationChannelImportant => 'Important Deadlines';

  @override
  String get notificationChannelImportantDesc =>
      'Urgent notifications for upcoming deadlines';

  @override
  String get notificationChannelUpcoming => 'Upcoming Events';

  @override
  String get notificationChannelUpcomingDesc =>
      'Information about events in the following weeks';

  @override
  String reminderDetailOverdueCount(int days) {
    return '${days}d overdue';
  }

  @override
  String get reminderDetailDueToday => 'Today';

  @override
  String get reminderDetailDueTomorrow => 'Tomorrow';

  @override
  String reminderDetailDueInDays(int days) {
    return 'In ${days}d';
  }

  @override
  String get reminderNotFound => 'Reminder not found';

  @override
  String get settingsAboutDesc => 'Life maintenance system';

  @override
  String get reminderMarkDoneAction => 'Mark as completed';

  @override
  String get priorityHigh => 'HIGH PRIORITY';

  @override
  String get settingsCalendarSync => 'Calendar Synchronization';

  @override
  String get settingsCalendarSyncHint =>
      'Automatically add deadlines to system calendar';
}
