import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

/// مسؤول عن فتح قاعدة البيانات + إنشاء الجداول
class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<Database> get database async {
    final db = _db;
    if (db != null) return db;

    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, Tables.dbName);

    return openDatabase(
      dbPath,
      version: Tables.dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE ${Tables.roomSessions} (
  ${Tables.cId} TEXT PRIMARY KEY,
  ${Tables.cStyleId} TEXT NOT NULL,
  ${Tables.cStyleTitle} TEXT NOT NULL,
  ${Tables.cDesignImageAssetPath} TEXT NOT NULL,
  ${Tables.cPaletteHexJson} TEXT NOT NULL,
  ${Tables.cFrontPath} TEXT,
  ${Tables.cRightPath} TEXT,
  ${Tables.cLeftPath} TEXT,
  ${Tables.cBackPath} TEXT,
  ${Tables.cCreatedAt} INTEGER NOT NULL,
  ${Tables.cUpdatedAt} INTEGER NOT NULL
)
''');
      },
    );
  }
}