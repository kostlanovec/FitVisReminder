import 'package:flutter/material.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/l10n/app_localizations.dart';

enum ReminderCategory {
  documents,
  car,
  health,
  finance,
  subscriptions,
  home,
  digital,
  pets,
  maintenance,
  custom;

  String get label {
    return switch (this) {
      ReminderCategory.documents => 'Doklady',
      ReminderCategory.car => 'Auto',
      ReminderCategory.health => 'Zdraví',
      ReminderCategory.finance => 'Finance',
      ReminderCategory.subscriptions => 'Předplatné',
      ReminderCategory.home => 'Domácnost',
      ReminderCategory.digital => 'Digitální život',
      ReminderCategory.pets => 'Mazlíčci',
      ReminderCategory.maintenance => 'Pravidelná údržba',
      ReminderCategory.custom => 'Vlastní',
    };
  }

  String get emoji {
    return switch (this) {
      ReminderCategory.documents => '🪪',
      ReminderCategory.car => '🚗',
      ReminderCategory.health => '❤️',
      ReminderCategory.finance => '💰',
      ReminderCategory.subscriptions => '🔄',
      ReminderCategory.home => '🏠',
      ReminderCategory.digital => '💻',
      ReminderCategory.pets => '🐶',
      ReminderCategory.maintenance => '🔧',
      ReminderCategory.custom => '⭐',
    };
  }

  Color get color {
    return switch (this) {
      ReminderCategory.documents => AppColors.categoryDocuments,
      ReminderCategory.car => AppColors.categoryCar,
      ReminderCategory.health => AppColors.categoryHealth,
      ReminderCategory.finance => AppColors.categoryFinance,
      ReminderCategory.subscriptions => const Color(0xFFFF4081), // Pink for subscriptions
      ReminderCategory.home => AppColors.categoryHome,
      ReminderCategory.digital => AppColors.categoryDigital,
      ReminderCategory.pets => AppColors.categoryPets,
      ReminderCategory.maintenance => AppColors.categoryMaintenance,
      ReminderCategory.custom => AppColors.categoryCustom,
    };
  }

  String get description {
    return switch (this) {
      ReminderCategory.documents => 'Průkazy, pasy, povolení',
      ReminderCategory.car => 'STK, pojištění, servis',
      ReminderCategory.health => 'Lékaři, prohlídky, očkování',
      ReminderCategory.finance => 'Daně, pojistky, splátky',
      ReminderCategory.subscriptions => 'Netflix, Spotify, tarify',
      ReminderCategory.home => 'Revize, filtry, údržba',
      ReminderCategory.digital => 'Domény, certifikáty, licence',
      ReminderCategory.pets => 'Veterina, očkování, krmení',
      ReminderCategory.maintenance => 'Kartáčky, filtry, čištění',
      ReminderCategory.custom => 'Vlastní připomínky',
    };
  }

  String localizedLabel(AppLocalizations l) => switch (this) {
    ReminderCategory.documents    => l.categoryDocuments,
    ReminderCategory.car          => l.categoryCar,
    ReminderCategory.health       => l.categoryHealth,
    ReminderCategory.finance      => l.categoryFinance,
    ReminderCategory.subscriptions => l.categorySubscriptions,
    ReminderCategory.home         => l.categoryHome,
    ReminderCategory.digital      => l.categoryDigital,
    ReminderCategory.pets         => l.categoryPets,
    ReminderCategory.maintenance  => l.categoryMaintenance,
    ReminderCategory.custom       => l.categoryCustom,
  };

  String localizedDescription(AppLocalizations l) => switch (this) {
    ReminderCategory.documents    => l.categoryDocumentsDesc,
    ReminderCategory.car          => l.categoryCarDesc,
    ReminderCategory.health       => l.categoryHealthDesc,
    ReminderCategory.finance      => l.categoryFinanceDesc,
    ReminderCategory.subscriptions => l.categorySubscriptionsDesc,
    ReminderCategory.home         => l.categoryHomeDesc,
    ReminderCategory.digital      => l.categoryDigitalDesc,
    ReminderCategory.pets         => l.categoryPetsDesc,
    ReminderCategory.maintenance  => l.categoryMaintenanceDesc,
    ReminderCategory.custom       => l.categoryCustomDesc,
  };
}
