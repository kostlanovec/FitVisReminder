import 'package:equatable/equatable.dart';

enum NotificationTriggerType { atTime, beforeDue, custom, byOffset }

class NotificationTrigger extends Equatable {
  const NotificationTrigger({
    this.offsetDays = 0,
    this.label,
    this.minutesBefore,
    this.customTime,
  }) : type = NotificationTriggerType.byOffset;

  const NotificationTrigger.atDueTime()
      : type = NotificationTriggerType.atTime,
        offsetDays = 0,
        label = null,
        minutesBefore = null,
        customTime = null;

  const NotificationTrigger.minutesBefore(int minutes)
      : type = NotificationTriggerType.beforeDue,
        offsetDays = 0,
        label = null,
        minutesBefore = minutes,
        customTime = null;

  const NotificationTrigger.dayBefore()
      : type = NotificationTriggerType.beforeDue,
        offsetDays = 1,
        label = '1 den předem',
        minutesBefore = 24 * 60,
        customTime = null;

  const NotificationTrigger.weekBefore()
      : type = NotificationTriggerType.beforeDue,
        offsetDays = 7,
        label = '1 týden předem',
        minutesBefore = 7 * 24 * 60,
        customTime = null;

  const NotificationTrigger.monthBefore()
      : type = NotificationTriggerType.beforeDue,
        offsetDays = 30,
        label = '1 měsíc předem',
        minutesBefore = 30 * 24 * 60,
        customTime = null;

  const NotificationTrigger.sameDay()
      : type = NotificationTriggerType.atTime,
        offsetDays = 0,
        label = null,
        minutesBefore = 0,
        customTime = null;

  final NotificationTriggerType type;
  final int offsetDays;
  final String? label;
  final int? minutesBefore;
  final String? customTime;

  DateTime scheduledFor(DateTime eventDate) {
    return eventDate.subtract(Duration(days: offsetDays));
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'offsetDays': offsetDays,
    'label': label,
    'minutesBefore': minutesBefore,
    'customTime': customTime,
  };

  factory NotificationTrigger.fromJson(Map<String, dynamic> json) {
    final offsetDays = json['offsetDays'] as int? ?? 0;
    final label = json['label'] as String?;
    
    return NotificationTrigger(
      offsetDays: offsetDays,
      label: label,
      minutesBefore: json['minutesBefore'] as int?,
      customTime: json['customTime'] as String?,
    );
  }

  @override
  List<Object?> get props => [type, offsetDays, label, minutesBefore, customTime];
}
