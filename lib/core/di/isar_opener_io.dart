import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';
import 'isar_opener.dart';

class IsarOpenerImpl implements IsarOpener {
  @override
  Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return Isar.open(
        [ReminderDataSchema],
        directory: dir.path,
        name: 'life_track',
      );
    }
    return Isar.getInstance('life_track')!;
  }
}

IsarOpener getOpener() => IsarOpenerImpl();
