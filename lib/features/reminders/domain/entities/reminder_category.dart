import 'package:flutter/material.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';

enum ReminderCategory {
  documents,
  car,
  health,
  finance,
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
      ReminderCategory.home => '🏠',
      ReminderCategory.digital => '💻',
      ReminderCategory.pets => '🐾',
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
      ReminderCategory.finance => 'Daně, předplatná, pojistky',
      ReminderCategory.home => 'Revize, filtry, údržba',
      ReminderCategory.digital => 'Domény, certifikáty, licence',
      ReminderCategory.pets => 'Veterina, očkování, krmení',
      ReminderCategory.maintenance => 'Kartáčky, filtry, čištění',
      ReminderCategory.custom => 'Vlastní připomínky',
    };
  }
}
