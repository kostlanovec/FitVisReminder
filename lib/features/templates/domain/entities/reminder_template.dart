import 'package:equatable/equatable.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';

class ReminderTemplate extends Equatable {
  const ReminderTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.defaultRecurrence,
    required this.defaultTriggers,
    required this.description,
    required this.icon,
    this.recommendedIntervalDays,
    this.onboardingQuestion,
    this.onboardingHint,
    this.isPopular = false,
  });

  final String id;
  final String title;
  final ReminderCategory category;
  final RecurrenceRule defaultRecurrence;
  final List<NotificationTrigger> defaultTriggers;
  final String description;
  final String icon;
  final int? recommendedIntervalDays;
  final String? onboardingQuestion;
  final String? onboardingHint;
  final bool isPopular;

  @override
  List<Object?> get props => [id, title, category];
}
