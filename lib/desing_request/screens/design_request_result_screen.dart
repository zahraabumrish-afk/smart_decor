import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DesignRequestResultScreen extends StatelessWidget {
  final String prompt;
  final XFile pickedImage;
  final Uint8List? webBytes;

  const DesignRequestResultScreen({
    super.key,
    required this.prompt,
    required this.pickedImage,
    required this.webBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
          Image.asset(
          'assets/backgrounds/1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),
        SafeArea(
          child: Column(
              children: [
          // زر رجوع
          Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text('Back', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.25),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Result',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 14),

        // ✅ الكرت الرئيسي + Scroll حتى ما يختفي المحتوى
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                        // ✅ صورة الغرفة (مقاس ثابت حتى ما تبلع الشاشة)
                        ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                            height: 300, // 👈 إذا بدك أكبر/أصغر عدلي هون
                            child: kIsWeb
                                ? (webBytes != null
                                ? Image.memory(webBytes!, fit: BoxFit.cover)
                                : _placeholderImage())
                                : FutureBuilder<Uint8List>(
                                future: pickedImage.readAsBytes(),
                                builder: (context, snap) {
                                  if (snap.connectionState != ConnectionState.done) {
                                    return _loadingBox();
                                  }
                                  if (!snap.hasData) return _placeholderImage();
                                  return Image.memory(snap.data!, fit: BoxFit.cover);
                                },
                            ),
                        ),
                        ),

                              const SizedBox(height: 14),

                              const Text(
                                'Your request:',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                prompt.isEmpty ? '(No text entered)' : prompt,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 14),

                              // ✅ مكان النتيجة (ثابت + ما يعمل مشاكل)
                              Container(
                                height: 180,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                                ),
                                child: const Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'AI result will appear here later.\n(We will connect AI in the next step)',
                                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                        ),
                    ),
                ),
            ),
        ),

                const SizedBox(height: 14),

                // زر Back to Chat
                // ✅ زر رجوع للشات (وسط الشاشة)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: SizedBox(
                      width: 180, // ✅ عرض ثابت (عدّليه إذا بدك)
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3C9A8),
                          foregroundColor: const Color(0xFF3B2A1E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Back to Chat',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),
              ],
          ),
        ),
          ],
        ),
    );
  }

  static Widget _placeholderImage() {
    return Container(
      color: Colors.black.withOpacity(0.15),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white70, size: 40),
    );
  }

  static Widget _loadingBox() {
    return Container(
      color: Colors.black.withOpacity(0.12),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}