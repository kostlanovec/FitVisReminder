// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LifeTrack';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navSettings => 'Settings';

  @override
  String get onboardingWelcomeTitle => 'Welcome to LifeTrack';

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
}
