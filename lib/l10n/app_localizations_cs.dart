// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'FitVis Reminder';

  @override
  String get navDashboard => 'Přehled';

  @override
  String get navReminders => 'Připomínky';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get navTemplates => 'Šablony';

  @override
  String get onboardingWelcomeTitle => 'Vítejte ve FitVis Reminder';

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
  String get reminderFormBasicInfo => 'Základní informace';

  @override
  String get reminderFormRecurrenceSection => 'Opakování';

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
  String recurrenceCustomDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Každých $count dní',
      few: 'Každé $count dny',
      one: 'Každý den',
    );
    return '$_temp0';
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
  String get settingsNotifications => 'Oznámení';

  @override
  String get settingsNotificationsPermission => 'Povolení notifikací';

  @override
  String get settingsRescheduleAll => 'Přeplánovat vše';

  @override
  String settingsRescheduleResult(int count) {
    return 'Naplánováno $count upozornění';
  }

  @override
  String get settingsNotificationTime => 'Čas notifikací';

  @override
  String settingsNotificationTimeValue(int hour) {
    return 'Notifikace v $hour:00';
  }

  @override
  String get settingsCancelAll => 'Zrušit vše';

  @override
  String get settingsTestNotification => 'Testovací notifikace';

  @override
  String get settingsTestNotificationDesc => 'Odeslat zkušební oznámení';

  @override
  String get settingsTestNotificationSent => 'Testovací notifikace odeslána';

  @override
  String get settingsAbout => 'O aplikaci';

  @override
  String get settingsVersion => 'Verze';

  @override
  String get categoryDocuments => 'Doklady';

  @override
  String get categoryCar => 'Auto';

  @override
  String get categoryHealth => 'Zdraví';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categorySubscriptions => 'Předplatné';

  @override
  String get categoryHome => 'Domácnost';

  @override
  String get categoryDigital => 'Digitální život';

  @override
  String get categoryPets => 'Mazlíčci';

  @override
  String get categoryMaintenance => 'Pravidelná údržba';

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
  String get onboardingFrequencyLabel => 'Frekvence připomínání:';

  @override
  String get onboardingRecommended => '(doporučeno)';

  @override
  String get settingsNotificationsTest => 'Testovací notifikace';

  @override
  String get settingsNotificationsTestHint =>
      'Kliknutím odešlete okamžitou notifikaci pro ověření funkčnosti';

  @override
  String get reminderPriorityLabel => 'Důležitost (priorita):';

  @override
  String get reminderPriorityNormal => 'Normální';

  @override
  String get reminderPriorityHigh => 'Vysoká (Kritická)';

  @override
  String get reminderCustomRecurrence => 'Vlastní opakování...';

  @override
  String get reminderCustomNotification => 'Vlastní upozornění...';

  @override
  String get reminderCustomDays => 'Počet dní';

  @override
  String get reminderCustomMonths => 'Počet měsíců';

  @override
  String get reminderCustomYears => 'Počet let';

  @override
  String get reminderCustomWeeks => 'Týdny';

  @override
  String reminderTriggerCustomDays(int days) {
    return '$days dní předem (Vlastní)';
  }

  @override
  String get reminderCustomLabel => 'Vlastní';

  @override
  String get greetingMorning => 'Dobré ráno ☀️';

  @override
  String get greetingAfternoon => 'Dobrý den 👋';

  @override
  String get greetingEvening => 'Dobrý večer 🌙';

  @override
  String get reminderDetailSnooze => 'Odložit o týden';

  @override
  String get reminderSnoozeMonth => 'Odložit o měsíc';

  @override
  String get reminderListContextSelect => 'Vybrat';

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

  @override
  String get settingsSectionSecurity => 'Bezpečnost';

  @override
  String get settingsAppLock => 'Zámek aplikace (PIN)';

  @override
  String settingsAppLockEnabled(int minutes) {
    return 'Zapnuto, timeout $minutes min';
  }

  @override
  String get settingsAppLockDisabled => 'Vypnuto';

  @override
  String get settingsAppLockTimeout => 'Timeout zamčení';

  @override
  String settingsAppLockTimeoutValue(int minutes) {
    return '$minutes minut';
  }

  @override
  String get settingsAppLockNow => 'Zamknout teď';

  @override
  String get settingsPinInvalid => 'PIN je neplatný nebo se neshoduje.';

  @override
  String get settingsPinSet => 'Nastavit PIN';

  @override
  String get settingsPinLabel => 'PIN (4-6 číslic)';

  @override
  String get settingsPinConfirm => 'Potvrzení PIN';

  @override
  String get appLockTitle => 'Aplikace je zamčená';

  @override
  String get appLockSubtitle => 'Zadej PIN pro odemknutí.';

  @override
  String get appLockPinLabel => 'PIN';

  @override
  String get appLockUnlock => 'Odemknout';

  @override
  String get appLockInvalidPin => 'Neplatný PIN';

  @override
  String get settingsSectionBackup => 'Záloha';

  @override
  String get settingsBackupExport => 'Exportovat zálohu';

  @override
  String get settingsBackupExportHint =>
      'Uloží JSON soubor do dokumentů aplikace';

  @override
  String get settingsBackupImport => 'Importovat zálohu (JSON)';

  @override
  String get settingsBackupImportHint => 'Nahradí aktuální data';

  @override
  String settingsBackupExportSuccess(String path) {
    return 'Záloha uložena: $path';
  }

  @override
  String get settingsBackupImportConfirmTitle => 'Nahradit aktuální data?';

  @override
  String get settingsBackupImportConfirmBody =>
      'Import přepíše všechny aktuální připomínky. Tuto akci nelze vrátit.';

  @override
  String get settingsBackupImportDialogTitle => 'Import JSON zálohy';

  @override
  String get settingsBackupImportDialogHint => 'Vlož obsah JSON zálohy sem...';

  @override
  String settingsBackupImportSuccess(int count) {
    return 'Importováno $count připomínek.';
  }

  @override
  String get settingsBackupImportError =>
      'Import se nepovedl. Zkontroluj JSON.';

  @override
  String get backupExportWebError =>
      'Export do souboru není na webu podporován. Použijte stažení JSON.';

  @override
  String get templatesTitle => 'Knihovna šablon';

  @override
  String get templatesSearchHint => 'Hledat šablony...';

  @override
  String get templatesEmpty => 'Žádné šablony nenalezeny';

  @override
  String templatesAddSuccess(String title) {
    return 'Připomínka \'$title\' byla přidána';
  }

  @override
  String dashboardStatusOverdue(int count) {
    return 'Máte $count restů k vyřízení';
  }

  @override
  String get dashboardStatusAllGood => 'Vše je v naprostém pořádku ✨';

  @override
  String get appLockForgotPin => 'Zapomněli jste PIN?';

  @override
  String get filterHighPriority => 'VYSOKÁ PRIORITA';

  @override
  String get remindersFilterNoResults => 'Žádné výsledky';

  @override
  String get remindersFilterNoResultsHint =>
      'Zkuste jiný filtr nebo vyhledávání';

  @override
  String get errorTitle => 'Něco se pokazilo';

  @override
  String get errorSubtitle => 'Zkus to prosím za chvíli znovu.';

  @override
  String get settingsSectionPerformance => 'Výkon a Oznámení';

  @override
  String get settingsNotifHorizon => 'Horizont plánování';

  @override
  String settingsNotifHorizonValue(int months) {
    return '$months měsíců';
  }

  @override
  String get settingsNotifLimit => 'Max. upozornění na položku';

  @override
  String get settingsNotifLimitOnlyNext => 'Jen nejbližší (optimalizováno)';

  @override
  String settingsNotifLimitValue(int count) {
    return '$count upozornění';
  }

  @override
  String get settingsNotifLimitAll => 'Bez omezení';

  @override
  String get settingsBackupCloud => 'Zálohovat do Cloudu (Drive/iCloud)';

  @override
  String get notificationActionSnooze => 'Odložit';

  @override
  String get notificationActionDone => 'Hotovo';

  @override
  String get notificationActionUnderstand => 'Rozumím ✓';

  @override
  String notificationBodyToday(Object title) {
    return 'Dnes nastává termín: $title';
  }

  @override
  String notificationBodyTomorrow(Object title) {
    return 'Zítra nastává termín: $title';
  }

  @override
  String notificationBodyInDays(int days, String title) {
    return 'Za $days dní nastává termín: $title';
  }

  @override
  String notificationBodyRemind(String date, String title) {
    return 'Připomenutí: $title - $date';
  }

  @override
  String get backupShareSubject => 'FitVis Reminder Záloha';

  @override
  String get backupShareText => 'Záloha mých připomínek z FitVis Reminder';

  @override
  String get notificationChannelReminders => 'Připomínky';

  @override
  String get notificationChannelRemindersDesc =>
      'Obecné připomínky životní údržby';

  @override
  String get notificationChannelImportant => 'Důležité termíny';

  @override
  String get notificationChannelImportantDesc =>
      'Upozornění na blížící se důležité termíny';

  @override
  String get notificationChannelUpcoming => 'Nadcházející události';

  @override
  String get notificationChannelUpcomingDesc =>
      'Informace o událostech v dalších týdnech';

  @override
  String reminderDetailOverdueCount(int days) {
    return '${days}d po termínu';
  }

  @override
  String get reminderDetailDueToday => 'Dnes';

  @override
  String get reminderDetailDueTomorrow => 'Zítra';

  @override
  String reminderDetailDueInDays(int days) {
    return 'Za ${days}d';
  }

  @override
  String get reminderNotFound => 'Připomínka nenalezena';

  @override
  String get settingsAboutDesc => 'Systém pro údržbu životních termínů';

  @override
  String get reminderMarkDoneAction => 'Označit jako splněné';

  @override
  String get priorityHigh => 'VYSOKÁ PRIORITA';

  @override
  String get settingsCalendarSync => 'Synchronizace s kalendářem';

  @override
  String get settingsCalendarSyncHint =>
      'Automaticky přidávat termíny do systémového kalendáře';

  @override
  String get buttonShare => 'Sdílet';

  @override
  String selectionShare(Object count) {
    return 'Sdílet ($count)';
  }

  @override
  String get dashboardSectionUpcoming => 'Nadcházející';

  @override
  String get dashboardNothingUpcoming => 'Nic nadcházejícího';

  @override
  String get reminderFormTriggersSection => 'Upozornění';

  @override
  String get reminderFormTriggersRequired => 'Vyberte alespoň jedno upozornění';

  @override
  String get settingsBatteryOptimization => 'Běh na pozadí (baterie)';

  @override
  String get settingsBatteryOptimizationDisabled =>
      'Optimalizováno (může zpozdit připomínky)';

  @override
  String get settingsBatteryOptimizationEnabled =>
      'Bez omezení (spolehlivý běh)';

  @override
  String get settingsBatteryAlreadyAllowed =>
      'Aplikace má již povolen spolehlivý běh na pozadí.';

  @override
  String get settingsPreciseAlarms => 'Přesné budíky';

  @override
  String get settingsPreciseAlarmsEnabled => 'Povoleno (přesné doručování)';

  @override
  String get settingsPreciseAlarmsDisabled =>
      'Nepovoleno (upozornění se mohou zpozdit)';

  @override
  String get settingsPreciseAlarmsDialogTitle => 'Vyžadovány přesné budíky';

  @override
  String get settingsPreciseAlarmsDialogBody =>
      'Tato aplikace potřebuje povolení pro přesné budíky, aby mohla doručovat notifikace přesně na čas. Klikněte na Uložit a povolte je v nastavení systému.';

  @override
  String get dashboardSectionOverdue => 'Prošlé';

  @override
  String get dashboardSectionThisWeek => 'Tento týden';

  @override
  String get dashboardCalmTitle => 'Vše v pořádku';

  @override
  String get dashboardCalmHint => 'V příštím měsíci žádné blížící se termíny.';

  @override
  String get dashboardCalmNext => 'Příště';

  @override
  String dashboardShowAll(int count) {
    return 'Zobrazit vše ($count)';
  }

  @override
  String get settingsNotificationTimeAdd => 'Přidat čas';

  @override
  String get settingsNotificationTimeAddHint => 'Vyberte hodinu (0–23)';

  @override
  String get settingsNotificationTimesLabel => 'Časy notifikací';

  @override
  String get settingsNotificationTimesHint =>
      'Připomínky budou zaslány v tyto časy. Max 5.';

  @override
  String get settingsNotificationTimeAlreadyExists =>
      'Tento čas je již přidán.';

  @override
  String get settingsNotificationTimeAtLeastOne =>
      'Musí zůstat alespoň jeden čas.';

  @override
  String get permissionBannerTitle => 'Notifikace nemusí fungovat spolehlivě';

  @override
  String get permissionBannerBody =>
      'Chybí oprávnění. Klepnutím opravíte v nastavení.';

  @override
  String get permissionBannerFix => 'Opravit';

  @override
  String get settingsRomGuideTitle => 'Speciální nastavení výrobce';

  @override
  String get settingsRomGuideSubtitle =>
      'Xiaomi, Huawei, Samsung, Oppo a další';

  @override
  String get settingsRomGuideBody =>
      'Některé telefony mají extra ochranu baterie, která může blokovat připomínky na pozadí. Níže jsou kroky pro nejrozšířenější výrobce:\n\n📱 Xiaomi / HyperOS\nNastavení → Aplikace → Správa aplikací → [Tato aplikace] → Baterie → Bez omezení\nNavíc: Nastavení → Aplikace → [Tato aplikace] → Automatické spouštění → Zapnout\n\n📱 Huawei / Honor\nNastavení → Aplikace → [Tato aplikace] → Baterie → Spouštění aplikace → Spravovat ručně → Povolte vše\n\n📱 Samsung (One UI)\nNastavení → Péče o zařízení → Baterie → Limity využití na pozadí → odeberte aplikaci ze seznamu\n\n📱 Oppo / Realme (ColorOS)\nNastavení → Baterie → Optimalizace baterie → [Tato aplikace] → Neoptimalizovat\n\n📱 Vivo (FuntouchOS)\nNastavení → Baterie → Vysoká spotřeba na pozadí → přidejte tuto aplikaci';

  @override
  String get settingsRomGuideClose => 'Zavřít';

  @override
  String get importSelectRemindersHint =>
      'Vyberte připomínky, které chcete přidat do svého seznamu:';

  @override
  String importAction(int count) {
    return 'Importovat ($count)';
  }

  @override
  String importSuccess(int count) {
    return 'Úspěšně importováno $count připomínek';
  }

  @override
  String get importSelectTitle => 'Vybrat připomínky k importu';

  @override
  String get categoryCustom => 'Vlastní';

  @override
  String get categoryDocumentsDesc => 'Průkazy, pasy, povolení';

  @override
  String get categoryCarDesc => 'STK, pojištění, servis';

  @override
  String get categoryHealthDesc => 'Lékaři, prohlídky, očkování';

  @override
  String get categoryFinanceDesc => 'Daně, pojistky, splátky';

  @override
  String get categorySubscriptionsDesc => 'Netflix, Spotify, tarify';

  @override
  String get categoryHomeDesc => 'Revize, filtry, údržba';

  @override
  String get categoryDigitalDesc => 'Domény, certifikáty, licence';

  @override
  String get categoryPetsDesc => 'Veterina, očkování, krmení';

  @override
  String get categoryMaintenanceDesc => 'Kartáčky, filtry, čištění';

  @override
  String get categoryCustomDesc => 'Vlastní připomínky';

  @override
  String recurrenceCustomYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Každých $count let',
      few: 'Každé $count roky',
      one: 'Každý rok',
    );
    return '$_temp0';
  }

  @override
  String recurrenceCustomWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Každých $count týdnů',
      few: 'Každé $count týdny',
      one: 'Každý týden',
    );
    return '$_temp0';
  }

  @override
  String recurrenceCustomMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Každých $count měsíců',
      few: 'Každé $count měsíce',
      one: 'Každý měsíc',
    );
    return '$_temp0';
  }
}
