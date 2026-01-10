import 'dart:ui';
import 'package:flutter/material.dart';

import 'style_quiz_generate_screen.dart';

class StyleQuizPreviewScreen extends StatefulWidget {
  const StyleQuizPreviewScreen({
    super.key,
    required this.title,
    required this.selectedImageAsset,
    required this.backgroundAssetPath,
  });

  final String title;
  final String selectedImageAsset;
  final String backgroundAssetPath;

  @override
  State<StyleQuizPreviewScreen> createState() => _StyleQuizPreviewScreenState();
}

class _StyleQuizPreviewScreenState extends State<StyleQuizPreviewScreen> {
  // باليت ألوان (متل اللي كان عندك - تقدري تغيّريها لاحقاً إذا بدك)
  final List<Color> _palette = const [
    Color(0xFFE6D3A3), // sand beige
    Color(0xFFD8C3A5),
    Color(0xFFCBB39B),
    Color(0xFFBFA78F),
    Color(0xFFA58E7C),
    Color(0xFF8E7D72),
    Color(0xFF6F6A63),
    Color(0xFF4D4A46),
    Color(0xFF2E2B28),
    Color(0xFF9FB3A5),
    Color(0xFFB9C7D4),
    Color(0xFFE2C9CF),
  ];

  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
      // background
      Positioned.fill(
      child: Image.asset(
        widget.backgroundAssetPath,
        fit: BoxFit.cover,
      ),
    ),

    // ✅ (3) تخفيف الغباش فقط
    Positioned.fill(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    child: Container(
    color: Colors.black.withOpacity(0.18),
    ),
    ),
    ),

    SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    children: [
    // Back
    Align(
    alignment: Alignment.centerLeft,
    child: _BackPill(onTap: () => Navigator.pop(context)),
    ),

    const SizedBox(height: 14),

    // Title
    Text(
    widget.title,
    textAlign: TextAlign.center,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    ),
    ),

    const SizedBox(height: 14),

    // Image (center) ✅ كبرناها بس
    Expanded(
    child: Center(
    child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 600),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: AspectRatio(
    // ✅ هذا اللي كبّر الصورة وخلاها أوضح بالنص
    aspectRatio: 16 / 9,
    child: Stack(
    children: [
    Positioned.fill(
    child: Image.asset(
    widget.selectedImageAsset,
    fit: BoxFit.cover,
    ),
    ),

    // ✅ (2) شَفّة اللون على صورة النص فقط
    Positioned.fill(
    child: Container(
    color: _palette[_selectedColorIndex]
        .withOpacity(0.18),
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    ),

    const SizedBox(height: 12),

    // Label
    Text(
    'Color Preview (Concept)',
    style: TextStyle(
    color: Colors.white.withOpacity(0.90),
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
    ),
    ),
      const SizedBox(height: 10),

      // ✅ (1) دوائر أكبر شوي
      SizedBox(
        height: 32,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_palette.length, (i) {
                final c = _palette[i];
                final isSelected = i == _selectedColorIndex;

                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedColorIndex = i;
                  }),
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white.withOpacity(0.95)
                            : Colors.white.withOpacity(0.25),
                        width: isSelected ? 2.2 : 1,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),

      // Button
      SizedBox(
        width: 260,
        height: 46,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StyleQuizGenerateScreen(
                  title: widget.title,
                  selectedImageAsset: widget.selectedImageAsset,
                  backgroundAssetPath: widget.backgroundAssetPath,
                  selectedColor: _palette[_selectedColorIndex],
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD8C3A5).withOpacity(0.92),
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Generate AI Design',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
            ),
          ),
        ),
      ),

      const SizedBox(height: 12),
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
  const _BackPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(24),border: Border.all(color: Colors.white.withOpacity(0.20)),
            ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('Back', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
    );
  }
}