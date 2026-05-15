import 'package:equatable/equatable.dart';

enum TriggerUnit { days, hours, minutes }

class NotificationTrigger extends Equatable {
  const NotificationTrigger({
    required this.offsetDays,
    required this.label,
    this.notificationId,
  });

  const NotificationTrigger.sameDay()
    : offsetDays = 0,
      label = 'V den události',
      notificationId = null;
  const NotificationTrigger.dayBefore()
    : offsetDays = 1,
      label = 'Den předem',
      notificationId = null;
  const NotificationTrigger.weekBefore()
    : offsetDays = 7,
      label = 'Týden předem',
      notificationId = null;
  const NotificationTrigger.monthBefore()
    : offsetDays = 30,
      label = 'Měsíc předem',
      notificationId = null;

  final int offsetDays;
  final String label;
  final int? notificationId;

  DateTime scheduledFor(DateTime eventDate) {
    final target = eventDate.subtract(Duration(days: offsetDays));
    return DateTime(target.year, target.month, target.day, 9, 0);
  }

  Map<String, dynamic> toJson() => {
    'offsetDays': offsetDays,
    'label': label,
    'notificationId': notificationId,
  };

  factory NotificationTrigger.fromJson(Map<String, dynamic> json) {
    return NotificationTrigger(
      offsetDays: json['offsetDays'] as int,
      label: json['label'] as String,
      notificationId: json['notificationId'] as int?,
    );
  }

  NotificationTrigger withId(int id) =>
      NotificationTrigger(offsetDays: offsetDays, label: label, notificationId: id);

  @override
  List<Object?> get props => [offsetDays, label, notificationId];
}
