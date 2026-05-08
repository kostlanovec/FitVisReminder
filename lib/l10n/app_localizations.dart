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
  /// **'LifeTrack'**
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

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to LifeTrack'**
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
  /// **'Every day'**
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
  /// **'Every {days} days'**
  String recurrenceCustomDays(int days);

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

  /// No description provided for @settingsCancelAll.
  ///
  /// In en, this message translates to:
  /// **'Cancel all'**
  String get settingsCancelAll;

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

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
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

  /// No description provided for @reminderDetailSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze 1 week'**
  String get reminderDetailSnooze;

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
