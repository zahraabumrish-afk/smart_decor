import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/style_quiz_models.dart';
import 'style_quiz_room_types_screen.dart';

class StyleQuizResultScreen extends StatelessWidget {
  const StyleQuizResultScreen({super.key, required this.result});

  final StyleQuizResult result;

  // ===== Colors (same spirit) =====
  static const Color sand = Color(0xFFD8C3A5); // بيج رملي
  static const Color darkText = Color(0xFF1F1B16); // أسود/داكن
  static const Color cardBorder = Color(0x26FFFFFF); // white 15%

  @override
  Widget build(BuildContext context) {
    final confidence = (result.confidence.clamp(0.0, 1.0));
    final percentText = "${(confidence * 100).round()}%";

    return Scaffold(
        body: Stack(
          children: [
            // Background image (use your same intro background)
            Positioned.fill(
              child: Image.asset(
                result.backgroundAssetPath.isNotEmpty
                    ? result.backgroundAssetPath
                    : 'assets/backgrounds/1.jpg',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                      children: [
                  // Top bar
                  Row(
                  children: [
                  _BackPill(
                  onTap: () => Navigator.pop(context),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Expanded(
            child: Align(
                alignment: Alignment.topLeft,
                child: _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        // Title
                        const Text(
                        "Your Result",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Style name (SAND)
                      Text(
                        result.styleTitle,
                        style: const TextStyle(
                          color: sand, // ✅ بيج رملي
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Confidence (BLACK text)
                      Text(
                        "Confidence: $percentText",
                        style: const TextStyle(
                          color: darkText, // ✅ أسود
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.35),
                          valueColor:
                          const AlwaysStoppedAnimation<Color>(sand),
                        ),
                      ),const SizedBox(height: 14),

                          // Short description (BLACK)
                          Text(
                            result.shortDescription,
                            style: const TextStyle(
                              color: darkText, // ✅ أسود
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Why this result (BLACK)
                          const Text(
                            "Why this result?",
                            style: TextStyle(
                              color: darkText, // ✅ أسود
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Expanded(
                            child: ListView.separated(
                              itemCount: result.reasons.length,
                              separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "• ",
                                      style: TextStyle(
                                        color: darkText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        result.reasons[i],
                                        style: const TextStyle(
                                          color: darkText, // ✅ أسود
                                          fontSize: 13.5,
                                          height: 1.35,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
            ),
        ),

                        const SizedBox(height: 16),

                        // Bottom button (أصغر + زر واحد + بيج رملي)
                        Center(
                          child: _PrimaryButton(
                            text: "Explore rooms for this style",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StyleQuizRoomTypesScreen(
                                    styleId: result.styleId,
                                    styleTitle: result.styleTitle,
                                    backgroundAssetPath: result.backgroundAssetPath,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                  ),
              ),
            ),
          ],
        ),
    );
  }
}

// ===== UI Widgets =====

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent, // ✅ شلنا المربع الأبيض
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: StyleQuizResultScreen.cardBorder),
          ),
          child: child,
        ),
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
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          // ❌ شلّي border نهائياً
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              "Back",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: StyleQuizResultScreen.sand,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: StyleQuizResultScreen.darkText,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}