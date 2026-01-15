import 'dart:convert';
import 'dart:typed_data';

/// موديل طلب الديكور لمسار Design Request
/// - prompt: نص طلب المستخدم
/// - imagePath: مسار الصورة (موبايل)
/// - imageBytesBase64: بايتات الصورة (للويب) محفوظة كنص Base64
/// - createdAt: وقت الإنشاء
class DesignRequestModel {
  final int? id;
  final String prompt;
  final String? imagePath;
  final String? imageBytesBase64;
  final DateTime createdAt;

  const DesignRequestModel({
    this.id,
    required this.prompt,
    required this.imagePath,
    required this.imageBytesBase64,
    required this.createdAt,
  });

  /// للويب: نحول Uint8List إلى Base64 للتخزين كنص
  static String? bytesToBase64(Uint8List? bytes) {
    if (bytes == null) return null;
    return base64Encode(bytes);
  }

  /// للويب: نرجّع Base64 إلى Uint8List عند الحاجة
  static Uint8List? base64ToBytes(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    return base64Decode(b64);
  }

  DesignRequestModel copyWith({
    int? id,
    String? prompt,
    String? imagePath,
    String? imageBytesBase64,
    DateTime? createdAt,
  }) {
    return DesignRequestModel(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      imagePath: imagePath ?? this.imagePath,
      imageBytesBase64: imageBytesBase64 ?? this.imageBytesBase64,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'prompt': prompt,
      'image_path': imagePath,
      'image_bytes_b64': imageBytesBase64,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DesignRequestModel.fromMap(Map<String, dynamic> map) {
    return DesignRequestModel(
      id: map['id'] as int?,
      prompt: (map['prompt'] ?? '') as String,
      imagePath: map['image_path'] as String?,
      imageBytesBase64: map['image_bytes_b64'] as String?,
      createdAt: DateTime.tryParse((map['created_at'] ?? '') as String) ?? DateTime.now(),
    );
  }
}