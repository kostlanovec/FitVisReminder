import 'package:equatable/equatable.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';

import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';

class ReminderTemplate extends Equatable {
  const ReminderTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.defaultRecurrence,
    required this.defaultTriggers,
    required this.description,
    required this.icon,
    this.priority = ReminderPriority.normal,
    this.recommendedIntervalDays,
    this.onboardingQuestion,
    this.onboardingHint,
    this.isPopular = false,
    this.supportsMultiple = false,
  });

  final String id;
  final String title;
  final ReminderCategory category;
  final RecurrenceRule defaultRecurrence;
  final List<NotificationTrigger> defaultTriggers;
  final String description;
  final String icon;
  final ReminderPriority priority;
  final int? recommendedIntervalDays;
  final String? onboardingQuestion;
  final String? onboardingHint;
  final bool isPopular;
  /// Whether the user can create multiple instances of this template
  /// (e.g., multiple payment cards, multiple cars, multiple pets).
  final bool supportsMultiple;

  ReminderTemplate copyWith({
    String? id,
    String? title,
    ReminderCategory? category,
    RecurrenceRule? defaultRecurrence,
    List<NotificationTrigger>? defaultTriggers,
    String? description,
    String? icon,
    ReminderPriority? priority,
    int? recommendedIntervalDays,
    String? onboardingQuestion,
    String? onboardingHint,
    bool? isPopular,
    bool? supportsMultiple,
  }) {
    return ReminderTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      defaultRecurrence: defaultRecurrence ?? this.defaultRecurrence,
      defaultTriggers: defaultTriggers ?? this.defaultTriggers,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      recommendedIntervalDays: recommendedIntervalDays ?? this.recommendedIntervalDays,
      onboardingQuestion: onboardingQuestion ?? this.onboardingQuestion,
      onboardingHint: onboardingHint ?? this.onboardingHint,
      isPopular: isPopular ?? this.isPopular,
      supportsMultiple: supportsMultiple ?? this.supportsMultiple,
    );
  }

  @override
  List<Object?> get props => [id, title, category, supportsMultiple];
}
