import 'package:isar/isar.dart';
import 'isar_opener.dart';
import 'isar_opener_io.dart'
    if (dart.library.html) 'isar_opener_web.dart'
    if (dart.library.js_interop) 'isar_opener_web.dart';

Future<Isar> openIsar() async {
  final opener = getOpener();
  return opener.open();
}
