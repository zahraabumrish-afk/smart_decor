import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

class StyleQuizApplyPreviewScreen extends StatelessWidget {
  final String styleTitle;
  final String designImageAssetPath; // صورة التصميم المحفوظ (Asset)
  final List<String> paletteHex; // مثل: ["#D8C3A5", "#BCA48A", ...]
  final Map<String, Uint8List?> roomPhotosBytes; // keys: front/right/left/back

  const StyleQuizApplyPreviewScreen({
    super.key,
    required this.styleTitle,
    required this.designImageAssetPath,
    required this.paletteHex,
    required this.roomPhotosBytes,
  });

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '').toUpperCase();
    final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
    return Color(value);
  }

  Widget _chip(Color c) {
    return Container(
      width: 26,
      height: 26,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.18),
          ),
        ],
      ),
    );
  }

  Widget _photoMini(String label, Uint8List? bytes) {
    return Column(
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: bytes == null
                ? Center(
              child: Icon(
                Icons.check_circle,
                color: Colors.white.withOpacity(0.65),
                size: 26,
              ),
            )
                : Image.memory(bytes, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // نفس خلفية تصميمك + نفس الغباش الخفيف
    return Scaffold(
      body: Stack(
        children: [
      Positioned.fill(
      child: Image.asset(
        'assets/backgrounds/1.jpg',
        fit: BoxFit.cover,
      ),
    ),
    Positioned.fill(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
    child: Container(color: Colors.black.withOpacity(0.05)),
    ),
    ),
    SafeArea(
    child: Padding(
    padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Back
    InkWell(
    onTap: () => Navigator.pop(context),
    borderRadius: BorderRadius.circular(18),
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.25),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withOpacity(0.12)),
    ),
    child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
    SizedBox(width: 8),
    Text(
    "Back",
    style: TextStyle(color: Colors.white,
    fontWeight: FontWeight.w800,
    ),
    ),
    ],
    ),
    ),
    ),

    const SizedBox(height: 18),

    // Title
    const Center(
    child: Column(
    children: [
    Text(
    "Preview (Saved Style)",
    style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w900,
    fontSize: 20,
    ),
    ),
    SizedBox(height: 6),
    Text(
    "This is the style you saved + your uploaded room photos",
    style: TextStyle(
    color: Colors.white70,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    ),
    ),
    ],
    ),
    ),

    const SizedBox(height: 18),

    // Main card (design image)
    Center(
    child: Container(
    constraints: const BoxConstraints(maxWidth: 560),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.22),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(color: Colors.white.withOpacity(0.14)),
    ),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Style name + palette
    Row(
    children: [
    Expanded(
    child: Text(
    styleTitle,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w900,
    fontSize: 16,
    ),
    ),
    ),
    const SizedBox(width: 10),
    Row(
    children: paletteHex.take(5).map((h) => _chip(_hexToColor(h))).toList(),
    ),
    ],
    ),

    const SizedBox(height: 12),

    ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: AspectRatio(
    aspectRatio: 16 / 9,
    child: Image.asset(
    designImageAssetPath,
    fit: BoxFit.cover,
    ),
    ),
    ),

    const SizedBox(height: 14),

    // Uploaded photos minis
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    _photoMini('Front', roomPhotosBytes['front']),
    _photoMini('Right', roomPhotosBytes['right']),
    _photoMini('Left', roomPhotosBytes['left']),
    _photoMini('Back', roomPhotosBytes['back']),
    ],
    ),],
    ),
    ),
    ),

      const Spacer(),

      // Button (نفس فكرة نكست: ظاهر دائماً، وبعد اكتمال الصور يصير أوضح)
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // هلق الخطوة الجاية: شاشة "Apply / Generate (AI)" (بنجهزها بعدك)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Next: Apply/Generate screen (AI)")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD8C3A5).withOpacity(0.92), // بيج رملي
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                "Continue",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
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