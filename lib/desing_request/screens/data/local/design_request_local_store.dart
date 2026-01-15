import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/design_request_model.dart';

/// تخزين محلي لمسار Design Request
/// ✅ على الموبايل: SQLite (حفظ دائم)
/// ⚠️ على الويب: In-Memory (لأن sqflite لا يدعم Web مباشرة)
class DesignRequestLocalStore {
  DesignRequestLocalStore._();
  static final DesignRequestLocalStore instance = DesignRequestLocalStore._();

  static const String _dbName = 'smart_decor.db';
  static const String _table = 'design_requests';

  Database? _db;

  // -------- Web fallback (In-Memory) --------
  final List<DesignRequestModel> _webCache = [];
  int _webAutoId = 1;

  Future<void> init() async {
    if (kIsWeb) return; // ✅ ويب: ما في db
    if (_db != null) return;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbName);

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $_table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prompt TEXT NOT NULL,
            image_path TEXT,
            image_bytes_b64 TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertRequest(DesignRequestModel model) async {
    if (kIsWeb) {
      final saved = model.copyWith(id: _webAutoId++);
      _webCache.insert(0, saved);
      return saved.id!;
    }

    await init();
    final db = _db!;
    final id = await db.insert(
      _table,
      model.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<DesignRequestModel>> getAllRequests() async {
    if (kIsWeb) return List<DesignRequestModel>.from(_webCache);

    await init();
    final db = _db!;
    final rows = await db.query(
      _table,
      orderBy: 'created_at DESC',
    );
    return rows.map(DesignRequestModel.fromMap).toList();
  }

  Future<void> deleteRequest(int id) async {
    if (kIsWeb) {
      _webCache.removeWhere((e) => e.id == id);
      return;
    }

    await init();
    final db = _db!;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      _webCache.clear();
      return;
    }

    await init();
    final db = _db!;
    await db.delete(_table);
  }
}