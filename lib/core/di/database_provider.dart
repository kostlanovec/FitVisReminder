import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fit_vis_reminder/features/reminders/data/models/reminder_model.dart';

Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isEmpty) {
    return Isar.open(
      [ReminderModelSchema],
      directory: dir.path,
      name: 'life_track',
    );
  }
  return Future.value(Isar.getInstance('life_track')!);
}
