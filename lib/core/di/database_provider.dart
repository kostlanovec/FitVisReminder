import 'package:fit_vis_reminder/core/database/app_database.dart';

export 'package:fit_vis_reminder/core/database/app_database.dart'
    show AppDatabase;

/// Creates (lazily) the Drift SQLite database.
/// On non-web platforms this is called once in main() and the instance is
/// passed via [databaseProvider] override.
AppDatabase openDatabase() => AppDatabase();
