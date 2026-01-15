import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'design_request_chat_screen.dart';

class DesignRequestUploadScreen extends StatefulWidget {
  const DesignRequestUploadScreen({super.key});

  @override
  State<DesignRequestUploadScreen> createState() =>
      _DesignRequestUploadScreenState();
}

class _DesignRequestUploadScreenState extends State<DesignRequestUploadScreen> {
  // ✅ مسؤول عن اختيار الصور (كاميرا/معرض)
  final ImagePicker _picker = ImagePicker();

  // ✅ ملف الصورة المختارة
  XFile? _picked;

  // ✅ للويب فقط: نخزن bytes حتى نعرض Image.memory
  Uint8List? _webBytes;

  bool get _hasImage => _picked != null;

  // ✅ (جديد) إظهار/إخفاء زرّين Camera/Gallery
  bool _showPickButtons = false;

  // ✅ اختيار صورة من المعرض
  Future<void> _pickFromGallery() async {
    final XFile? x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;

    if (kIsWeb) {
      final bytes = await x.readAsBytes();
      setState(() {
        _picked = x;
        _webBytes = bytes;
      });
    } else {
      setState(() {
        _picked = x;
        _webBytes = null;
      });
    }
  }

  // ✅ التقاط صورة من الكاميرا
  Future<void> _pickFromCamera() async {
    final XFile? x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (x == null) return;

    if (kIsWeb) {
      final bytes = await x.readAsBytes();
      setState(() {
        _picked = x;
        _webBytes = bytes;
      });
    } else {
      setState(() {
        _picked = x;
        _webBytes = null;
      });
    }
  }

  // ✅ انتقال للشات بعد اختيار صورة
  void _goNext() {
    if (!_hasImage) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DesignRequestChatScreen(
          pickedImage: _picked!,
          webBytes: _webBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _hasImage;

    return Scaffold(
        body: Stack(
          children: [
          // ✅ خلفية الشاشة
          Image.asset(
          'assets/backgrounds/1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // ✅ غباش خفيف على الخلفية (مثل أسلوب مشروعك)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.10)),
        ),

        SafeArea(
          child: Column(
              children: [
          // ✅ زر رجوع أعلى يسار
          Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text('Back',
                  style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.25),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // ✅ عنوان
        const Text(
          'Upload Your Room Photo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text('Upload one clear photo of your room to start\ndesigning it your way',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.25,
          ),
        ),

      const SizedBox(height: 18),

      // ✅ (المهم) مربع الصورة: أكبر + بالنص + بدون "إطار كبير" وراه
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760, // ✅ حتى على الويب ما يطلع عريض زيادة
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GestureDetector(
              onTap: _pickFromGallery,
              child: Container(
                width: double.infinity,
                height: 360, // ✅ كبرناه (كان 185)
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),

                  // ✅ قبل اختيار صورة: نخلي خلفية خفيفة داخل المربع لتوضح مكان الرفع
                  // ✅ بعد اختيار صورة: نخلي الخلفية شفافة تماماً (بدون غباش ورا الصورة)
                  color: _hasImage
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.18),

                  // ✅ قبل اختيار صورة: نخلي إطار خفيف
                  // ✅ بعد اختيار صورة: ما في إطار (حسب طلبك: بدون إطار ورا/حول الصورة)
                  border: _hasImage
                      ? null
                      : Border.all(
                    color: Colors.white.withOpacity(0.22),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: _hasImage
                      ? SizedBox.expand(
                    // ✅ الصورة تملى المربع كامل (تظهر صح)
                    child: kIsWeb
                        ? Image.memory(
                      _webBytes!,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      _picked!.path,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFFF3C9A8),
                        size: 60,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Tap to upload your room photo',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),// ✅ زر Upload (نفس ستايلك)
                SizedBox(
                  width: 220,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      // ✅ (المطلوب) أول ما أكبس Upload: أظهر زرّين Camera/Gallery
                      setState(() => _showPickButtons = true);

                      // ✅ وما تغيّر شي: برضو يفتح المعرض مثل قبل
                      _pickFromGallery();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3C9A8),
                      foregroundColor: const Color(0xFF3B2A1E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Upload Photo',
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ (المطلوب) زرين (Camera / Gallery) لا يظهروا إلا بعد كبس Upload
                if (_showPickButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SmallBeigeButton(
                        text: 'Camera',
                        icon: Icons.photo_camera_outlined,
                        onTap: _pickFromCamera,
                      ),
                      const SizedBox(width: 10),
                      _SmallBeigeButton(
                        text: 'Gallery',
                        icon: Icons.photo_library_outlined,
                        onTap: _pickFromGallery,
                      ),
                    ],
                  ),

                const Spacer(),

                // ✅ زر المتابعة (نفس ستايل الأزرار وبحجم أصغر)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: SizedBox(
                    width: 220,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: canContinue ? _goNext : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canContinue
                            ? const Color(0xFFF3C9A8)
                            : Colors.white.withOpacity(0.12),
                        foregroundColor: canContinue
                            ? const Color(0xFF3B2A1E)
                            : Colors.white38,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Continue to Design Chat',
                        style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
}

class _SmallBeigeButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _SmallBeigeButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 132,
        height: 40,
        child: ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, size: 18),
            label: Text(
              text,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3C9A8),
              foregroundColor: const Color(0xFF3B2A1E),
              elevation: 0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
        ),
    );
  }
}