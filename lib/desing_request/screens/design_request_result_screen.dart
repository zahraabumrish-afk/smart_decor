// lib/screens/design_request_result_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class DesignRequestResultScreen extends StatefulWidget {
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
  State<DesignRequestResultScreen> createState() =>
      _DesignRequestResultScreenState();
}

class _DesignRequestResultScreenState extends State<DesignRequestResultScreen> {
  // UI state
  bool _loading = true;
  String? _error;
  String? _taskId;
  String _loadingStatus = "Starting..."; // حالة تحميل تفصيلية

  // نتيجة الصورة: عادة URL حسب الوثائق
  String? _resultImageUrl;
  Uint8List? _resultImageBytes;

  Timer? _pollTimer;

  // --- المفاتيح والتهيئة ---
  // ⚠️ لا تنسَ وضع مفتاح ImgBB هنا
  static const String _imgBBKey = ' '; 
  static const String _nanoBananaToken = '';

  // endpoints
  static const String _generateUrl =
      'https://api.nanobananaapi.ai/api/v1/nanobanana/generate';
  static const String _recordInfoUrl =
      'https://api.nanobananaapi.ai/api/v1/nanobanana/record-info';

  @override
  void initState() {
    super.initState();
    // نبدأ العملية فوراً عند فتح الصفحة
    _startGenerateAndPoll();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // دالة مساعدة لرفع الصورة لـ ImgBB وتحويلها لرابط
  Future<String> _uploadToImgBB(Uint8List imageBytes) async {
    final String base64Image = base64Encode(imageBytes);

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {
        'key': _imgBBKey,
        'image': base64Image,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['url']; // الرابط المباشر للصورة مرفوعة
    } else {
      throw Exception("Image upload to cloud failed. Please check ImgBB Key.");
    }
  }

  // الدالة الرئيسية المعدلة لتشمل الرفع ثم التوليد
  Future<void> _startGenerateAndPoll() async {
    setState(() {
      _loading = true;
      _error = null;
      _taskId = null;
      _resultImageUrl = null;
      _resultImageBytes = null;
      _loadingStatus = "Preparing image...";
    });

    try {
      // 1) اقرأ بايتس الصورة (ويب أو موبايل)
      Uint8List imageBytes;
      if (kIsWeb && widget.webBytes != null) {
        imageBytes = widget.webBytes!;
      } else {
        imageBytes = await widget.pickedImage.readAsBytes();
      }

      // 2) تحويل الصورة المحلية لرابط شبكي (عبر ImgBB) لحل مشكلة blank imageUrls
      setState(() => _loadingStatus = "Uploading image to cloud...");
      final String uploadedImageUrl = await _uploadToImgBB(imageBytes);

      // تعزيز البرومت بالنص العربي لضمان التعديل وليس الإنشاء
      final String enhancedPrompt = "${widget.prompt} . "
          "يجب تعديل الصورة المرفقة بناءً على الوصف، مع الحفاظ على الهيكل العام للصورة الأصلية "
          "وتطبيق الأسلوب المطلوب باحترافية وبشكل متناسق.";

      setState(() => _loadingStatus = "AI is generating design...");

      // 3) جهّز الـ body — تم تعديله لاستخدام نمط التعديل (IMAGETOIAMGE) والروابط (imageUrls)
      final Map<String, dynamic> body = {
        'prompt': enhancedPrompt, // استخدام البرومت المحسن
        'numImages': 1,
        'type': 'IMAGETOIAMGE', // ✅ التصحيح: تغيير النمط لتعديل الصورة
        'imageUrls': [uploadedImageUrl], // ✅ إرسال الرابط بدلاً من base64
        'image_size': '16:9',
        'callBackUrl': 'https://dummy-callback.com/api', 
      };

      final http.Response resp = await http.post(
        Uri.parse(_generateUrl),
        headers: {
          'Authorization': 'Bearer $_nanoBananaToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception(
            'Generate failed: ${resp.statusCode} — ${resp.body}');
      }

      final dynamic decoded = jsonDecode(resp.body);

      // استخراج taskId من أي مكان محتمل في الـ JSON
      final Map<String, dynamic> decodedMap =
          (decoded is Map) ? Map<String, dynamic>.from(decoded) : {};

      String? foundTaskId;

      if (decodedMap.containsKey('taskId')) {
        foundTaskId = decodedMap['taskId']?.toString();
      } else if (decodedMap.containsKey('data') &&
          decodedMap['data'] is Map) {
        final dataMap = Map<String, dynamic>.from(decodedMap['data']);
        if (dataMap.containsKey('taskId')) {
          foundTaskId = dataMap['taskId']?.toString();
        } else if (dataMap.containsKey('id')) {
          foundTaskId = dataMap['id']?.toString();
        }
      }

      setState(() {
        _taskId = foundTaskId;
      });

      // ابدأ polling للتأكد من حالة التصميم
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        _pollOnce();
      });

    } catch (e, st) {
      _pollTimer?.cancel();
      setState(() {
        _loading = false;
        _error = 'Process failed: $e';
      });
      debugPrint('Generate error: $e\n$st');
    }
  }

  Future<void> _pollOnce() async {
    try {
      if (_taskId == null) return;

      Uri uri = Uri.parse(_recordInfoUrl).replace(queryParameters: {
        'taskId': _taskId!,
      });

      final http.Response resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $_nanoBananaToken',
        'Content-Type': 'application/json',
      });

      if (resp.statusCode == 404) {
        debugPrint('record-info 404: task not found yet');
        return;
      }

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('record-info failed: ${resp.statusCode} ${resp.body}');
        return;
      }

      final dynamic decoded = jsonDecode(resp.body);
      if (decoded is! Map) return;

      final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
      Map<String, dynamic>? data;
      if (map.containsKey('data') && map['data'] is Map) {
        data = Map<String, dynamic>.from(map['data']);
      }

      int? successFlag;
      if (data != null && data.containsKey('successFlag')) {
        successFlag = int.tryParse(data['successFlag']?.toString() ?? '');
      }

      String? resultImageUrl;
      if (data != null && data.containsKey('response') && data['response'] is Map) {
        final responseMap = Map<String, dynamic>.from(data['response']);
        if (responseMap.containsKey('resultImageUrl')) {
          resultImageUrl = responseMap['resultImageUrl']?.toString();
        }
      }

      if (successFlag == 1 || resultImageUrl != null) {
        // نجاح عملية AI
        _pollTimer?.cancel();

        setState(() {
          _loading = false;
          _error = null;
          _resultImageUrl = resultImageUrl;
        });
        return;
      }

      // إذا كانت هناك حالة فشل على السيرفر
      if (successFlag != null && (successFlag == 2 || successFlag == 3)) {
        _pollTimer?.cancel();
        String errMsg = 'Generation failed on server.';
        if (data != null && data.containsKey('errorMessage')) {
          errMsg += ' ${data['errorMessage']}';
        }
        setState(() {
          _loading = false;
          _error = errMsg;
        });
        return;
      }

    } catch (e, st) {
      debugPrint('poll error: $e\n$st');
    }
  }

  // زر إعادة محاولة (retry)
  void _retry() {
    _pollTimer?.cancel();
    _startGenerateAndPoll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background المضبب التابع لتصميم الصفحة
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/1.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        _pollTimer?.cancel();
                        Navigator.pop(context);
                      },
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
                  'AI Design Result',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 14),

                // منطقة عرض النتائج بالتصميم الأصلي
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
                            // 1. عرض صورة الدخل (Picked Image) للمقارنة
                            const Text('Original Image:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 280,
                                child: kIsWeb
                                    ? (widget.webBytes != null
                                        ? Image.memory(widget.webBytes!, fit: BoxFit.cover)
                                        : _placeholderImage())
                                    : FutureBuilder<Uint8List>(
                                        future: widget.pickedImage.readAsBytes(),
                                        builder: (context, snap) {
                                          if (snap.connectionState != ConnectionState.done) return _loadingBox();
                                          if (!snap.hasData) return _placeholderImage();
                                          return Image.memory(snap.data!, fit: BoxFit.cover);
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text('Modification Request:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(widget.prompt, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 18),

                            // 2. منطقة عرض نتيجة AI (The modified image)
                            const Text('AI Modified Result:', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 10),
                            Container(
                              height: 320,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.18)),
                              ),
                              child: _buildResultArea(), // تعرض الـ Loading ثم الصورة النهائية
                            ),
                            const SizedBox(height: 14),

                            if (_taskId != null && _loading)
                              Text('Tracking ID: $_taskId', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // زر العودة التابع للتصميم الأصلي
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: SizedBox(
                      width: 180,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          _pollTimer?.cancel();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3C9A8),
                          foregroundColor: const Color(0xFF3B2A1E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('New Request', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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

  // دالة عرض منطقة النتيجة (Loading -> Error -> Success Image)
  Widget _buildResultArea() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Try Again'),
            )
          ],
        ),
      );
    }

    if (_loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          // عرض حالة تحميل تفصيلية (Uploading... Editing...)
          Text(_loadingStatus, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Processing... please wait', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
    }

    if (_resultImageUrl != null) {
      // نجاح: عرض الصورة النهائية بناءً على الرابط الشبكي القادم من AI
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          _resultImageUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (ctx, child, progress) {
            if (progress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (ctx, err, stack) {
            return const Center(child: Text("Failed to load result image", style: TextStyle(color: Colors.white70)));
          },
        ),
      );
    }

    // احتياط في حال لم يكن هناك نتيجة ولا تحميل
    return const Align(
      alignment: Alignment.center,
      child: Text(
        'AI final design will appear here.',
        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
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
      child: const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}