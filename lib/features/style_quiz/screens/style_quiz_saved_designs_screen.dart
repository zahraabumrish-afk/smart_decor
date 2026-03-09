import 'package:flutter/material.dart';
import 'package:smart_decor/features/style_quiz/screens/style_quiz_upload_room_images_screen.dart';
import 'package:smart_decor/features/style_quiz/data/repositories/room_session_repository.dart';

class StyleQuizSavedDesignsScreen extends StatelessWidget {
  final String title;
  final String imageAssetPath; // قد يكون مسار محلي أو رابط URL
  final String backgroundAssetPath;
  final Color appliedColor;
  final List<String> paletteHex;

  const StyleQuizSavedDesignsScreen({
    super.key,
    required this.title,
    required this.imageAssetPath,
    required this.backgroundAssetPath,
    required this.appliedColor,
    this.paletteHex = const [],
  });

  // دالة مساعدة لاختيار نوع الـ Widget المناسب للصورة
  Widget _buildDynamicImage(String path, {BoxFit fit = BoxFit.cover, double? width, double? height}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        // معالجة حالة فشل التحميل من الإنترنت
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.white, size: 40),
        ),
      );
    } else {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
      );
    }
  }

  String _styleIdFromTitle(String t) {
    return t
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  Future<void> _openUploadWithSession(BuildContext context) async {
    String? sessionId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = RoomSessionRepository();
      sessionId = await repo.createSession(
        styleId: _styleIdFromTitle(title),
        styleTitle: title,
        designImageAssetPath: imageAssetPath,
        paletteHex: paletteHex,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
      sessionId = null;
    } finally {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StyleQuizUploadRoomImagesScreen(
          styleTitle: title,
          designImageAssetPath: imageAssetPath,
          paletteHex: paletteHex,
          sessionId: sessionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية
          Positioned.fill(
            child: _buildDynamicImage(backgroundAssetPath),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.14),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackPill(onTap: () => Navigator.pop(context)),
                  const SizedBox(height: 14),
                  const Text(
                    "Saved Design",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // الصورة بالوسط
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 16 / 10,
                                child: _buildDynamicImage(imageAssetPath),
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: appliedColor.withOpacity(0.22),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.05),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  _PrimaryButton(
                    text: "Upload Room Photos",
                    onTap: () => _openUploadWithSession(context),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// الكلاسات المساعدة (تلقائية كما هي في الكود الأصلي)
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