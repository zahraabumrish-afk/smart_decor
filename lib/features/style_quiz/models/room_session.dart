// room_session.dart
// Model: RoomSession
// يمثل جلسة مسار Style Quiz (المستخدم اختار ستايل + تصميم + حفظ 4 صور للغرفة)

class RoomSession {
  /// رقم داخلي في SQLite (اختياري)
  final int? id;

  /// Timestamp (millisecondsSinceEpoch) وقت إنشاء الجلسة
  final int createdAt;

  /// عنوان الستايل اللي انعرض للمستخدم (مثال: Modern Mix Style)
  final String styleTitle;

  /// مسار صورة التصميم المختارة من الـ assets
  final String designImageAssetPath;

  /// باليت ألوان بصيغة hex مخزنة كسطر واحد (CSV) داخل SQLite
  /// مثال: "#DCC7A1,#111111,#BFA78F"
  final String paletteHexCsv;

  /// مسارات الصور الأربعة (ملفات محلية) بعد ما نحفظها على الجهاز
  final String frontPath;
  final String rightPath;
  final String leftPath;
  final String backPath;

  const RoomSession({
    this.id,
    required this.createdAt,
    required this.styleTitle,
    required this.designImageAssetPath,
    required this.paletteHexCsv,
    required this.frontPath,
    required this.rightPath,
    required this.leftPath,
    required this.backPath,
  });

  /// نسخة مع تعديل بعض القيم (مفيد لما نرجع id بعد الإدخال)
  RoomSession copyWith({
    int? id,
    int? createdAt,
    String? styleTitle,
    String? designImageAssetPath,
    String? paletteHexCsv,
    String? frontPath,
    String? rightPath,
    String? leftPath,
    String? backPath,
  }) {
    return RoomSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      styleTitle: styleTitle ?? this.styleTitle,
      designImageAssetPath: designImageAssetPath ?? this.designImageAssetPath,
      paletteHexCsv: paletteHexCsv ?? this.paletteHexCsv,
      frontPath: frontPath ?? this.frontPath,
      rightPath: rightPath ?? this.rightPath,
      leftPath: leftPath ?? this.leftPath,
      backPath: backPath ?? this.backPath,
    );
  }

  /// تحويل إلى Map للحفظ في SQLite
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'created_at': createdAt,
      'style_title': styleTitle,
      'design_image_asset_path': designImageAssetPath,
      'palette_hex_csv': paletteHexCsv,
      'front_path': frontPath,
      'right_path': rightPath,
      'left_path': leftPath,
      'back_path': backPath,
    };
  }

  /// إنشاء كائن من Map قادم من SQLite
  factory RoomSession.fromMap(Map<String, Object?> map) {
    return RoomSession(
      id: (map['id'] as int?),
      createdAt: (map['created_at'] as int?) ?? 0,
      styleTitle: (map['style_title'] as String?) ?? '',
      designImageAssetPath: (map['design_image_asset_path'] as String?) ?? '',
      paletteHexCsv: (map['palette_hex_csv'] as String?) ?? '',
      frontPath: (map['front_path'] as String?) ?? '',
      rightPath: (map['right_path'] as String?) ?? '',
      leftPath: (map['left_path'] as String?) ?? '',
      backPath: (map['back_path'] as String?) ?? '',
    );
  }

  /// Helpers: تحويل List<String> (hex) إلى CSV والعكس
  static String paletteToCsv(List<String> hexList) => hexList.join(',');

  static List<String> paletteFromCsv(String csv) {
    if (csv.trim().isEmpty) return [];
    return csv.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}