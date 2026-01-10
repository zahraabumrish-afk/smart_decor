/// ثابتات أسماء الجداول والأعمدة (حتى ما نغلط بالكتابة)
class Tables {
  static const String dbName = 'style_quiz.db';
  static const int dbVersion = 1;

  // Table: room_sessions
  static const String roomSessions = 'room_sessions';

  static const String cId = 'id';
  static const String cStyleId = 'style_id';
  static const String cStyleTitle = 'style_title';
  static const String cDesignImageAssetPath = 'design_image_asset_path';
  static const String cPaletteHexJson = 'palette_hex_json';

  // paths for photos saved as files
  static const String cFrontPath = 'front_path';
  static const String cRightPath = 'right_path';
  static const String cLeftPath = 'left_path';
  static const String cBackPath = 'back_path';

  static const String cCreatedAt = 'created_at';
  static const String cUpdatedAt = 'updated_at';
}