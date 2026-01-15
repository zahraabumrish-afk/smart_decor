import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'design_request_result_screen.dart';

class DesignRequestChatScreen extends StatefulWidget {
  final XFile pickedImage;
  final Uint8List? webBytes;

  const DesignRequestChatScreen({
    super.key,
    required this.pickedImage,
    required this.webBytes,
  });

  @override
  State<DesignRequestChatScreen> createState() =>
      _DesignRequestChatScreenState();
}

class _DesignRequestChatScreenState extends State<DesignRequestChatScreen> {
  // Controller لحقل الكتابة
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
          // ======================
          // خلفية التطبيق الأساسية
          // ======================
          Image.asset(
          'assets/backgrounds/1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // ======================
        // غباش خفيف للخلفية (ثابت مثل باقي الشاشات)
        // ======================
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),

        SafeArea(
          child: Column(
              children: [
          // ======================
          // زر الرجوع
          // ======================
          Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon:
              const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                'Back',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor:
                Colors.black.withOpacity(0.25),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ======================
        // عنوان الشاشة
        // ======================
        const Text(
          'Design Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        // ======================
        // الإطار الكبير (خففنا الغباش)
        // ======================
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // ⬅️ خففنا الغباش هون
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.10),
                      ),
                    ),
                    child: const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Describe what you want to design (style, colors, furniture, etc.)',style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        ),
                    ),
                ),
            ),
        ),

        // ======================
        // شريط الكتابة + زر الإرسال
        // ======================
        Padding(
          padding:
          const EdgeInsets.fromLTRB(18, 14, 18, 24),
          child: Row(
            children: [
          // ======================
          // مربع الكتابة (كبرناه)
          // ======================
          Expanded(
          child: SizedBox(
          height: 140, // ⬅️ تكبير الارتفاع
            child: TextField(
              controller: _controller,
              maxLines: 8, // ⬅️ يسمح بسطرين
              style:
              const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your request...',
                hintStyle: const TextStyle(
                    color: Colors.white54),
                filled: true,
                fillColor:
                Colors.black.withOpacity(0.18),
                contentPadding:
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white
                        .withOpacity(0.16),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white
                        .withOpacity(0.16),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white
                        .withOpacity(0.28),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ======================
        // زر الإرسال
        // ======================
        SizedBox(
            height: 56,
            width: 56,
            child: ElevatedButton(
              onPressed: () {
                // ✅ انتقال مؤقت لشاشة النتيجة
                // (بدون AI حالياً – مجرد تجربة المسار)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DesignRequestResultScreen(
                      prompt: _controller.text,        // النص يلي كتبه المستخدم
                      pickedImage: widget.pickedImage, // الصورة المرفوعة
                      webBytes: widget.webBytes,       // بايتات الويب
                    ),
                  ),
                );
              },
                style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFFF3C9A8),
                  foregroundColor:
                  const Color(0xFF3B2A1E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(16),
                  ),
                ),
              child:
              const Icon(Icons.send_rounded),
            ),
        ),
            ],
          ),
        ),
              ],
          ),
        ),
          ],
        ),
    );
  }
}