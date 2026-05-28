import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';

class SharingService {
  static const String fileExtension = 'fvr'; // FitVis Reminder

  Future<void> shareReminders(List<Reminder> reminders, {String? subject}) async {
    if (kIsWeb) return;

    final payload = {
      'schemaType': 'share',
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'reminders': reminders.map(_toJson).toList(),
    };

    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = reminders.length == 1 
        ? '${reminders.first.title.replaceAll(RegExp(r'[^\w\s]+'), '')}. $fileExtension'
        : 'shared_reminders_$timestamp.$fileExtension';
    
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    await file.writeAsString(jsonEncode(payload), flush: true);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject ?? 'Sdílené připomínky FitVis',
    );
  }

  List<Reminder> parseSharedFile(String content) {
    final decoded = jsonDecode(content) as Map<String, dynamic>;
    if (decoded['schemaType'] != 'share') {
      throw const FormatException('Neplatný formát souboru pro sdílení.');
    }
    
    final list = (decoded['reminders'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    return list.map(_fromJson).toList();
  }

  Map<String, dynamic> _toJson(Reminder reminder) {
    return {
      'title': reminder.title,
      'category': reminder.category.name,
      'dueDate': reminder.dueDate.toIso8601String(),
      'recurrenceRule': reminder.recurrenceRule.toJson(),
      'triggers': reminder.triggers.map((t) => t.toJson()).toList(),
      'description': reminder.description,
      'templateId': reminder.templateId,
      'priority': reminder.priority.name,
      'customIconCode': reminder.customIconCode,
    };
  }

  Reminder _fromJson(Map<String, dynamic> map) {
    return Reminder(
      id: 0, // Will be auto-incremented on save
      title: map['title'] as String? ?? 'Připomínka',
      category: _parseCategory(map['category'] as String?),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ?? DateTime.now(),
      recurrenceRule: RecurrenceRule.fromJson((map['recurrenceRule'] as Map? ?? const {}).cast<String, dynamic>()),
      triggers: (map['triggers'] as List? ?? const [])
          .map((t) => NotificationTrigger.fromJson((t as Map).cast<String, dynamic>()))
          .toList(),
      description: map['description'] as String?,
      templateId: map['templateId'] as String?,
      isActive: true,
      customIconCode: (map['customIconCode'] as num?)?.toInt(),
    );
  }

  ReminderCategory _parseCategory(String? name) {
    if (name == null) return ReminderCategory.custom;
    return ReminderCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ReminderCategory.custom,
    );
  }
}
