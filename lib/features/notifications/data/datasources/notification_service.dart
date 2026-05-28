import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fit_vis_reminder/core/background/background_handler.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_priority.dart';

abstract interface class NotificationService {
  Future<void> initialize({
    Map<String, String>? channelNames,
    Map<String, String>? channelDescriptions,
  });
  Future<bool> requestPermission();
  Future<bool> isAllowed();
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    ReminderPriority priority = ReminderPriority.normal,
    String channelKey = 'reminders',
    Map<String, String>? payload,
    String? snoozeLabel,
    String? doneLabel,
  });
  Future<void> cancel(int id);
  Future<void> cancelAllForReminder(int reminderId);
  Future<List<NotificationModel>> listScheduled();
  Future<void> cancelAll();
  Future<void> showTestNotification({required String title, required String body});
}

class AwesomeNotificationService implements NotificationService {
  static const _channelReminders = 'reminders';
  static const _channelImportant = 'important';
  static const _channelUpcoming = 'upcoming';

  static Future<void> Function(String action, int reminderId)? _actionCallback;

  static void setActionCallback(
    Future<void> Function(String action, int reminderId) cb,
  ) {
    _actionCallback = cb;
  }

  @override
  Future<void> initialize({
    Map<String, String>? channelNames,
    Map<String, String>? channelDescriptions,
  }) async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'life_track_group',
          channelKey: _channelReminders,
          channelName: channelNames?[_channelReminders] ?? 'Reminders',
          channelDescription: channelDescriptions?[_channelReminders] ?? 'General life maintenance reminders',
          defaultColor: AppColors.primary,
          ledColor: AppColors.primary,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
        ),
        NotificationChannel(
          channelGroupKey: 'life_track_group',
          channelKey: _channelImportant,
          channelName: channelNames?[_channelImportant] ?? 'Important Deadlines',
          channelDescription: channelDescriptions?[_channelImportant] ?? 'Urgent notifications for upcoming deadlines',
          defaultColor: AppColors.accentRed,
          ledColor: AppColors.accentRed,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'life_track_group',
          channelKey: _channelUpcoming,
          channelName: channelNames?[_channelUpcoming] ?? 'Upcoming Events',
          channelDescription: channelDescriptions?[_channelUpcoming] ?? 'Information about events in the following weeks',
          defaultColor: AppColors.accent,
          ledColor: AppColors.accent,
          importance: NotificationImportance.Default,
          channelShowBadge: false,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'life_track_group',
          channelGroupName: 'LifeTrack',
        ),
      ],
      debug: false,
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceived,
      onNotificationCreatedMethod: _onNotificationCreated,
      onNotificationDisplayedMethod: _onNotificationDisplayed,
      onDismissActionReceivedMethod: _onDismissReceived,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceived(ReceivedAction action) async {
    final reminderId = int.tryParse(action.payload?['reminderId'] ?? '');
    if (reminderId == null) return;
    final key = action.buttonKeyPressed;
    if (key.isNotEmpty) {
      await _actionCallback?.call(key, reminderId);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreated(
    ReceivedNotification notification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(
    ReceivedNotification notification,
  ) async {
    // Check if there are any more alarms pending.
    // If the queue is empty, this was the last notification in the current
    // batch → schedule the next nearest batch in the background.
    final pending = await AwesomeNotifications().listScheduledNotifications();
    if (pending.isEmpty) {
      await rescheduleNextBatch();
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissReceived(ReceivedAction action) async {}

  @override
  Future<bool> requestPermission() async {
    return AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.Light,
        NotificationPermission.FullScreenIntent,
        NotificationPermission.CriticalAlert,
        NotificationPermission.PreciseAlarms,
      ],
    );
  }

  @override
  Future<bool> isAllowed() => AwesomeNotifications().isNotificationAllowed();

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    ReminderPriority priority = ReminderPriority.normal,
    String channelKey = _channelReminders,
    Map<String, String>? payload,
    String? snoozeLabel,
    String? doneLabel,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) return;

    // Silently skip if the user hasn't granted notification permission yet.
    // The reminder is already saved to the database; notifications can be
    // (re)scheduled later once permission is granted.
    if (!await isAllowed()) return;

    final isHigh = priority == ReminderPriority.high;
    final channel = isHigh ? _channelImportant : _selectChannel(scheduledAt);

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channel,
          title: title,
          body: body,
          payload: payload,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledAt,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: doneLabel ?? (isHigh ? 'Understand ✓' : 'Done'),
            actionType: ActionType.SilentAction,
            enabled: true,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: snoozeLabel ?? 'Snooze',
            actionType: ActionType.SilentAction,
            enabled: true,
            autoDismissible: true,
          ),
        ],
      );
    } catch (_) {
      // Fallback: schedule as inexact alarm if precise alarms are blocked by the OS
      try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: channel,
          title: title,
          body: body,
          payload: payload,
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(
          date: scheduledAt,
          preciseAlarm: false,
          allowWhileIdle: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'MARK_DONE',
            label: doneLabel ?? (isHigh ? 'Understand ✓' : 'Done'),
            actionType: ActionType.SilentAction,
            enabled: true,
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'SNOOZE',
            label: snoozeLabel ?? 'Snooze',
            actionType: ActionType.SilentAction,
            enabled: true,
            autoDismissible: true,
          ),
        ],
      );
      } catch (_) {
        // Inexact alarm also failed — notifications unavailable, ignore.
      }
    }
  }

  String _selectChannel(DateTime scheduledAt) {
    final daysUntil = scheduledAt.difference(DateTime.now()).inDays;
    if (daysUntil <= 1) return _channelImportant;
    if (daysUntil <= 7) return _channelReminders;
    return _channelUpcoming;
  }

  @override
  Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  @override
  Future<void> cancelAllForReminder(int reminderId) async {
    final scheduled = await AwesomeNotifications().listScheduledNotifications();
    for (final n in scheduled) {
      final payload = n.content?.payload;
      if (payload != null && payload['reminderId'] == reminderId.toString()) {
        await AwesomeNotifications().cancel(n.content!.id!);
      }
    }
  }

  @override
  Future<List<NotificationModel>> listScheduled() {
    return AwesomeNotifications().listScheduledNotifications();
  }

  @override
  Future<void> cancelAll() => AwesomeNotifications().cancelAll();

  @override
  Future<void> showTestNotification({required String title, required String body}) async {
    if (!await isAllowed()) return;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999999, // Fixed positive ID reserved for test notifications
        channelKey: _channelImportant,
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
        wakeUpScreen: true,
        autoDismissible: true,
      ),
    );
  }
}

class WebNotificationService implements NotificationService {
  @override
  Future<void> initialize({
    Map<String, String>? channelNames,
    Map<String, String>? channelDescriptions,
  }) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> isAllowed() async => true;

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    ReminderPriority priority = ReminderPriority.normal,
    String channelKey = 'reminders',
    Map<String, String>? payload,
    String? snoozeLabel,
    String? doneLabel,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAllForReminder(int reminderId) async {}

  @override
  Future<List<NotificationModel>> listScheduled() async => [];

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> showTestNotification({required String title, required String body}) async {}
}
