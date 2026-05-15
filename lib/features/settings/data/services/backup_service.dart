import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/notification_trigger.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/recurrence_rule.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:fit_vis_reminder/features/reminders/domain/entities/reminder_category.dart';
import 'package:fit_vis_reminder/features/reminders/domain/repositories/reminder_repository.dart';

class BackupService {
  BackupService(this._repository);

  final ReminderRepository _repository;

  Future<String> exportToFile() async {
    if (kIsWeb) {
      throw UnsupportedError('Export to file is not supported on web. Use JSON download instead.');
    }
    final reminders = await _repository.getAll();
    final payload = {
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'reminders': reminders.map(_toJson).toList(),
    };

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}${Platform.pathSeparator}lifetrack_backup_$timestamp.json');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
      flush: true,
    );
    return file.path;
  }

  Future<void> shareBackup({required String subject, required String text}) async {
    final path = await exportToFile();
    await Share.shareXFiles(
      [XFile(path)],
      subject: subject,
      text: text,
    );
  }

  Future<int> importFromJson(String rawJson) async {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final list = (decoded['reminders'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();

    final reminders = list.map(_fromJson).toList();
    await _repository.replaceAll(reminders);
    return reminders.length;
  }

  Map<String, dynamic> _toJson(Reminder reminder) {
    return {
      'id': reminder.id,
      'title': reminder.title,
      'category': reminder.category.name,
      'dueDate': reminder.dueDate.toIso8601String(),
      'recurrenceRule': reminder.recurrenceRule.toJson(),
      'triggers': reminder.triggers.map((t) => t.toJson()).toList(),
      'description': reminder.description,
      'templateId': reminder.templateId,
      'isActive': reminder.isActive,
      'lastCompletedAt': reminder.lastCompletedAt?.toIso8601String(),
      'createdAt': reminder.createdAt?.toIso8601String(),
      'updatedAt': reminder.updatedAt?.toIso8601String(),
      'customIconCode': reminder.customIconCode,
    };
  }

  Reminder _fromJson(Map<String, dynamic> map) {
    final recurrenceMap = (map['recurrenceRule'] as Map<String, dynamic>? ?? const {});
    final triggers = (map['triggers'] as List<dynamic>? ?? const [])
        .map((t) => NotificationTrigger.fromJson((t as Map).cast<String, dynamic>()))
        .toList();

    return Reminder(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: (map['title'] as String?)?.trim().isNotEmpty == true ? map['title'] as String : 'Reminder',
      category: _parseCategory(map['category'] as String?),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ?? DateTime.now(),
      recurrenceRule: RecurrenceRule.fromJson(recurrenceMap),
      triggers: triggers,
      description: map['description'] as String?,
      templateId: map['templateId'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      lastCompletedAt: DateTime.tryParse(map['lastCompletedAt'] as String? ?? ''),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
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

