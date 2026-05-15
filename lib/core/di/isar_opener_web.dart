import 'package:isar/isar.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';
import 'isar_opener.dart';

class IsarOpenerImpl implements IsarOpener {
  @override
  Future<Isar> open() async {
    if (Isar.instanceNames.isEmpty) {
      return Isar.open(
        [ReminderDataSchema],
        directory: '', // Ignored on web
        name: 'life_track',
      );
    }
    return Isar.getInstance('life_track')!;
  }
}

IsarOpener getOpener() => IsarOpenerImpl();
