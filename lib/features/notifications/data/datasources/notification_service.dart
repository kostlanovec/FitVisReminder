import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fit_vis_reminder/core/theme/app_theme.dart';

abstract interface class NotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<bool> isAllowed();
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String channelKey = 'reminders',
    Map<String, String>? payload,
  });
  Future<void> cancel(int id);
  Future<void> cancelAllForReminder(int reminderId);
  Future<List<NotificationModel>> listScheduled();
  Future<void> cancelAll();
}

class AwesomeNotificationService implements NotificationService {
  static const _channelReminders = 'reminders';
  static const _channelImportant = 'important';
  static const _channelUpcoming = 'upcoming';

  // Registered from main.dart after ProviderContainer is ready
  static Future<void> Function(String action, int reminderId)? _actionCallback;
  static void setActionCallback(Future<void> Function(String action, int reminderId) cb) {
    _actionCallback = cb;
  }

  @override
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'life_track_group',
          channelKey: _channelReminders,
          channelName: 'Připomínky',
          channelDescription: 'Obecné připomínky životní údržby',
          defaultColor: AppColors.primary,
          ledColor: AppColors.primary,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          soundSource: null,
        ),
        NotificationChannel(
          channelGroupKey: 'life_track_group',
          channelKey: _channelImportant,
          channelName: 'Důležité termíny',
          channelDescription: 'Upozornění na blížící se důležité termíny',
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
          channelName: 'Nadcházející události',
          channelDescription: 'Informace o událostech v dalších týdnech',
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
  static Future<void> _onNotificationCreated(ReceivedNotification notification) async {}

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayed(ReceivedNotification notification) async {}

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
    String channelKey = _channelReminders,
    Map<String, String>? payload,
  }) async {
    if (scheduledAt.isBefore(DateTime.now())) return;

    final channel = _selectChannel(scheduledAt);

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
          label: 'Hotovo ✓',
          actionType: ActionType.SilentAction,
        ),
        NotificationActionButton(
          key: 'SNOOZE',
          label: 'Odložit',
          actionType: ActionType.SilentAction,
        ),
      ],
    );
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
}
