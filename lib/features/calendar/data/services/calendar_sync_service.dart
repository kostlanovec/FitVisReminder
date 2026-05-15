import 'package:device_calendar/device_calendar.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

final calendarSyncServiceProvider = Provider((ref) => CalendarSyncService());

class CalendarSyncService {
  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  static const String calendarName = 'FitVis Reminders';

  Future<bool> requestPermissions() async {
    final status = await Permission.calendarFullAccess.request();
    return status.isGranted;
  }

  Future<String?> syncReminder(Reminder reminder) async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) return null;

    final calendarId = await _getOrCreateCalendarId();
    if (calendarId == null) return null;

    final event = Event(
      calendarId,
      eventId: reminder.calendarEventId,
      title: '${reminder.category.emoji} ${reminder.title}',
      description: reminder.description ?? '',
      start: tz.TZDateTime.from(reminder.dueDate, tz.local),
      end: tz.TZDateTime.from(reminder.dueDate.add(const Duration(hours: 1)), tz.local),
      allDay: false,
    );

    final result = await _plugin.createOrUpdateEvent(event);
    if (result != null && result.isSuccess) {
      return result.data;
    }
    return null;
  }

  Future<void> deleteEvent(String calendarId, String eventId) async {
    await _plugin.deleteEvent(calendarId, eventId);
  }

  Future<String?> _getOrCreateCalendarId() async {
    final calendarsResult = await _plugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null) {
      final existing = calendarsResult.data!.where((c) => c.name == calendarName);
      if (existing.isNotEmpty) {
        return existing.first.id;
      }
    }

    final createResult = await _plugin.createCalendar(
      calendarName,
      calendarColor: 0xFF6366F1, // AppColors.primary
      localAccountName: 'FitVis',
    );

    if (createResult.isSuccess) {
      return createResult.data;
    }
    return null;
  }
}
