import '../models/style_quiz_models.dart';

class StyleQuizData {
  /// 5 أسئلة — كل سؤال: عنوان + نص + 5 صور (اختيار واحد)
  static final List<StyleQuizQuestion> questions = [
  // 1) Rooms
  StyleQuizQuestion(
  id: 'q_rooms',
  title: 'Rooms vibe',
  subtitle: 'Pick the room vibe you feel closest to.',
  options: const [
  StyleQuizOption(
  styleId: 'classic',
  assetPath: 'assets/quiz_rooms/1.jpg',
  label: 'Classic',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_rooms/2.jpg',
  label: 'Modern',
  ),
  StyleQuizOption(
  styleId: 'vintage',
  assetPath: 'assets/quiz_rooms/3.jpg',
  label: 'Vintage',
  ),
  StyleQuizOption(
  styleId: 'modernMix',
  assetPath: 'assets/quiz_rooms/4.jpg',
  label: 'Modern_ Mix',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_rooms/5.jpg',
  label: 'Minimal',
  ),
  ],
  ),

  // 2) Colors
  StyleQuizQuestion(
  id: 'q_colors',
  title: 'Colors mood',
  subtitle: 'Pick the color mood you love.',
  options: const [
  StyleQuizOption(
  styleId: 'classic',
  assetPath: 'assets/quiz_colors/1.jpg',
  label: 'Neutrals',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_colors/2.jpg',
  label: 'Warm',
  ),
  StyleQuizOption(
  styleId: 'vintage',
  assetPath: 'assets/quiz_colors/3.jpg',
  label: 'Earthy',
  ),
  StyleQuizOption(
  styleId: 'modern_Mix',
  assetPath: 'assets/quiz_colors/4.jpg',
  label: 'Soft mix',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_colors/5.jpg',
  label: 'Contrast',
  ),
  ],
  ),

  // 3) Furniture
  StyleQuizQuestion(
  id: 'q_furniture',
  title: 'Furniture taste',
  subtitle: 'Choose the furniture style you prefer.',
  options: const [
  StyleQuizOption(
  styleId: 'classic',
  assetPath: 'assets/quiz_furniture/1.jpg',
  label: 'Classic',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_furniture/2.jpg',
  label: 'Modern',
  ),
  StyleQuizOption(
  styleId: 'vintage',
  assetPath: 'assets/quiz_furniture/3.jpg',
  label: 'Vintage',
  ),
  StyleQuizOption(
  styleId: 'modern_Mix',
  assetPath: 'assets/quiz_furniture/4.jpg',
  label: 'Modern_ Mix',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_furniture/5.jpg',
  label: 'Simple',
  ),
  ],
  ),

  // 4) Lighting
  StyleQuizQuestion(
  id: 'q_lighting',
  title: 'Lighting vibe',
  subtitle: 'Pick the lighting you feel fits you.',
  options: const [
  StyleQuizOption(
  styleId: 'classic',
  assetPath: 'assets/quiz_lighting/1.jpg',
  label: 'Warm',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_lighting/2.jpg',
  label: 'Modern',
  ),
  StyleQuizOption(
  styleId: 'vintage',
  assetPath: 'assets/quiz_lighting/3.jpg',
  label: 'Vintage',
  ),
  StyleQuizOption(
  styleId: 'modernMix',
  assetPath: 'assets/quiz_lighting/4.jpg',
  label: 'Mixed',
  ),
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_lighting/5.jpg',
  label: 'Minimal',
  ),
  ],
  ),

  // 5) Feel (بحر/جبل/صحراء/طبيعة…)
  StyleQuizQuestion(
  id: 'q_feel',
  title: 'Your vibe',
  subtitle: 'Which place feels most like you?',
  options: const [
  StyleQuizOption(
  styleId: 'modern',
  assetPath: 'assets/quiz_feel/1.jpg',label: 'Sea',
  ),
    StyleQuizOption(
      styleId: 'classic',
      assetPath: 'assets/quiz_feel/2.jpg',
      label: 'Mountains',
    ),
    StyleQuizOption(
      styleId: 'vintage',
      assetPath: 'assets/quiz_feel/3.jpg',
      label: 'Desert',
    ),
    StyleQuizOption(
      styleId: 'modern_Mix',
      assetPath: 'assets/quiz_feel/4.jpg',
      label: 'Nature',
    ),
    StyleQuizOption(
      styleId: 'modern',
      assetPath: 'assets/quiz_feel/5.jpg',
      label: 'City',
    ),
  ],
  ),
  ];

  /// حساب النتيجة بناءً على اختيارات المستخدم (list من styleId)
  static StyleQuizResult calculateResult(List<String> pickedStyleIds) {
    final counts = <String, int>{
      'classic': 0,
      'modern': 0,
      'vintage': 0,
      'modern_Mix': 0,
    };

    for (final id in pickedStyleIds) {
      if (counts.containsKey(id)) counts[id] = (counts[id] ?? 0) + 1;
    }

    String winner = 'modern';
    int maxCount = -1;

    counts.forEach((k, v) {
      if (v > maxCount) {
        maxCount = v;
        winner = k;
      }
    });

    final total = pickedStyleIds.isEmpty ? 1 : pickedStyleIds.length;
    final confidence = (maxCount <= 0) ? (1 / total) : (maxCount / total);

    // خلفية شاشة النتيجة (عدّليها إذا اسمها غير هيك)
    const bg = 'assets/backgrounds/1.jpg';

    switch (winner) {
      case 'classic':
        return const StyleQuizResult(
          styleId: 'classic',
          styleTitle: 'Classic Style',
          shortDescription: 'Warm, elegant, timeless details.',
          reasons: [
            'You prefer balanced spaces and timeless furniture.',
            'You lean toward warm tones and classic materials.',
            'You like a cozy, refined look that feels “home”.',
          ],
          confidence: 0.0, // سيتم استبدالها تحت
          backgroundAssetPath: bg,
        ).copyWith(confidence: confidence);

      case 'vintage':
        return const StyleQuizResult(
          styleId: 'vintage',
          styleTitle: 'Vintage Style',
          shortDescription: 'Earthy, unique, full of character.',
          reasons: [
            'You enjoy expressive details and unique pieces.',
            'You like earthy palettes and warm textures.',
            'You prefer charm and personality over “perfect”.',
          ],
          confidence: 0.0,
          backgroundAssetPath: bg,
        ).copyWith(confidence: confidence);

      case 'modern_Mix':
        return const StyleQuizResult(
          styleId: 'modern_Mix',
          styleTitle: 'Modern Mix Style',
          shortDescription: 'Modern base with warm, mixed touches.',
          reasons: [
            'You like modern lines but still want warmth.',
            'You mix styles in a clean, organized way.',
            'You enjoy variety without losing harmony.',
          ],
          confidence: 0.0,
          backgroundAssetPath: bg,
        ).copyWith(confidence: confidence);

      case 'modern':
      default:
        return const StyleQuizResult(
          styleId: 'modern',
          styleTitle: 'Modern Style',
          shortDescription: 'Clean lines, minimal, bright feeling.',
          reasons: [
            'You prefer clean lines and a sleek look.',
            'Neutral palettes feel calm and modern to you.',
            'You like simplicity with smart details.',
          ],
          confidence: 0.0,
          backgroundAssetPath: bg,
        ).copyWith(confidence: confidence);
    }
  }
}

/// helper صغير حتى ما نعيد كتابة الكونست
extension _ResultCopy on StyleQuizResult {
  StyleQuizResult copyWith({
    double? confidence,
  }) {
    return StyleQuizResult(
      styleId: styleId,
      styleTitle: styleTitle,
      shortDescription: shortDescription,
      reasons: reasons,
      confidence: confidence ?? this.confidence,
      backgroundAssetPath: backgroundAssetPath,
    );
  }
}