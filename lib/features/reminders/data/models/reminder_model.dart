import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';

part 'reminder_model.g.dart';

@collection
class ReminderData {
  ReminderData({
    required this.title,
    required this.categoryIndex,
    required this.dueDate,
    required this.recurrenceRuleJson,
    required this.triggersJson,
    this.description,
    this.templateId,
    this.isActive = true,
    this.lastCompletedAt,
    this.createdAt,
    this.updatedAt,
    this.customIconCode,
    this.calendarEventId,
  });

  Id id = Isar.autoIncrement;
  late String title;
  late int categoryIndex;
  late DateTime dueDate;
  late String recurrenceRuleJson;
  late String triggersJson;
  String? description;
  String? templateId;
  late bool isActive;
  DateTime? lastCompletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? customIconCode;
  String? calendarEventId;

  Reminder toDomain() {
    return Reminder(
      id: id,
      title: title,
      category: ReminderCategory.values[categoryIndex],
      dueDate: dueDate,
      recurrenceRule: _parseRecurrenceRule(),
      triggers: _parseTriggers(),
      description: description,
      templateId: templateId,
      isActive: isActive,
      lastCompletedAt: lastCompletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      customIconCode: customIconCode,
      calendarEventId: calendarEventId,
    );
  }

  static ReminderData fromDomain(Reminder reminder) {
    return ReminderData(
      title: reminder.title,
      categoryIndex: reminder.category.index,
      dueDate: reminder.dueDate,
      recurrenceRuleJson: jsonEncode(reminder.recurrenceRule.toJson()),
      triggersJson: jsonEncode(reminder.triggers.map((t) => t.toJson()).toList()),
      description: reminder.description,
      templateId: reminder.templateId,
      isActive: reminder.isActive,
      lastCompletedAt: reminder.lastCompletedAt,
      createdAt: reminder.createdAt ?? DateTime.now(),
      updatedAt: reminder.updatedAt ?? DateTime.now(),
      customIconCode: reminder.customIconCode,
      calendarEventId: reminder.calendarEventId,
    )..id = reminder.id == 0 ? Isar.autoIncrement : reminder.id;
  }

  RecurrenceRule _parseRecurrenceRule() {
    try {
      final map = jsonDecode(recurrenceRuleJson) as Map<String, dynamic>;
      return RecurrenceRule.fromJson(map);
    } catch (_) {
      return const RecurrenceRule.once();
    }
  }

  List<NotificationTrigger> _parseTriggers() {
    try {
      final list = jsonDecode(triggersJson) as List<dynamic>;
      return list.cast<Map<String, dynamic>>().map(NotificationTrigger.fromJson).toList();
    } catch (_) {
      return const [];
    }
  }
}
