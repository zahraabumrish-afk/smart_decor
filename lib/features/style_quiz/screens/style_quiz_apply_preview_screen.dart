import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// تأكد من استيراد الشاشة التالية هنا عند تجهيزها
// import 'package:smart_decor/features/style_quiz/screens/style_quiz_final_ai_result_screen.dart';

class StyleQuizApplyPreviewScreen extends StatefulWidget {
  final String styleTitle;
  final String designImageAssetPath; // هذا رابط URL (Image.network)
  final List<String> paletteHex;
  final Map<String, Uint8List?> roomPhotosBytes;

  const StyleQuizApplyPreviewScreen({
    super.key,
    required this.styleTitle,
    required this.designImageAssetPath,
    required this.paletteHex,
    required this.roomPhotosBytes,
  });

  @override
  State<StyleQuizApplyPreviewScreen> createState() => _StyleQuizApplyPreviewScreenState();
}

class _StyleQuizApplyPreviewScreenState extends State<StyleQuizApplyPreviewScreen> {
  // --- CONFIGURATION ---
  // ⚠️ ضع مفاتيح الـ API الخاصة بك هنا
  static const String _imgBBKey = '';
  static const String _nanoBananaToken = '';

  static const String _nanoGenerateUrl = 'https://api.nanobananaapi.ai/api/v1/nanobanana/generate';
  static const String _nanoRecordUrl = 'https://api.nanobananaapi.ai/api/v1/nanobanana/record-info';

  // State flags
  bool _isGenerating = false;
  String _loadingStatus = "";
  String? _taskId;
  Timer? _pollTimer;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceAll('#', '').toUpperCase();
    final value = int.parse(h.length == 6 ? 'FF$h' : h, radix: 16);
    return Color(value);
  }

  // دالة لرفع بايتات صورة الغرفة الفارغة إلى ImgBB للحصول على URL
  Future<String> _uploadRoomByteData(Uint8List bytes) async {
    setState(() => _loadingStatus = "Uploading room photo...");
    String base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {
        'key': _imgBBKey,
        'image': base64Image,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['url']; // الرابط المباشر للصورة المرفوعة
    } else {
      throw Exception("Failed to upload room image to cloud.");
    }
  }

  // الدالة الرئيسية التي تستدعى عند الضغط على Continue
  Future<void> _handleIntegrateAndGenerate() async {
    final Uint8List? roomFrontBytes = widget.roomPhotosBytes['front'];

    if (roomFrontBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Front view of the room is missing.")),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null; // إعادة تعيين الخطأ في حال إعادة المحاولة
    });

    try {
      // 1. رفع صورة الغرفة الفارغة (بايتات) للحصول على رابط
      final String roomImageUrl = await _uploadRoomByteData(roomFrontBytes);

      // 2. رابط صورة التصميم (المفروشات) جاهز بالفعل
      final String furnitureImageUrl = widget.designImageAssetPath;

      setState(() => _loadingStatus = "AI is designing...");

      // 3. صياغة البرومت الإنجليزي الاحترافي للدمج (Style & Furniture Transfer)
      const String enhancedPrompt = 
          "Photorealistic interior design rendering. Take the empty room structure from Image 1 as the base architecture. "
          "Transfer and arrange the furniture, decorations, art, lighting style, and overall color palette from Image 2 into this empty room. "
          "Ensure realistic perspective, shadows, and textures. The final result should look like Image 1, but fully furnished and styled exactly like Image 2.";

      // 4. إرسال طلب التعديل (IMAGETOIAMGE) مع رابطين
      final resp = await http.post(
        Uri.parse(_nanoGenerateUrl),
        headers: {
          'Authorization': 'Bearer $_nanoBananaToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': enhancedPrompt,
          'numImages': 1,
          'type': 'IMAGETOIAMGE', // نمط التعديل/الدمج
          'imageUrls': [roomImageUrl, furnitureImageUrl], // ✅ إرسال رابط الغرفة ثم رابط المفروشات
          'image_size': '16:9',
          'callBackUrl': 'https://dummy-callback.com/api',
        }),
      );

      final decoded = jsonDecode(resp.body);

      if (decoded['code'] == 200) {
        _taskId = decoded['data']['taskId']?.toString();
        _startPolling(); // البدء في فحص الحالة كل ثانيتين
      } else {
        throw Exception(decoded['msg'] ?? "Server Error");
      }
    } catch (e) {
      _resetStateWithError("Error: $e");
    }
  }

  // دالة الـ Polling لفحص هل انتهى التصميم
  void _startPolling() {
    setState(() => _loadingStatus = "Applying final touches...");
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_taskId == null) return;

    try {
      final uri = Uri.parse(_nanoRecordUrl).replace(queryParameters: {'taskId': _taskId!});
      final resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $_nanoBananaToken',
        'Content-Type': 'application/json',
      });

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['data'];
        if (data == null || data is! Map) return;

        final int? successFlag = int.tryParse(data['successFlag']?.toString() ?? '');
        String? resultImageUrl = data['response']?['resultImageUrl'];

        if (successFlag == 1 || resultImageUrl != null) {
          // نجاح التوليد
          _pollTimer?.cancel();
          if (resultImageUrl != null) {
            _navigateToResult(resultImageUrl);
          } else {
            _resetStateWithError("Succeeded, but image URL is missing.");
          }
        } else if (successFlag == 2 || successFlag == 3) {
          // فشل على السيرفر
          _pollTimer?.cancel();
          _resetStateWithError("Server side generation failed.");
        }
      }
    } catch (e) {
      debugPrint("Poll error: $e");
    }
  }

  void _navigateToResult(String imageUrl) {
    setState(() => _isGenerating = false);
    // هلق الانتقال للشاشة النهائية لعرض النتيجة
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StyleQuizFinalAiResultScreen(
          finalImageUrl: imageUrl,
          styleTitle: widget.styleTitle,
        ),
      ),
    );
    
    // مؤقتاً نعرض SnackbBar حتى تجهز الشاشة التالية
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Success! AI Image Generated. (Navigate to result screen)")),
    );
    debugPrint("Final AI Image: $imageUrl");
  }

  String? _error;
  void _resetStateWithError(String message) {
    _pollTimer?.cancel();
    setState(() {
      _isGenerating = false;
      _error = message;
    });
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Generation Issue"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  // --- UI WIDGETS ---
  Widget _chip(Color c) {
    return Container(
      width: 26, height: 26,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(blurRadius: 10, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.18)),
        ],
      ),
    );
  }

  Widget _photoMini(String label, Uint8List? bytes) {
    return Column(
      children: [
        Container(
          width: 74, height: 74,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: bytes == null
                ? Center(child: Icon(Icons.check_circle, color: Colors.white.withOpacity(0.65), size: 26))
                : Image.memory(bytes, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/backgrounds/1.jpg', fit: BoxFit.cover),
          ),
          // Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.2, sigmaY: 2.2),
              child: Container(color: Colors.black.withOpacity(0.05)),
            ),
          ),
          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  InkWell(
                    onTap: _isGenerating ? null : () => Navigator.pop(context),
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
                          Text("Back", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Title Area
                  const Center(
                    child: Column(
                      children: [
                        Text("Preview (Saved Style)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                        SizedBox(height: 6),
                        Text("This is the style you saved + your uploaded room photos", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Main card (design image + room minis)
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
                                child: Text(widget.styleTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: widget.paletteHex.take(5).map((h) => _chip(_hexToColor(h))).toList(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // صورة التصميم (المفروشات)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(widget.designImageAssetPath, fit: BoxFit.cover),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Uploaded photos minis
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _photoMini('Front', widget.roomPhotosBytes['front']),
                              _photoMini('Right', widget.roomPhotosBytes['right']),
                              _photoMini('Left', widget.roomPhotosBytes['left']),
                              _photoMini('Back', widget.roomPhotosBytes['back']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Continue Button (Now handles Integration)
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          // تعطيل الزر أثناء التوليد منعاً لعدة طلبات
                          onPressed: _isGenerating ? null : _handleIntegrateAndGenerate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD8C3A5).withOpacity(0.92), // بيج رملي
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            disabledBackgroundColor: Colors.grey, // لون عند التعطيل
                          ),
                          child: _isGenerating
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black87),
                                )
                              : const Text(
                                  "Continue & Generate AI Design",
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                        ),
                      ),
                    ),
                  ),
                  
                  // عرض حالة التحميل تحت الزر
                  if (_isGenerating)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Center(
                        child: Text(
                          _loadingStatus,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

/// ✅ شاشة عرض النتيجة النهائية الناتجة عن الذكاء الاصطناعي
class StyleQuizFinalAiResultScreen extends StatelessWidget {
  final String finalImageUrl;
  final String styleTitle;

  const StyleQuizFinalAiResultScreen({
    super.key,
    required this.finalImageUrl,
    required this.styleTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخلفية الثابتة للتطبيق
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/1.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // 2. طبقة غباش وتعتيم خفيف
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // زر الرجوع (Pill Style)
                  _BackPill(onTap: () => Navigator.pop(context)),

                  const SizedBox(height: 25),

                  // العنوان
                  const Text(
                    "Your AI Transformation",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    "Based on $styleTitle style",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // عرض الصورة النهائية داخل إطار احترافي
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            finalImageUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(color: Color(0xFFD8C3A5)),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // أزرار التحكم (حفظ / مشاركة)
                  _PrimaryActionButtons(imageUrl: finalImageUrl),
                  
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ الأزرار السفلية للشاشة النهائية
class _PrimaryActionButtons extends StatelessWidget {
  final String imageUrl;
  const _PrimaryActionButtons({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // زر الحفظ في المعرض
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              // هنا نضع كود حفظ الصورة أو مشاركتها
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Design saved to gallery!")),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text("Save Design", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD8C3A5),
              foregroundColor: const Color(0xFF1F1B16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // زر الرجوع للرئيسية
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Text(
            "Back to Home",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}


class _BackPill extends StatelessWidget {
  final VoidCallback onTap;

  const _BackPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}