import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'style_quiz_generate_screen.dart';

class StyleQuizPreviewScreen extends StatefulWidget {
  const StyleQuizPreviewScreen({
    super.key,
    required this.title,
    required this.selectedImageAsset,
    required this.backgroundAssetPath,
    this.prompt,
  });

  final String title;
  final String selectedImageAsset;
  final String backgroundAssetPath;
  final String? prompt;

  @override
  State<StyleQuizPreviewScreen> createState() => _StyleQuizPreviewScreenState();
}

class _StyleQuizPreviewScreenState extends State<StyleQuizPreviewScreen> {
  // --- الكيانات والمفاتيح ---
  static const String _imgBBKey = ''; // 👈 ضع مفتاح ImgBB هنا
  static const String _nanoBananaToken = '';
  
  static const String _nanoGenerateUrl = 'https://api.nanobananaapi.ai/api/v1/nanobanana/generate';
  static const String _nanoRecordUrl = 'https://api.nanobananaapi.ai/api/v1/nanobanana/record-info';

  bool _isGenerating = false;
  String? _taskId;
  Timer? _pollTimer;
  String _loadingStatus = "Preparing Request...";

  final List<Color> _palette = const [
    Color(0xFFE6D3A3), Color(0xFFD8C3A5), Color(0xFFCBB39B),
    Color(0xFFBFA78F), Color(0xFFA58E7C), Color(0xFF8E7D72),
    Color(0xFF6F6A63), Color(0xFF4D4A46), Color(0xFF2E2B28),
    Color(0xFF9FB3A5), Color(0xFFB9C7D4), Color(0xFFE2C9CF),
  ];

  int _selectedColorIndex = 0;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  // 1. رفع الصورة إلى ImgBB للحصول على رابط صالح لـ NanoBanana
  Future<String> _uploadToImgBB(String assetPath) async {
    setState(() => _loadingStatus = "Uploading Image...");
    ByteData bytes = await rootBundle.load(assetPath);
    String base64Image = base64Encode(Uint8List.view(bytes.buffer));

    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {'key': _imgBBKey, 'image': base64Image},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']['url'];
    } else {
      throw Exception("Image upload failed");
    }
  }

  // 2. بدء عملية التوليد
  Future<void> _handleGeneratePress() async {
    setState(() {
      _isGenerating = true;
      _loadingStatus = "Reading Image...";
    });

    try {
      // رفع الصورة أولاً لحل مشكلة blank imageUrls
      final String publicUrl = await _uploadToImgBB(widget.selectedImageAsset);

      final String enhancedPrompt = "${widget.prompt ?? ""} . "
          "Please modify this image based on the description, keeping the original structure "
          "and applying professional style and colors.";

      setState(() => _loadingStatus = "AI is thinking...");

      final resp = await http.post(
        Uri.parse(_nanoGenerateUrl),
        headers: {
          'Authorization': 'Bearer $_nanoBananaToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': enhancedPrompt,
          'numImages': 1,
          'type': 'IMAGETOIAMGE', 
          'imageUrls': [publicUrl], // ✅ إرسال الرابط بدلاً من base64
          'image_size': '16:9',
          'callBackUrl': 'https://dummy-callback.com/api', 
        }),
      );

      final decoded = jsonDecode(resp.body);

      if (decoded['code'] == 200) {
        _taskId = decoded['data']['taskId']?.toString();
        _startPolling();
      } else {
        throw Exception(decoded['msg'] ?? "Server Error");
      }
    } catch (e) {
      _resetStateWithError("Error: $e");
    }
  }

  void _startPolling() {
    setState(() => _loadingStatus = "AI is editing...");
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_taskId == null) return;
    try {
      final uri = Uri.parse(_nanoRecordUrl).replace(queryParameters: {'taskId': _taskId});
      final resp = await http.get(uri, headers: {'Authorization': 'Bearer $_nanoBananaToken'});

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['data'];
        final int? successFlag = int.tryParse(data['successFlag']?.toString() ?? '');

        if (successFlag == 1) {
          _pollTimer?.cancel();
          String? resultUrl = data['response']?['resultImageUrl'];
          if (resultUrl != null) {
            _navigateToResult(resultUrl);
          }
        } else if (successFlag == 2 || successFlag == 3) {
          _pollTimer?.cancel();
          _resetStateWithError("Server side failure");
        }
      }
    } catch (e) { debugPrint("Poll error: $e"); }
  }

  void _navigateToResult(String imageUrl) {
    setState(() => _isGenerating = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StyleQuizGenerateScreen(
          title: widget.title,
          selectedImageAsset: widget.selectedImageAsset,
          backgroundAssetPath: widget.backgroundAssetPath,
          selectedColor: _palette[_selectedColorIndex],
          generatedImageUrl: imageUrl,
        ),
      ),
    );
  }

  void _resetStateWithError(String message) {
    _pollTimer?.cancel();
    setState(() => _isGenerating = false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Generation Issue"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. الخلفية الأصلية
          Positioned.fill(
            child: Image.asset(widget.backgroundAssetPath, fit: BoxFit.cover),
          ),
          // 2. التضبيب (Blur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.18)),
            ),
          ),
          // 3. المحتوى الأساسي بالتصميم القديم
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackPill(onTap: () => Navigator.pop(context)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(widget.selectedImageAsset, fit: BoxFit.cover),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    color: _palette[_selectedColorIndex].withOpacity(0.18),
                                  ),
                                ),
                                // Loading Overlay التابع للتصميم القديم
                                if (_isGenerating)
                                  Container(
                                    color: Colors.black87,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircularProgressIndicator(color: Colors.white),
                                          const SizedBox(height: 16),
                                          Text(
                                            _loadingStatus,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Color Preview (Concept)',
                    style: TextStyle(color: Colors.white.withOpacity(0.90), fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  // باليتة الألوان الأصلية
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(_palette.length, (i) {
                            final isSelected = i == _selectedColorIndex;
                            return GestureDetector(
                              onTap: _isGenerating ? null : () => setState(() => _selectedColorIndex = i),
                              child: Container(
                                width: 22, height: 22,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _palette[i],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white24,
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // الزر الأصلي مع المنطق الجديد
                  SizedBox(
                    width: 260, height: 50,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _handleGeneratePress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD8C3A5).withOpacity(0.95),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isGenerating
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black87))
                          : const Text('Generate AI Design', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// الـ Widget المساعد للرجوع كما في كودك الأصلي
class _BackPill extends StatelessWidget {
  const _BackPill({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text('Back', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}