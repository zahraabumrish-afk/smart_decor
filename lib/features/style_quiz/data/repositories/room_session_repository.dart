import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;

import '../db/app_db.dart';
import '../db/tables.dart';
import '../store/local_files_store.dart';

/// ✅ Repository لمسار Style Quiz (مسار 2)
/// - يخزن "جلسة" Session داخل SQLite (Metadata: ستايل/عنوان/صورة تصميم/باليت…)
/// - ويخزن صور الغرفة كـ ملفات (front/right/left/back) ويربط مساراتها داخل SQLite
///
/// مهم:
/// - SQLite (sqflite) لا يعمل على Chrome Web.
/// - شغّلي Android/iOS لتجربة الباك.
class RoomSessionRepository {
  RoomSessionRepository({
    AppDb? db,
    LocalFilesStore? filesStore,
  })  : _db = db ?? AppDb.instance,
        _files = filesStore ?? LocalFilesStore();

  final AppDb _db;
  final LocalFilesStore _files;

  // =========================
  // Helpers
  // =========================

  void _ensureNotWeb() {
    if (kIsWeb) {
      throw UnsupportedError(
        'sqflite does not support Flutter Web. Run on Android/iOS for DB features.',
      );
    }
  }

  String _newId() {
    final ms = DateTime.now().millisecondsSinceEpoch;
    final r = Random().nextInt(1 << 32);
    return 'sess_${ms}_$r';
  }

  int _now() => DateTime.now().millisecondsSinceEpoch;

  // =========================
  // Session CRUD
  // =========================

  /// ✅ إنشاء Session جديدة (قبل رفع صور الغرفة أو بعده)
  /// ترجع sessionId لنستخدمه بباقي العمليات.
  Future<String> createSession({
    required String styleId,
    required String styleTitle,
    required String designImageAssetPath,
    required List<String> paletteHex,
  }) async {
    _ensureNotWeb();

    final db = await _db.database;
    final id = _newId();
    final t = _now();

    await db.insert(
      Tables.roomSessions,
      {
        Tables.cId: id,
        Tables.cStyleId: styleId,
        Tables.cStyleTitle: styleTitle,
        Tables.cDesignImageAssetPath: designImageAssetPath,
        Tables.cPaletteHexJson: jsonEncode(paletteHex),

        // مسارات الصور بتكون فاضية بالبداية
        Tables.cFrontPath: null,
        Tables.cRightPath: null,
        Tables.cLeftPath: null,
        Tables.cBackPath: null,

        Tables.cCreatedAt: t,
        Tables.cUpdatedAt: t,
      },
    );

    return id;
  }

  /// ✅ جلب Session حسب id
  Future<RoomSession?> getById(String id) async {
    _ensureNotWeb();

    final db = await _db.database;
    final rows = await db.query(
      Tables.roomSessions,
      where: '${Tables.cId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return RoomSession.fromMap(rows.first);
  }

  /// ✅ آخر Session (الأحدث) — مفيد لو بدك ترجع لآخر جلسة محفوظة
  Future<RoomSession?> getLatest() async {
    _ensureNotWeb();

    final db = await _db.database;
    final rows = await db.query(
      Tables.roomSessions,
      orderBy: '${Tables.cUpdatedAt} DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return RoomSession.fromMap(rows.first);
  }

  /// ✅ حذف Session + حذف مجلد صورها
  Future<void> deleteSession(String id) async {
    _ensureNotWeb();

    final db = await _db.database;
    await db.delete(
      Tables.roomSessions,
      where: '${Tables.cId} = ?',
      whereArgs: [id],
    );

    // حذف ملفات الصور من الجهاز
    await _files.deleteSessionFolder(id);
  }

  // =========================
  // Room Photos (front/right/left/back)
  // =========================

  /// ✅ حفظ صورة زاوية (front/right/left/back)
  /// - تخزنها كملف داخل Documents
  /// - تحفظ مسارها داخل SQLite
  ///
  /// angleKey لازم يكون واحد من:
  /// 'front' , 'right' , 'left' , 'back'
  Future<void> saveAnglePhoto({
    required String sessionId,
    required String angleKey,
    required Uint8List bytes,
  }) async {
    _ensureNotWeb();

    // 1) خزّنيها كملف
    final filePath = await _files.savePhoto(
      sessionId: sessionId,
      angleKey: angleKey,
      bytes: bytes,
    );

    // 2) حدّثي الـ DB بالمسار المناسب
    final db = await _db.database;

    final column = switch (angleKey) {
      'front' => Tables.cFrontPath,'right' => Tables.cRightPath,
      'left' => Tables.cLeftPath,
      'back' => Tables.cBackPath,
      _ => throw ArgumentError('Invalid angleKey: $angleKey'),
    };

    await db.update(
      Tables.roomSessions,
      {
        column: filePath,
        Tables.cUpdatedAt: _now(),
      },
      where: '${Tables.cId} = ?',
      whereArgs: [sessionId],
    );
  }

  /// ✅ فحص هل الصور الأربعة موجودة (مساراتها محفوظة)
  Future<bool> hasAllRoomPhotos(String sessionId) async {
    final s = await getById(sessionId);
    if (s == null) return false;

    return (s.frontPath != null && s.frontPath!.isNotEmpty) &&
        (s.rightPath != null && s.rightPath!.isNotEmpty) &&
        (s.leftPath != null && s.leftPath!.isNotEmpty) &&
        (s.backPath != null && s.backPath!.isNotEmpty);
  }
}

/// ✅ Model بسيط للـ Session (ضمن نفس الملف لتفادي إنشاء ملفات إضافية)
class RoomSession {
  final String id;
  final String styleId;
  final String styleTitle;
  final String designImageAssetPath;
  final List<String> paletteHex;

  final String? frontPath;
  final String? rightPath;
  final String? leftPath;
  final String? backPath;

  final int createdAt;
  final int updatedAt;

  const RoomSession({
    required this.id,
    required this.styleId,
    required this.styleTitle,
    required this.designImageAssetPath,
    required this.paletteHex,
    required this.frontPath,
    required this.rightPath,
    required this.leftPath,
    required this.backPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RoomSession.fromMap(Map<String, Object?> m) {
    final paletteJson = (m[Tables.cPaletteHexJson] as String?) ?? '[]';
    final decoded = jsonDecode(paletteJson);
    final palette = (decoded is List)
        ? decoded.map((e) => e.toString()).toList()
        : <String>[];

    return RoomSession(
      id: (m[Tables.cId] as String),
      styleId: (m[Tables.cStyleId] as String),
      styleTitle: (m[Tables.cStyleTitle] as String),
      designImageAssetPath: (m[Tables.cDesignImageAssetPath] as String),
      paletteHex: palette,

      frontPath: m[Tables.cFrontPath] as String?,
      rightPath: m[Tables.cRightPath] as String?,
      leftPath: m[Tables.cLeftPath] as String?,
      backPath: m[Tables.cBackPath] as String?,

      createdAt: (m[Tables.cCreatedAt] as int),
      updatedAt: (m[Tables.cUpdatedAt] as int),
    );
  }
}