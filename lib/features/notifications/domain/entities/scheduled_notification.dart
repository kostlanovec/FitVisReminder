import 'package:equatable/equatable.dart';

enum NotificationStatus { pending, delivered, cancelled }

class ScheduledNotification extends Equatable {
  const ScheduledNotification({
    required this.notificationId,
    required this.reminderId,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.status,
    this.channelKey = 'reminders',
  });

  final int notificationId;
  final int reminderId;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final NotificationStatus status;
  final String channelKey;

  @override
  List<Object?> get props => [notificationId, reminderId, scheduledAt];
}
