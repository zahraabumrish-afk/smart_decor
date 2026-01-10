// local_files_store.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// ✅ LocalFilesStore
/// مسؤول عن حفظ/حذف صور الغرفة على الجهاز ضمن مجلد خاص لكل Session:
/// documents/smart_decor/style_quiz/<sessionId>/front.jpg ..الخ
///
/// مهم:
/// - لا يعمل على Web (Chrome). لازم Android/iOS.
class LocalFilesStore {
  /// مجلد الجذر للمسار
  static const String _rootFolder = 'smart_decor/style_quiz';

  void _ensureNotWeb() {
    if (kIsWeb) {
      throw UnsupportedError(
        'Local file storage is not supported on Flutter Web. Run on Android/iOS.',
      );
    }
  }

  /// يرجع مجلد session جاهز (ويعمله إذا مو موجود)
  Future<Directory> _sessionDir(String sessionId) async {
    _ensureNotWeb();

    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _rootFolder, sessionId));

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// ✅ حفظ صورة زاوية (front/right/left/back) كملف
  /// ويرجع مسار الملف الكامل.
  Future<String> savePhoto({
    required String sessionId,
    required String angleKey, // 'front'/'right'/'left'/'back'
    required Uint8List bytes,
  }) async {
    _ensureNotWeb();

    final dir = await _sessionDir(sessionId);

    // اسم الملف ثابت لكل زاوية (بيستبدل إذا المستخدم غير الصورة)
    final fileName = '$angleKey.jpg';
    final filePath = p.join(dir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);

    return filePath;
  }

  /// ✅ حذف مجلد Session بالكامل (مع الصور)
  Future<void> deleteSessionFolder(String sessionId) async {
    _ensureNotWeb();

    final dir = await _sessionDir(sessionId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// ✅ هل الملف موجود فعلاً؟
  Future<bool> exists(String filePath) async {
    _ensureNotWeb();
    return File(filePath).exists();
  }
}