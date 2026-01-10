import 'package:flutter/material.dart';
import 'package:smart_decor/features/style_quiz/screens/style_quiz_upload_room_images_screen.dart';

// ✅ Backend (Style Quiz - Path 2)
import 'package:smart_decor/features/style_quiz/data/repositories/room_session_repository.dart';

/// ✅ شاشة حفظ التصميم (Saved Design) - بدون Blur، فقط غباش خفيف جداً
/// تعرض الخلفية + صورة التصميم بالوسط + زر يروح لشاشة رفع صور الغرفة
class StyleQuizSavedDesignsScreen extends StatelessWidget {
  final String title; // اسم الستايل/العنوان
  final String imageAssetPath; // صورة التصميم الذي اخترتيه (Asset)
  final String backgroundAssetPath; // الخلفية
  final Color appliedColor; // اللون المختار (شفّة خفيفة على الصورة)

  /// ✅ (اختياري) باليتة Hex لعرضها لاحقاً في شاشة Apply Preview
  final List<String> paletteHex;

  const StyleQuizSavedDesignsScreen({
    super.key,
    required this.title,
    required this.imageAssetPath,
    required this.backgroundAssetPath,
    required this.appliedColor,
    this.paletteHex = const [],
  });

  // ✅ تحويل عنوان الستايل إلى styleId بسيط (بدون ما نضيف باراميتر جديد)
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

    // Loading صغير (بدون أي تغيير تصميم الشاشة)
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
      // sqflite ما يشتغل على الويب أو أي خطأ آخر
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'DB is not available on Web. Run on Android/iOS to test backend.\n$e',
          ),
        ),
      );
      sessionId = null;
    } finally {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop(); // close loading
    }

    // روح على شاشة رفع الصور (مع sessionId إذا توفر)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StyleQuizUploadRoomImagesScreen(
          styleTitle: title,
          designImageAssetPath: imageAssetPath,
          paletteHex: paletteHex,
          sessionId: sessionId, // ✅ لازم نضيفها بالملف الثاني (Upload) كـ optional
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
      child: Image.asset(
        backgroundAssetPath,
        fit: BoxFit.cover,
      ),
    ),

    // ✅ غباش خفيف جداً فقط (بدون blur)
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
    ),const SizedBox(height: 14),

      // ✅ الصورة بالوسط
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
                    child: Image.asset(
                      imageAssetPath,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // ✅ شفّة لون خفيفة على الصورة (مو على الشاشة)
                  Positioned.fill(
                    child: Container(
                      color: appliedColor.withOpacity(0.22),
                    ),
                  ),

                  // ✅ طبقة خفيفة جداً لتحسين وضوح الصورة
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

      // ✅ زر يودّي لشاشة رفع 4 صور + createSession
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