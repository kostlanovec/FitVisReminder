import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FitVis Reminder'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get navReminders;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get navTemplates;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FitVis Reminder'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal assistant for life maintenance.\nNever forget your MOT, dentist appointment or passport expiry.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingWelcomeHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll go through each category so you can pick what to track.'**
  String get onboardingWelcomeHint;

  /// No description provided for @onboardingFeatureNotifications.
  ///
  /// In en, this message translates to:
  /// **'Smart advance notifications'**
  String get onboardingFeatureNotifications;

  /// No description provided for @onboardingFeatureRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring reminders'**
  String get onboardingFeatureRecurring;

  /// No description provided for @onboardingFeatureBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery-friendly'**
  String get onboardingFeatureBattery;

  /// No description provided for @onboardingFeatureOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get onboardingFeatureOffline;

  /// No description provided for @onboardingNothingSelected.
  ///
  /// In en, this message translates to:
  /// **'Nothing selected'**
  String get onboardingNothingSelected;

  /// No description provided for @onboardingSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count} of {total}'**
  String onboardingSelectedCount(int count, int total);

  /// No description provided for @onboardingSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get onboardingSelectAll;

  /// No description provided for @onboardingDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get onboardingDeselectAll;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboardingCustomCard.
  ///
  /// In en, this message translates to:
  /// **'Add custom reminder'**
  String get onboardingCustomCard;

  /// No description provided for @onboardingCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Something not in the list? Add it manually.'**
  String get onboardingCustomHint;

  /// No description provided for @onboardingCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom reminder'**
  String get onboardingCustomTitle;

  /// No description provided for @onboardingCustomNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Car tax, dentist...'**
  String get onboardingCustomNameHint;

  /// No description provided for @onboardingCustomNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingCustomNameLabel;

  /// No description provided for @onboardingCustomCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get onboardingCustomCategoryLabel;

  /// No description provided for @onboardingCustomRecurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get onboardingCustomRecurrenceLabel;

  /// No description provided for @onboardingCustomAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get onboardingCustomAdd;

  /// No description provided for @onboardingCustomCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get onboardingCustomCancel;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good day 👋'**
  String get dashboardGreeting;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboardTitle;

  /// No description provided for @dashboardSectionAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get dashboardSectionAttention;

  /// No description provided for @dashboardSectionThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get dashboardSectionThisMonth;

  /// No description provided for @dashboardSectionCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get dashboardSectionCategories;

  /// No description provided for @dashboardAllGood.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get dashboardAllGood;

  /// No description provided for @dashboardNoUrgent.
  ///
  /// In en, this message translates to:
  /// **'No urgent deadlines.'**
  String get dashboardNoUrgent;

  /// No description provided for @dashboardNothingThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Nothing else this month 🎉'**
  String get dashboardNothingThisMonth;

  /// No description provided for @dashboardStatOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dashboardStatOverdue;

  /// No description provided for @dashboardStatSoon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get dashboardStatSoon;

  /// No description provided for @dashboardStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get dashboardStatTotal;

  /// No description provided for @dashboardAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dashboardAddButton;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dashboardSeeAll;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get remindersSearchHint;

  /// No description provided for @remindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.'**
  String get remindersEmpty;

  /// No description provided for @remindersEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first reminder.'**
  String get remindersEmptyHint;

  /// No description provided for @remindersOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get remindersOverdue;

  /// No description provided for @remindersUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get remindersUpcoming;

  /// No description provided for @remindersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String remindersCount(int count);

  /// No description provided for @reminderFormTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get reminderFormTitleNew;

  /// No description provided for @reminderFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get reminderFormTitleEdit;

  /// No description provided for @reminderFormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get reminderFormSave;

  /// No description provided for @reminderFormFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get reminderFormFieldTitle;

  /// No description provided for @reminderFormFieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. MOT, dentist, passport...'**
  String get reminderFormFieldTitleHint;

  /// No description provided for @reminderFormFieldTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get reminderFormFieldTitleRequired;

  /// No description provided for @reminderFormFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reminderFormFieldDescription;

  /// No description provided for @reminderFormFieldDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional description...'**
  String get reminderFormFieldDescriptionHint;

  /// No description provided for @reminderFormFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get reminderFormFieldCategory;

  /// No description provided for @reminderFormFieldDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get reminderFormFieldDueDate;

  /// No description provided for @reminderFormFieldRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get reminderFormFieldRecurrence;

  /// No description provided for @reminderFormFieldNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get reminderFormFieldNotifications;

  /// No description provided for @reminderFormBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic info'**
  String get reminderFormBasicInfo;

  /// No description provided for @reminderFormRecurrenceSection.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get reminderFormRecurrenceSection;

  /// No description provided for @reminderFormTemplateSection.
  ///
  /// In en, this message translates to:
  /// **'Template (optional)'**
  String get reminderFormTemplateSection;

  /// No description provided for @reminderFormAllTemplates.
  ///
  /// In en, this message translates to:
  /// **'All templates'**
  String get reminderFormAllTemplates;

  /// No description provided for @reminderFormPickTemplate.
  ///
  /// In en, this message translates to:
  /// **'Choose a template'**
  String get reminderFormPickTemplate;

  /// No description provided for @recurrenceOnce.
  ///
  /// In en, this message translates to:
  /// **'One-off'**
  String get recurrenceOnce;

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get recurrenceYearly;

  /// No description provided for @recurrenceCustomDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Every day} other{Every {count} days}}'**
  String recurrenceCustomDays(int count);

  /// No description provided for @triggerMonthBefore.
  ///
  /// In en, this message translates to:
  /// **'A month before'**
  String get triggerMonthBefore;

  /// No description provided for @triggerWeekBefore.
  ///
  /// In en, this message translates to:
  /// **'A week before'**
  String get triggerWeekBefore;

  /// No description provided for @triggerDayBefore.
  ///
  /// In en, this message translates to:
  /// **'A day before'**
  String get triggerDayBefore;

  /// No description provided for @triggerSameDay.
  ///
  /// In en, this message translates to:
  /// **'On the day'**
  String get triggerSameDay;

  /// No description provided for @reminderDetailMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get reminderDetailMarkDone;

  /// No description provided for @reminderDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get reminderDetailDelete;

  /// No description provided for @reminderDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this reminder?'**
  String get reminderDetailDeleteConfirm;

  /// No description provided for @reminderDetailDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reminderDetailDeleteCancel;

  /// No description provided for @reminderDetailNextOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Upcoming occurrences'**
  String get reminderDetailNextOccurrences;

  /// No description provided for @reminderDetailSchedule.
  ///
  /// In en, this message translates to:
  /// **'Notification schedule'**
  String get reminderDetailSchedule;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageCzech.
  ///
  /// In en, this message translates to:
  /// **'Czech'**
  String get settingsLanguageCzech;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification permission'**
  String get settingsNotificationsPermission;

  /// No description provided for @settingsRescheduleAll.
  ///
  /// In en, this message translates to:
  /// **'Reschedule all'**
  String get settingsRescheduleAll;

  /// No description provided for @settingsRescheduleResult.
  ///
  /// In en, this message translates to:
  /// **'Scheduled {count} notifications'**
  String settingsRescheduleResult(int count);

  /// No description provided for @settingsNotificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification time'**
  String get settingsNotificationTime;

  /// No description provided for @settingsNotificationTimeValue.
  ///
  /// In en, this message translates to:
  /// **'Notifications at {hour}:00'**
  String settingsNotificationTimeValue(int hour);

  /// No description provided for @settingsCancelAll.
  ///
  /// In en, this message translates to:
  /// **'Cancel all'**
  String get settingsCancelAll;

  /// No description provided for @settingsTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Test notification'**
  String get settingsTestNotification;

  /// No description provided for @settingsTestNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Send a trial notification'**
  String get settingsTestNotificationDesc;

  /// No description provided for @settingsTestNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent'**
  String get settingsTestNotificationSent;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @categoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocuments;

  /// No description provided for @categoryCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get categoryCar;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get categoryFinance;

  /// No description provided for @categorySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get categorySubscriptions;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital life'**
  String get categoryDigital;

  /// No description provided for @categoryPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get categoryPets;

  /// No description provided for @categoryMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get categoryMaintenance;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @onboardingFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder frequency:'**
  String get onboardingFrequencyLabel;

  /// No description provided for @onboardingRecommended.
  ///
  /// In en, this message translates to:
  /// **'(recommended)'**
  String get onboardingRecommended;

  /// No description provided for @settingsNotificationsTest.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get settingsNotificationsTest;

  /// No description provided for @settingsNotificationsTestHint.
  ///
  /// In en, this message translates to:
  /// **'Click to send an immediate notification to verify functionality'**
  String get settingsNotificationsTestHint;

  /// No description provided for @reminderPriorityLabel.
  ///
  /// In en, this message translates to:
  /// **'Importance (Priority):'**
  String get reminderPriorityLabel;

  /// No description provided for @reminderPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get reminderPriorityNormal;

  /// No description provided for @reminderPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High (Critical)'**
  String get reminderPriorityHigh;

  /// No description provided for @reminderCustomRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Custom recurrence...'**
  String get reminderCustomRecurrence;

  /// No description provided for @reminderCustomNotification.
  ///
  /// In en, this message translates to:
  /// **'Custom notification...'**
  String get reminderCustomNotification;

  /// No description provided for @reminderCustomDays.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get reminderCustomDays;

  /// No description provided for @reminderCustomMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get reminderCustomMonths;

  /// No description provided for @reminderCustomYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get reminderCustomYears;

  /// No description provided for @reminderCustomWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get reminderCustomWeeks;

  /// No description provided for @reminderTriggerCustomDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days before (Custom)'**
  String reminderTriggerCustomDays(int days);

  /// No description provided for @reminderCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get reminderCustomLabel;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning ☀️'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon 👋'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening 🌙'**
  String get greetingEvening;

  /// No description provided for @reminderDetailSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 week'**
  String get reminderDetailSnooze;

  /// No description provided for @reminderSnoozeMonth.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 month'**
  String get reminderSnoozeMonth;

  /// No description provided for @reminderListContextSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get reminderListContextSelect;

  /// No description provided for @reminderDetailSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed to {date}'**
  String reminderDetailSnoozed(String date);

  /// No description provided for @reminderDetailLastCompleted.
  ///
  /// In en, this message translates to:
  /// **'Last completed'**
  String get reminderDetailLastCompleted;

  /// No description provided for @reminderDetailNeverCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not completed yet'**
  String get reminderDetailNeverCompleted;

  /// No description provided for @reminderDetailSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming dates'**
  String get reminderDetailSectionUpcoming;

  /// No description provided for @reminderDetailSectionSchedule.
  ///
  /// In en, this message translates to:
  /// **'Notification schedule'**
  String get reminderDetailSectionSchedule;

  /// No description provided for @reminderDetailSectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get reminderDetailSectionInfo;

  /// No description provided for @reminderDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get reminderDetailCreatedAt;

  /// No description provided for @selectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectionCount(int count);

  /// No description provided for @selectionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String selectionDelete(int count);

  /// No description provided for @selectionMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String selectionMarkDone(int count);

  /// No description provided for @selectionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get selectionCancel;

  /// No description provided for @selectionDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} reminders?'**
  String selectionDeleteConfirm(int count);

  /// No description provided for @selectionDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get selectionDeleteHint;

  /// No description provided for @settingsSectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSectionSecurity;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock (PIN)'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled, timeout {minutes} min'**
  String settingsAppLockEnabled(int minutes);

  /// No description provided for @settingsAppLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsAppLockDisabled;

  /// No description provided for @settingsAppLockTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto-lock timeout'**
  String get settingsAppLockTimeout;

  /// No description provided for @settingsAppLockTimeoutValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String settingsAppLockTimeoutValue(int minutes);

  /// No description provided for @settingsAppLockNow.
  ///
  /// In en, this message translates to:
  /// **'Lock now'**
  String get settingsAppLockNow;

  /// No description provided for @settingsPinInvalid.
  ///
  /// In en, this message translates to:
  /// **'PIN is invalid or does not match.'**
  String get settingsPinInvalid;

  /// No description provided for @settingsPinSet.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get settingsPinSet;

  /// No description provided for @settingsPinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN (4-6 digits)'**
  String get settingsPinLabel;

  /// No description provided for @settingsPinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get settingsPinConfirm;

  /// No description provided for @appLockTitle.
  ///
  /// In en, this message translates to:
  /// **'App is locked'**
  String get appLockTitle;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to unlock.'**
  String get appLockSubtitle;

  /// No description provided for @appLockPinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get appLockPinLabel;

  /// No description provided for @appLockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// No description provided for @appLockInvalidPin.
  ///
  /// In en, this message translates to:
  /// **'Invalid PIN'**
  String get appLockInvalidPin;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsSectionBackup;

  /// No description provided for @settingsBackupExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsBackupExport;

  /// No description provided for @settingsBackupExportHint.
  ///
  /// In en, this message translates to:
  /// **'Saves a JSON file to app documents'**
  String get settingsBackupExportHint;

  /// No description provided for @settingsBackupImport.
  ///
  /// In en, this message translates to:
  /// **'Import backup (JSON)'**
  String get settingsBackupImport;

  /// No description provided for @settingsBackupImportHint.
  ///
  /// In en, this message translates to:
  /// **'Replaces current data'**
  String get settingsBackupImportHint;

  /// No description provided for @settingsBackupExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {path}'**
  String settingsBackupExportSuccess(String path);

  /// No description provided for @settingsBackupImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current data?'**
  String get settingsBackupImportConfirmTitle;

  /// No description provided for @settingsBackupImportConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Import will overwrite all current reminders. This action cannot be undone.'**
  String get settingsBackupImportConfirmBody;

  /// No description provided for @settingsBackupImportDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Import JSON backup'**
  String get settingsBackupImportDialogTitle;

  /// No description provided for @settingsBackupImportDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Paste JSON backup content here...'**
  String get settingsBackupImportDialogHint;

  /// No description provided for @settingsBackupImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} reminders.'**
  String settingsBackupImportSuccess(int count);

  /// No description provided for @settingsBackupImportError.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Check JSON format.'**
  String get settingsBackupImportError;

  /// No description provided for @backupExportWebError.
  ///
  /// In en, this message translates to:
  /// **'Export to file is not supported on web. Use JSON download instead.'**
  String get backupExportWebError;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Template Library'**
  String get templatesTitle;

  /// No description provided for @templatesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search templates...'**
  String get templatesSearchHint;

  /// No description provided for @templatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get templatesEmpty;

  /// No description provided for @templatesAddSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reminder \'{title}\' added'**
  String templatesAddSuccess(String title);

  /// No description provided for @dashboardStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'You have {count} tasks to handle'**
  String dashboardStatusOverdue(int count);

  /// No description provided for @dashboardStatusAllGood.
  ///
  /// In en, this message translates to:
  /// **'Everything is in perfect order ✨'**
  String get dashboardStatusAllGood;

  /// No description provided for @appLockForgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get appLockForgotPin;

  /// No description provided for @filterHighPriority.
  ///
  /// In en, this message translates to:
  /// **'HIGH PRIORITY'**
  String get filterHighPriority;

  /// No description provided for @remindersFilterNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get remindersFilterNoResults;

  /// No description provided for @remindersFilterNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or search'**
  String get remindersFilterNoResultsHint;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please try again in a moment.'**
  String get errorSubtitle;

  /// No description provided for @settingsSectionPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance & Notifications'**
  String get settingsSectionPerformance;

  /// No description provided for @settingsNotifHorizon.
  ///
  /// In en, this message translates to:
  /// **'Scheduling Horizon'**
  String get settingsNotifHorizon;

  /// No description provided for @settingsNotifHorizonValue.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String settingsNotifHorizonValue(int months);

  /// No description provided for @settingsNotifLimit.
  ///
  /// In en, this message translates to:
  /// **'Max triggers per reminder'**
  String get settingsNotifLimit;

  /// No description provided for @settingsNotifLimitOnlyNext.
  ///
  /// In en, this message translates to:
  /// **'Only next (optimized)'**
  String get settingsNotifLimitOnlyNext;

  /// No description provided for @settingsNotifLimitValue.
  ///
  /// In en, this message translates to:
  /// **'{count} triggers'**
  String settingsNotifLimitValue(int count);

  /// No description provided for @settingsNotifLimitAll.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get settingsNotifLimitAll;

  /// No description provided for @settingsBackupCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup (Drive/iCloud)'**
  String get settingsBackupCloud;

  /// No description provided for @notificationActionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get notificationActionSnooze;

  /// No description provided for @notificationActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notificationActionDone;

  /// No description provided for @notificationActionUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand ✓'**
  String get notificationActionUnderstand;

  /// No description provided for @notificationBodyToday.
  ///
  /// In en, this message translates to:
  /// **'Today is the deadline: {title}'**
  String notificationBodyToday(Object title);

  /// No description provided for @notificationBodyTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow is the deadline: {title}'**
  String notificationBodyTomorrow(Object title);

  /// No description provided for @notificationBodyInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days is the deadline: {title}'**
  String notificationBodyInDays(int days, String title);

  /// No description provided for @notificationBodyRemind.
  ///
  /// In en, this message translates to:
  /// **'Reminder: {title} - {date}'**
  String notificationBodyRemind(String date, String title);

  /// No description provided for @backupShareSubject.
  ///
  /// In en, this message translates to:
  /// **'FitVis Reminder Backup'**
  String get backupShareSubject;

  /// No description provided for @backupShareText.
  ///
  /// In en, this message translates to:
  /// **'My reminders backup from FitVis Reminder'**
  String get backupShareText;

  /// No description provided for @notificationChannelReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notificationChannelReminders;

  /// No description provided for @notificationChannelRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'General life maintenance reminders'**
  String get notificationChannelRemindersDesc;

  /// No description provided for @notificationChannelImportant.
  ///
  /// In en, this message translates to:
  /// **'Important Deadlines'**
  String get notificationChannelImportant;

  /// No description provided for @notificationChannelImportantDesc.
  ///
  /// In en, this message translates to:
  /// **'Urgent notifications for upcoming deadlines'**
  String get notificationChannelImportantDesc;

  /// No description provided for @notificationChannelUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get notificationChannelUpcoming;

  /// No description provided for @notificationChannelUpcomingDesc.
  ///
  /// In en, this message translates to:
  /// **'Information about events in the following weeks'**
  String get notificationChannelUpcomingDesc;

  /// No description provided for @reminderDetailOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{days}d overdue'**
  String reminderDetailOverdueCount(int days);

  /// No description provided for @reminderDetailDueToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reminderDetailDueToday;

  /// No description provided for @reminderDetailDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get reminderDetailDueTomorrow;

  /// No description provided for @reminderDetailDueInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days}d'**
  String reminderDetailDueInDays(int days);

  /// No description provided for @reminderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Reminder not found'**
  String get reminderNotFound;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Life maintenance system'**
  String get settingsAboutDesc;

  /// No description provided for @reminderMarkDoneAction.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get reminderMarkDoneAction;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH PRIORITY'**
  String get priorityHigh;

  /// No description provided for @settingsCalendarSync.
  ///
  /// In en, this message translates to:
  /// **'Calendar Synchronization'**
  String get settingsCalendarSync;

  /// No description provided for @settingsCalendarSyncHint.
  ///
  /// In en, this message translates to:
  /// **'Automatically add deadlines to system calendar'**
  String get settingsCalendarSyncHint;

  /// No description provided for @buttonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get buttonShare;

  /// No description provided for @selectionShare.
  ///
  /// In en, this message translates to:
  /// **'Share ({count})'**
  String selectionShare(Object count);

  /// No description provided for @dashboardSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get dashboardSectionUpcoming;

  /// No description provided for @dashboardNothingUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing upcoming'**
  String get dashboardNothingUpcoming;

  /// No description provided for @reminderFormTriggersSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get reminderFormTriggersSection;

  /// No description provided for @reminderFormTriggersRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one notification trigger'**
  String get reminderFormTriggersRequired;

  /// No description provided for @settingsBatteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Background execution (battery)'**
  String get settingsBatteryOptimization;

  /// No description provided for @settingsBatteryOptimizationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Optimized (reminders might be delayed)'**
  String get settingsBatteryOptimizationDisabled;

  /// No description provided for @settingsBatteryOptimizationEnabled.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted (reliable execution)'**
  String get settingsBatteryOptimizationEnabled;

  /// No description provided for @settingsBatteryAlreadyAllowed.
  ///
  /// In en, this message translates to:
  /// **'The app already has background execution allowed.'**
  String get settingsBatteryAlreadyAllowed;

  /// No description provided for @settingsPreciseAlarms.
  ///
  /// In en, this message translates to:
  /// **'Precise Alarms'**
  String get settingsPreciseAlarms;

  /// No description provided for @settingsPreciseAlarmsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Allowed (accurate reminders)'**
  String get settingsPreciseAlarmsEnabled;

  /// No description provided for @settingsPreciseAlarmsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Restricted (reminders may be delayed)'**
  String get settingsPreciseAlarmsDisabled;

  /// No description provided for @settingsPreciseAlarmsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Precise Alarms Required'**
  String get settingsPreciseAlarmsDialogTitle;

  /// No description provided for @settingsPreciseAlarmsDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This application needs permission to schedule precise alarms to deliver notifications at the exact scheduled time. Tap Save to open system settings.'**
  String get settingsPreciseAlarmsDialogBody;

  /// No description provided for @dashboardSectionOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dashboardSectionOverdue;

  /// No description provided for @dashboardSectionThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get dashboardSectionThisWeek;

  /// No description provided for @dashboardCalmTitle.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get dashboardCalmTitle;

  /// No description provided for @dashboardCalmHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing due in the next month.'**
  String get dashboardCalmHint;

  /// No description provided for @dashboardCalmNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get dashboardCalmNext;

  /// No description provided for @dashboardShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String dashboardShowAll(int count);

  /// No description provided for @settingsNotificationTimeAdd.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get settingsNotificationTimeAdd;

  /// No description provided for @settingsNotificationTimeAddHint.
  ///
  /// In en, this message translates to:
  /// **'Select hour (0–23)'**
  String get settingsNotificationTimeAddHint;

  /// No description provided for @settingsNotificationTimesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notification times'**
  String get settingsNotificationTimesLabel;

  /// No description provided for @settingsNotificationTimesHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders will be sent at these times. Max 5.'**
  String get settingsNotificationTimesHint;

  /// No description provided for @settingsNotificationTimeAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This time is already added.'**
  String get settingsNotificationTimeAlreadyExists;

  /// No description provided for @settingsNotificationTimeAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'At least one time must remain.'**
  String get settingsNotificationTimeAtLeastOne;

  /// No description provided for @permissionBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications may not be reliable'**
  String get permissionBannerTitle;

  /// No description provided for @permissionBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Missing permissions. Tap to fix in Settings.'**
  String get permissionBannerBody;

  /// No description provided for @permissionBannerFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get permissionBannerFix;

  /// No description provided for @settingsRomGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer-specific setup'**
  String get settingsRomGuideTitle;

  /// No description provided for @settingsRomGuideSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Xiaomi, Huawei, Samsung, Oppo and others'**
  String get settingsRomGuideSubtitle;

  /// No description provided for @settingsRomGuideBody.
  ///
  /// In en, this message translates to:
  /// **'Some phones have extra battery protection that can block background reminders. Below are steps for the most common manufacturers:\n\n📱 Xiaomi / HyperOS\nSettings → Apps → Manage Apps → [This App] → Battery → No restrictions\nAlso: Settings → Apps → [This App] → Autostart → On\n\n📱 Huawei / Honor\nSettings → Apps → [This App] → Battery → App launch → Manage manually → Allow all\n\n📱 Samsung (One UI)\nSettings → Device Care → Battery → Background usage limits → remove this app from the list\n\n📱 Oppo / Realme (ColorOS)\nSettings → Battery → Battery Optimization → [This App] → Don\'t optimize\n\n📱 Vivo (FuntouchOS)\nSettings → Battery → High background power consumption → add this app'**
  String get settingsRomGuideBody;

  /// No description provided for @settingsRomGuideClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsRomGuideClose;

  /// No description provided for @importSelectRemindersHint.
  ///
  /// In en, this message translates to:
  /// **'Select the reminders you want to add to your list:'**
  String get importSelectRemindersHint;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import ({count})'**
  String importAction(int count);

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully imported {count} reminders'**
  String importSuccess(int count);

  /// No description provided for @importSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select reminders to import'**
  String get importSelectTitle;

  /// No description provided for @categoryCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get categoryCustom;

  /// No description provided for @categoryDocumentsDesc.
  ///
  /// In en, this message translates to:
  /// **'ID cards, passports, permits'**
  String get categoryDocumentsDesc;

  /// No description provided for @categoryCarDesc.
  ///
  /// In en, this message translates to:
  /// **'MOT, insurance, service'**
  String get categoryCarDesc;

  /// No description provided for @categoryHealthDesc.
  ///
  /// In en, this message translates to:
  /// **'Doctors, check-ups, vaccines'**
  String get categoryHealthDesc;

  /// No description provided for @categoryFinanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Taxes, insurance, payments'**
  String get categoryFinanceDesc;

  /// No description provided for @categorySubscriptionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Netflix, Spotify, subscriptions'**
  String get categorySubscriptionsDesc;

  /// No description provided for @categoryHomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Inspections, filters, maintenance'**
  String get categoryHomeDesc;

  /// No description provided for @categoryDigitalDesc.
  ///
  /// In en, this message translates to:
  /// **'Domains, certificates, licences'**
  String get categoryDigitalDesc;

  /// No description provided for @categoryPetsDesc.
  ///
  /// In en, this message translates to:
  /// **'Vet, vaccines, feeding'**
  String get categoryPetsDesc;

  /// No description provided for @categoryMaintenanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Brushes, filters, cleaning'**
  String get categoryMaintenanceDesc;

  /// No description provided for @categoryCustomDesc.
  ///
  /// In en, this message translates to:
  /// **'Custom reminders'**
  String get categoryCustomDesc;

  /// No description provided for @recurrenceCustomYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Every year} other{Every {count} years}}'**
  String recurrenceCustomYears(int count);

  /// No description provided for @recurrenceCustomWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Every week} other{Every {count} weeks}}'**
  String recurrenceCustomWeeks(int count);

  /// No description provided for @recurrenceCustomMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Every month} other{Every {count} months}}'**
  String recurrenceCustomMonths(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
