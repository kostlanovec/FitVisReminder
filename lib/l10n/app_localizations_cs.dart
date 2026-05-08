// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'LifeTrack';

  @override
  String get navDashboard => 'Přehled';

  @override
  String get navReminders => 'Připomínky';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get onboardingWelcomeTitle => 'Vítejte v LifeTrack';

  @override
  String get onboardingWelcomeSubtitle =>
      'Váš osobní asistent pro správu životních povinností.\nNikdy nezapomeňte na STK, zubaře nebo pas.';

  @override
  String get onboardingWelcomeHint =>
      'Teď si projdeme kategorie a vyberete, co chcete sledovat.';

  @override
  String get onboardingFeatureNotifications => 'Chytré upozornění předem';

  @override
  String get onboardingFeatureRecurring => 'Opakující se připomínky';

  @override
  String get onboardingFeatureBattery => 'Šetrné k baterii';

  @override
  String get onboardingFeatureOffline => 'Funguje offline';

  @override
  String get onboardingNothingSelected => 'Nic nevybráno';

  @override
  String onboardingSelectedCount(int count, int total) {
    return 'Vybráno: $count z $total';
  }

  @override
  String get onboardingSelectAll => 'Vybrat vše';

  @override
  String get onboardingDeselectAll => 'Odebrat vše';

  @override
  String get onboardingSkip => 'Přeskočit';

  @override
  String get onboardingNext => 'Další';

  @override
  String get onboardingStart => 'Začít';

  @override
  String get onboardingFinish => 'Dokončit';

  @override
  String get onboardingCustomCard => 'Přidat vlastní připomínku';

  @override
  String get onboardingCustomHint => 'Něco v seznamu chybí? Přidejte ručně.';

  @override
  String get onboardingCustomTitle => 'Vlastní připomínka';

  @override
  String get onboardingCustomNameHint => 'např. Silniční daň, zubař...';

  @override
  String get onboardingCustomNameLabel => 'Název';

  @override
  String get onboardingCustomCategoryLabel => 'Kategorie';

  @override
  String get onboardingCustomRecurrenceLabel => 'Opakování';

  @override
  String get onboardingCustomAdd => 'Přidat';

  @override
  String get onboardingCustomCancel => 'Zrušit';

  @override
  String get dashboardGreeting => 'Dobrý den 👋';

  @override
  String get dashboardTitle => 'Přehled';

  @override
  String get dashboardSectionAttention => 'Vyžaduje pozornost';

  @override
  String get dashboardSectionThisMonth => 'Tento měsíc';

  @override
  String get dashboardSectionCategories => 'Kategorie';

  @override
  String get dashboardAllGood => 'Vše v pořádku';

  @override
  String get dashboardNoUrgent => 'Žádné urgentní termíny.';

  @override
  String get dashboardNothingThisMonth => 'Nic dalšího tento měsíc 🎉';

  @override
  String get dashboardStatOverdue => 'Po termínu';

  @override
  String get dashboardStatSoon => 'Brzy';

  @override
  String get dashboardStatTotal => 'Celkem';

  @override
  String get dashboardAddButton => 'Přidat';

  @override
  String get dashboardSeeAll => 'Vše';

  @override
  String get remindersTitle => 'Připomínky';

  @override
  String get remindersSearchHint => 'Hledat...';

  @override
  String get remindersEmpty => 'Zatím žádné připomínky.';

  @override
  String get remindersEmptyHint => 'Klikněte na + a přidejte první připomínku.';

  @override
  String get remindersOverdue => 'Po termínu';

  @override
  String get remindersUpcoming => 'Nadcházející';

  @override
  String remindersCount(int count) {
    return '$count položek';
  }

  @override
  String get reminderFormTitleNew => 'Nová připomínka';

  @override
  String get reminderFormTitleEdit => 'Upravit připomínku';

  @override
  String get reminderFormSave => 'Uložit';

  @override
  String get reminderFormFieldTitle => 'Název *';

  @override
  String get reminderFormFieldTitleHint => 'např. STK, Zubař, Pas...';

  @override
  String get reminderFormFieldTitleRequired => 'Název je povinný';

  @override
  String get reminderFormFieldDescription => 'Popis';

  @override
  String get reminderFormFieldDescriptionHint => 'Volitelný popis...';

  @override
  String get reminderFormFieldCategory => 'Kategorie';

  @override
  String get reminderFormFieldDueDate => 'Termín';

  @override
  String get reminderFormFieldRecurrence => 'Opakování';

  @override
  String get reminderFormFieldNotifications => 'Upozornění';

  @override
  String get reminderFormTemplateSection => 'Šablona (volitelné)';

  @override
  String get reminderFormAllTemplates => 'Všechny šablony';

  @override
  String get reminderFormPickTemplate => 'Vyberte šablonu';

  @override
  String get recurrenceOnce => 'Jednorázově';

  @override
  String get recurrenceDaily => 'Každý den';

  @override
  String get recurrenceWeekly => 'Každý týden';

  @override
  String get recurrenceMonthly => 'Každý měsíc';

  @override
  String get recurrenceYearly => 'Každý rok';

  @override
  String recurrenceCustomDays(int days) {
    return 'Každých $days dní';
  }

  @override
  String get triggerMonthBefore => 'Měsíc předem';

  @override
  String get triggerWeekBefore => 'Týden předem';

  @override
  String get triggerDayBefore => 'Den předem';

  @override
  String get triggerSameDay => 'V den termínu';

  @override
  String get reminderDetailMarkDone => 'Splněno';

  @override
  String get reminderDetailDelete => 'Smazat';

  @override
  String get reminderDetailDeleteConfirm => 'Smazat tuto připomínku?';

  @override
  String get reminderDetailDeleteCancel => 'Zrušit';

  @override
  String get reminderDetailNextOccurrences => 'Nadcházející výskyty';

  @override
  String get reminderDetailSchedule => 'Plán upozornění';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsTheme => 'Motiv';

  @override
  String get settingsThemeSystem => 'Systém';

  @override
  String get settingsThemeLight => 'Světlý';

  @override
  String get settingsThemeDark => 'Tmavý';

  @override
  String get settingsLanguage => 'Jazyk';

  @override
  String get settingsLanguageCzech => 'Čeština';

  @override
  String get settingsLanguageEnglish => 'Angličtina';

  @override
  String get settingsNotifications => 'Notifikace';

  @override
  String get settingsNotificationsPermission => 'Povolení notifikací';

  @override
  String get settingsRescheduleAll => 'Přeplánovat vše';

  @override
  String get settingsCancelAll => 'Zrušit vše';

  @override
  String get settingsAbout => 'O aplikaci';

  @override
  String get settingsVersion => 'Verze';

  @override
  String get categoryDocuments => 'Dokumenty';

  @override
  String get categoryCar => 'Auto';

  @override
  String get categoryHealth => 'Zdraví';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryHome => 'Domov';

  @override
  String get categoryDigital => 'Digitální';

  @override
  String get categoryPets => 'Mazlíčci';

  @override
  String get categoryMaintenance => 'Údržba';

  @override
  String get buttonAdd => 'Přidat';

  @override
  String get buttonSave => 'Uložit';

  @override
  String get buttonCancel => 'Zrušit';

  @override
  String get buttonDelete => 'Smazat';

  @override
  String get buttonEdit => 'Upravit';

  @override
  String get buttonClose => 'Zavřít';

  @override
  String get buttonBack => 'Zpět';

  @override
  String get reminderDetailSnooze => 'Odložit o týden';

  @override
  String reminderDetailSnoozed(String date) {
    return 'Odloženo na $date';
  }

  @override
  String get reminderDetailLastCompleted => 'Naposledy splněno';

  @override
  String get reminderDetailNeverCompleted => 'Zatím nesplněno';

  @override
  String get reminderDetailSectionUpcoming => 'Nadcházející termíny';

  @override
  String get reminderDetailSectionSchedule => 'Plán upozornění';

  @override
  String get reminderDetailSectionInfo => 'Informace';

  @override
  String get reminderDetailCreatedAt => 'Vytvořeno';

  @override
  String selectionCount(int count) {
    return 'Vybráno: $count';
  }

  @override
  String selectionDelete(int count) {
    return 'Smazat ($count)';
  }

  @override
  String selectionMarkDone(int count) {
    return 'Hotovo ($count)';
  }

  @override
  String get selectionCancel => 'Zrušit výběr';

  @override
  String selectionDeleteConfirm(int count) {
    return 'Smazat $count připomínek?';
  }

  @override
  String get selectionDeleteHint => 'Tuto akci nelze vrátit.';
}
