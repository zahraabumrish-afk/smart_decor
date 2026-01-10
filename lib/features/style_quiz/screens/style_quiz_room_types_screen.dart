import 'package:flutter/material.dart';
import 'style_quiz_gallery_screen.dart';

enum RoomType { living, kitchen, office, master, kids }

extension RoomTypeX on RoomType {
  String get key {
    switch (this) {
      case RoomType.living:
        return 'living';
      case RoomType.kitchen:
        return 'kitchen';
      case RoomType.office:
        return 'office';
      case RoomType.master:
        return 'master';
      case RoomType.kids:
        return 'kids';
    }
  }

  String get title {
    switch (this) {
      case RoomType.living:
        return 'Living Room';
      case RoomType.kitchen:
        return 'Kitchen';
      case RoomType.office:
        return 'Office';
      case RoomType.master:
        return 'Master Bedroom';
      case RoomType.kids:
        return 'Kids Bedroom';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomType.living:
        return Icons.weekend_outlined;
      case RoomType.kitchen:
        return Icons.kitchen_outlined;
      case RoomType.office:
        return Icons.chair_alt_outlined;
      case RoomType.master:
        return Icons.bed_outlined;
      case RoomType.kids:
        return Icons.child_friendly_outlined;
    }
  }
}

class StyleQuizRoomTypesScreen extends StatelessWidget {
  final String styleId;
  final String styleTitle;
  final String backgroundAssetPath;

  const StyleQuizRoomTypesScreen({
    super.key,
    required this.styleId,
    required this.styleTitle,
    required this.backgroundAssetPath,
  });

  static const Color _sandBeige = Color(0xFFDCC7A1);
  static const Color _darkText = Color(0xFF1F1A14);

  void _openGallery(BuildContext context, RoomType roomType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StyleQuizGalleryScreen(
          styleId: styleId,
          styleTitle: styleTitle,
          roomType: roomType,
          backgroundAssetPath: backgroundAssetPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = RoomType.values;

    return Scaffold(
      body: Stack(
        children: [
      Positioned.fill(
      child: Image.asset(
        backgroundAssetPath,
        fit: BoxFit.cover,
      ),
    ),

    Positioned.fill(
    child: Container(
    color: Colors.black.withOpacity(0.10),
    ),
    ),

    SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(14),
    child: Column(
    children: [
    Align(
    alignment: Alignment.centerLeft,
    child: _BackPill(onTap: () => Navigator.pop(context)),
    ),

    const SizedBox(height: 18),

    Text(
    '$styleTitle Style Rooms',
    textAlign: TextAlign.center,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    ),
    ),

    const SizedBox(height: 6),

    Text(
    'Choose Room Type',
    style: TextStyle(
    color: Colors.white.withOpacity(0.95),
    fontSize: 18,
    fontWeight: FontWeight.w500,
    ),
    ),

    // ⬇️⬇️⬇️ هذا السطر فقط نزل الأزرار ⬇️⬇️⬇️
    const SizedBox(height: 75),

    Center(
    child: SizedBox(
    width: 500,
    child: Column(
    children: rooms.map((r) {
    return Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: () => _openGallery(context, r),child: Container(
      height: 38,
      padding:
      const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _sandBeige.withOpacity(0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Icon(
            r.icon,
            color: _darkText,
            size: 30, // ⬅️ أصغر فقط
          ),
          const SizedBox(width: 10),
          Text(
            r.title,
            style: const TextStyle(
              color: _darkText,
              fontSize: 15, // ⬅️ أصغر فقط
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
    ),
    );
    }).toList(),
    ),
    ),
    ),

      const Spacer(),
    ],
    ),
    ),
    ),
        ],
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  const _BackPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 15),
            SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}