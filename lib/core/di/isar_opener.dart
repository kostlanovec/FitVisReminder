import 'package:isar/isar.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';

abstract class IsarOpener {
  Future<Isar> open();
}
