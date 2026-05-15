import 'package:equatable/equatable.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';

class Reminder extends Equatable {
  const Reminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.recurrenceRule,
    required this.triggers,
    this.priority = ReminderPriority.normal,
    this.description,
    this.templateId,
    this.isActive = true,
    this.lastCompletedAt,
    this.createdAt,
    this.updatedAt,
    this.customIconCode,
    this.calendarEventId,
  });

  final int id;
  final String title;
  final ReminderCategory category;
  final DateTime dueDate;
  final RecurrenceRule recurrenceRule;
  final List<NotificationTrigger> triggers;
  final ReminderPriority priority;
  final String? description;
  final String? templateId;
  final bool isActive;
  final DateTime? lastCompletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? customIconCode;
  final String? calendarEventId;

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && isActive;

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  Reminder copyWith({
    int? id,
    String? title,
    ReminderCategory? category,
    DateTime? dueDate,
    RecurrenceRule? recurrenceRule,
    List<NotificationTrigger>? triggers,
    ReminderPriority? priority,
    String? description,
    String? templateId,
    bool? isActive,
    DateTime? lastCompletedAt,
    DateTime? updatedAt,
    int? customIconCode,
    String? calendarEventId,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      triggers: triggers ?? this.triggers,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      templateId: templateId ?? this.templateId,
      isActive: isActive ?? this.isActive,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customIconCode: customIconCode ?? this.customIconCode,
      calendarEventId: calendarEventId ?? this.calendarEventId,
    );
  }

  @override
  List<Object?> get props => [id, title, category, dueDate, isActive, recurrenceRule, priority, calendarEventId];
}
