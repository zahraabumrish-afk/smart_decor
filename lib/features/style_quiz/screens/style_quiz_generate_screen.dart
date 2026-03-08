import 'dart:ui';
import 'package:flutter/material.dart';
import 'style_quiz_saved_designs_screen.dart';

class StyleQuizGenerateScreen extends StatelessWidget {
  const StyleQuizGenerateScreen({
    super.key,
    required this.title,
    required this.selectedImageAsset,
    required this.backgroundAssetPath,
    required this.selectedColor,
    this.generatedImageUrl, // الرابط الجديد (اختياري)
  });

  final String title;
  final String selectedImageAsset;
  final String backgroundAssetPath;
  final Color selectedColor;
  final String? generatedImageUrl; // المتغير الجديد لاستقبال رابط AI

  static const Color sand = Color(0xFFD8C3A5); 
  static const Color darkText = Color(0xFF1F1B16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              backgroundAssetPath.isNotEmpty ? backgroundAssetPath : 'assets/backgrounds/1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.10)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackPill(onTap: () => Navigator.pop(context)),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    title.replaceAll("Preview", "Final Design"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // منطقة عرض الصورة (AI أو Asset)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // المنطق البرمجي لاختيار مصدر الصورة
                                    generatedImageUrl != null && generatedImageUrl!.isNotEmpty
                                        ? Image.network(
                                            generatedImageUrl!,
                                            fit: BoxFit.cover,
                                            // أثناء التحميل من الرابط
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.black26,
                                                child: const Center(
                                                  child: CircularProgressIndicator(color: sand),
                                                ),
                                              );
                                            },
                                            // في حال فشل الرابط
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(selectedImageAsset, fit: BoxFit.cover);
                                            },
                                          )
                                        : Image.asset(
                                            selectedImageAsset,
                                            fit: BoxFit.cover,
                                          ),

                                    // طبقة اللون (تظهر فقط إذا لم تكن صورة AI لتوضيح المفهوم)
                                    if (generatedImageUrl == null)
                                      Container(
                                        color: selectedColor.withOpacity(0.18),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // زر حفظ/اكمال
                            _PrimaryButton(
                              text: "Save Final Design",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StyleQuizSavedDesignsScreen(
                                      title: title,
                                      // نمرر الرابط كأولوية للحفظ، وإذا لم يوجد نمرر الـ Asset
                                      imageAssetPath: generatedImageUrl ?? selectedImageAsset,
                                      backgroundAssetPath: backgroundAssetPath,
                                      appliedColor: selectedColor,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            Text(
                              generatedImageUrl != null 
                                  ? "AI has successfully generated your design."
                                  : "Selected color is applied as a preview (concept).",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              "Back",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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

  static const Color sand = Color(0xFFD8C3A5);
  static const Color darkText = Color(0xFF1F1B16);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: sand.withOpacity(0.95),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: darkText,
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