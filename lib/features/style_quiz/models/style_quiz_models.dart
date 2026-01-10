
import 'package:flutter/material.dart';

enum RoomType { living, kitchen, office, masterBedroom, kidsBedroom }

extension RoomTypeX on RoomType {
  String get key {
    switch (this) {
      case RoomType.living: return 'living';
      case RoomType.kitchen: return 'kitchen';
      case RoomType.office: return 'office';
      case RoomType.masterBedroom: return 'master_bedroom';
      case RoomType.kidsBedroom: return 'kids_bedroom';
    }
  }

  String get title {
    switch (this) {
      case RoomType.living: return 'Living Room';
      case RoomType.kitchen: return 'Kitchen';
      case RoomType.office: return 'Office';
      case RoomType.masterBedroom: return 'Master Bedroom';
      case RoomType.kidsBedroom: return 'Kids Bedroom';
    }
  }
}



class GalleryItem {
  final String imageAssetPath;
  const GalleryItem(this.imageAssetPath);
}

class StyleQuizDemoData {
  // نفس نقاط الألوان اللي بتحبيها (بيج + هادي)
  static const List<Color> palette = [
    Color(0xFFF2E6CC),
    Color(0xFFEAD7B0),
    Color(0xFFD9C39B),
    Color(0xFFC9B089),
    Color(0xFFBFA57F),
    Color(0xFFA7B08A),
    Color(0xFF8FA17C),
    Color(0xFF6D7D6B),
    Color(0xFFEAEAEA),
    Color(0xFFE0D8FF),
    Color(0xFFD6EEFF),
  ];

  static List<GalleryItem> designsFor(String styleId, RoomType roomType) {
    // عدّلي المسارات حسب صورك الموجودة (assets)
    // أهم شي: خلي الصور موجودة بالـ pubspec.yaml
    switch (roomType) {
      case RoomType.office:
        return const [
          GalleryItem('assets/office/1.jpg'),
          GalleryItem('assets/office/2.jpg'),
          GalleryItem('assets/office/3.jpg'),
          GalleryItem('assets/office/4.jpg'),
          GalleryItem('assets/office/5.jpg'),
          GalleryItem('assets/office/6.jpg'),
          GalleryItem('assets/office/7.jpg'),
          GalleryItem('assets/office/8.jpg'),
        ];
      case RoomType.living:
        return const [
          GalleryItem('assets/living/1.jpg'),
          GalleryItem('assets/living/2.jpg'),
          GalleryItem('assets/living/3.jpg'),
          GalleryItem('assets/living/4.jpg'),
        ];
      case RoomType.kitchen:
        return const [
          GalleryItem('assets/kitchen/1.jpg'),
          GalleryItem('assets/kitchen/2.jpg'),
          GalleryItem('assets/kitchen/3.jpg'),
          GalleryItem('assets/kitchen/4.jpg'),
        ];
      case RoomType.masterBedroom:
        return const [
          GalleryItem('assets/master_bedroom/1.jpg'),
          GalleryItem('assets/master_bedroom/2.jpg'),
          GalleryItem('assets/master_bedroom/3.jpg'),
          GalleryItem('assets/master_bedroom/4.jpg'),
        ];
      case RoomType.kidsBedroom:
        return const [
          GalleryItem('assets/kids_bedroom/1.jpg'),
          GalleryItem('assets/kids_bedroom/2.jpg'),
          GalleryItem('assets/kids_bedroom/3.jpg'),
          GalleryItem('assets/kids_bedroom/4.jpg'),
        ];
    }
  }
}

// Saved store (local demo)
class SavedDesignItem {
  final String title;
  final String imagePath;
  const SavedDesignItem({required this.title, required this.imagePath});
}

class StyleQuizSavedStore {
  static final List<SavedDesignItem> _items = [];

  static List<SavedDesignItem> get items => List.unmodifiable(_items);

  static void add(SavedDesignItem item) => _items.insert(0, item);
  static void removeAt(int index) => _items.removeAt(index);
}

/// الأنماط المعتمدة
enum QuizStyle { classic, modern, vintage, modernMix }

extension QuizStyleX on QuizStyle {
  String get id => name;

  String get title {
    switch (this) {
      case QuizStyle.classic:
        return 'Classic';
      case QuizStyle.modern:
        return 'Modern';
      case QuizStyle.vintage:
        return 'Vintage';
      case QuizStyle.modernMix:
        return 'Modern Mix';
    }
  }
}

/// خيار واحد داخل سؤال (صورة + لأي ستايل بتنحسب)
@immutable
class StyleQuizOption {
  final String styleId;      // classic / modern / vintage / modernMix
  final String assetPath;    // assets/quiz_rooms/1.jpg مثلا
  final String label;        // نص صغير على الصورة (اختياري)

  const StyleQuizOption({
    required this.styleId,
    required this.assetPath,
    required this.label,
  });
}

/// سؤال واحد: عنوان + نص + 5 خيارات (صور)
@immutable
class StyleQuizQuestion {
  final String id;
  final String title;     // عنوان السؤال (بيج رملي بالواجهة)
  final String subtitle;  // نص السؤال (أسود بالواجهة)
  final List<StyleQuizOption> options;

  const StyleQuizQuestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.options,
  }) : assert(options.length == 5, 'Each question must have exactly 5 options');
}

/// نتيجة الاختبار (هذا اللي كان ناقص ✅)
@immutable
class StyleQuizResult {
  final String styleId;              // modern مثلا
  final String styleTitle;           // Modern Style
  final String shortDescription;     // جملة قصيرة
  final List<String> reasons;        // نقاط التفسير
  final double confidence;           // 0.0 -> 1.0
  final String backgroundAssetPath;  // خلفية شاشة النتيجة

  const StyleQuizResult({
    required this.styleId,
    required this.styleTitle,
    required this.shortDescription,
    required this.reasons,
    required this.confidence,
    required this.backgroundAssetPath,
  });
}
