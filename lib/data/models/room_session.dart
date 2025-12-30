class RoomSession {
  final String id;
  final DateTime createdAt;

  // 4 room images paths
  final String frontPath;
  final String rightPath;
  final String leftPath;
  final String backPath;

  // optional (later)
  final String? roomType;

  RoomSession({
    required this.id,
    required this.createdAt,
    required this.frontPath,
    required this.rightPath,
    required this.leftPath,
    required this.backPath,
    this.roomType,
  });

  RoomSession copyWith({String? roomType}) {
    return RoomSession(
      id: id,
      createdAt: createdAt,
      frontPath: frontPath,
      rightPath: rightPath,
      leftPath: leftPath,
      backPath: backPath,
      roomType: roomType ?? this.roomType,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'frontPath': frontPath,
    'rightPath': rightPath,
    'leftPath': leftPath,
    'backPath': backPath,
    'roomType': roomType,
  };

  static RoomSession fromJson(Map<String, dynamic> json) {
    return RoomSession(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      frontPath: json['frontPath'] as String,
      rightPath: json['rightPath'] as String,
      leftPath: json['leftPath'] as String,
      backPath: json['backPath'] as String,
      roomType: json['roomType'] as String?,
    );
  }
}