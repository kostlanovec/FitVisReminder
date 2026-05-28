import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final widgetServiceProvider = Provider((ref) => WidgetService());

class WidgetService {
  static const String androidWidgetName = 'FitVisWidgetProvider';
  static const String appGroupId = 'group.fit_vis_reminder';

  Future<void> updateWidget(List<Reminder> activeReminders) async {
    if (kIsWeb) return;

    try {
      if (activeReminders.isEmpty) {
        await HomeWidget.saveWidgetData('next_title', '');
        await HomeWidget.saveWidgetData('next_date', '');
        await HomeWidget.saveWidgetData('next_category', '');
        await HomeWidget.saveWidgetData('overdue_count', 0);
      } else {
        activeReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final next = activeReminders.first;
        final overdue = activeReminders.where((r) => r.isOverdue).length;

        await HomeWidget.saveWidgetData('next_title', next.title);
        await HomeWidget.saveWidgetData('next_date', DateFormat('d. M. H:mm').format(next.dueDate));
        await HomeWidget.saveWidgetData('next_category', '${next.category.emoji} ${next.category.label}');
        await HomeWidget.saveWidgetData('overdue_count', overdue);
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: 'FitVisWidget',
      );
    } catch (_) {
      // Home widget not configured on this device — silently ignore.
    }
  }

  Future<void> syncReminders(List<Reminder> reminders) => updateWidget(reminders);
}
