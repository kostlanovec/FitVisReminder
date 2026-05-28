import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  const NotificationSettings({
    this.calendarSyncEnabled = false,
    this.silentMode = false,
    this.maxNotifications = 60,
    this.maxTriggersPerReminder = 10,
  });

  final bool calendarSyncEnabled;
  final bool silentMode;
  final int maxNotifications;
  final int maxTriggersPerReminder;

  NotificationSettings copyWith({
    bool? calendarSyncEnabled,
    bool? silentMode,
    int? maxNotifications,
    int? maxTriggersPerReminder,
  }) {
    return NotificationSettings(
      calendarSyncEnabled: calendarSyncEnabled ?? this.calendarSyncEnabled,
      silentMode: silentMode ?? this.silentMode,
      maxNotifications: maxNotifications ?? this.maxNotifications,
      maxTriggersPerReminder: maxTriggersPerReminder ?? this.maxTriggersPerReminder,
    );
  }

  @override
  List<Object?> get props => [calendarSyncEnabled, silentMode, maxNotifications, maxTriggersPerReminder];
}
