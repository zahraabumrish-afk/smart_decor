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

  // نتيجة الصورة: عادة URL حسب الوثائق
  String? _resultImageUrl;
  Uint8List? _resultImageBytes;

  Timer? _pollTimer;

  // ضع توكنك هنا
  static const String _apiToken = '';

  // endpoints
  static const String _generateUrl =
      'https://api.nanobananaapi.ai/api/v1/nanobanana/generate';
  static const String _recordInfoUrl =
      'https://api.nanobananaapi.ai/api/v1/nanobanana/record-info';

  @override
  void initState() {
    super.initState();
    _startGenerateAndPoll();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _startGenerateAndPoll() async {
    setState(() {
      _loading = true;
      _error = null;
      _taskId = null;
      _resultImageUrl = null;
      _resultImageBytes = null;
    });

    try {
      // 1) اقرأ بايتس الصورة (ويب أو موبايل)
      Uint8List imageBytes;

      if (widget.webBytes != null) {
        imageBytes = widget.webBytes!;
      } else {
        imageBytes = await widget.pickedImage.readAsBytes();
      }

      // 2) شفّر للـ base64
      final String imageBase64 = base64Encode(imageBytes);

      // 3) جهّز الـ body — عدّل الحقول وفق ما عمل معك سابقًا إذا لزم
      // ملاحظة: بعض الـ APIs قد تتطلب اسم حقل مختلف أو multipart؛ هذا مثال JSON مع image_base64
      final Map<String, dynamic> body = {
        'prompt': widget.prompt,
        'numImages': 1,
        // استخدم القيمة التي نجحت معك سلفًا (في حال واجهت خطأ قم بتعديل 'type' كما عندك)
        'type': 'TEXTTOIAMGE',
        'image_size': '16:9',
        'image_base64': imageBase64,
        // 'callBackUrl': 'https://your-callback-url.com/callback',
      };

      final http.Response resp = await http.post(
        Uri.parse(_generateUrl),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception(
            'Generate failed: ${resp.statusCode} — ${resp.body}');
      }

      final dynamic decoded = jsonDecode(resp.body);

      // احصل على taskId من أي مكان محتمل في الـ JSON
      final Map<String, dynamic> decodedMap =
          (decoded is Map) ? Map<String, dynamic>.from(decoded) : {};

      String? foundTaskId;

      // إحتمالات استخراج الـ task id من الاستجابة
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
      } else if (decodedMap.containsKey('id')) {
        foundTaskId = decodedMap['id']?.toString();
      } else if (decodedMap.containsKey('recordId')) {
        foundTaskId = decodedMap['recordId']?.toString();
      }

      // احتطاط: لو لم نجد taskId سنستعمل حقل 'data' أو 'id' إن وجد
      setState(() {
        _taskId = foundTaskId;
      });

      // ابدأ polling — حسب الوثائق endpoint يتطلب query param اسمه taskId
      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _pollOnce();
      });

    } catch (e, st) {
      _pollTimer?.cancel();
      setState(() {
        _loading = false;
        _error = 'Generate request failed: $e';
      });
      // طباعة للوحدة التطويرية
      debugPrint('Generate error: $e\n$st');
    }
  }

  Future<void> _pollOnce() async {
    try {
      // if no taskId, call without param (some installs may allow global check) — لكن docs تطلب taskId
      Uri uri;
      if (_taskId != null) {
        uri = Uri.parse(_recordInfoUrl).replace(queryParameters: {
          'taskId': _taskId!,
        });
      } else {
        uri = Uri.parse(_recordInfoUrl);
      }

      final http.Response resp = await http.get(uri, headers: {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
      });

      if (resp.statusCode == 404) {
        // لم يجد المهمة بعد
        debugPrint('record-info 404: task not found yet');
        return;
      }

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        // لا نلغي polling لمجرد خطأ مؤقت، لكن نعرض في الـ console
        debugPrint('record-info failed: ${resp.statusCode} ${resp.body}');
        return;
      }

      final dynamic decoded = jsonDecode(resp.body);
      if (decoded is! Map) {
        debugPrint('Unexpected record-info response format');
        return;
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);

      // الوثائق توضح بنية: { code, msg, data: { taskId, response: { originImageUrl, resultImageUrl }, successFlag, ... } }
      Map<String, dynamic>? data;
      if (map.containsKey('data') && map['data'] is Map) {
        data = Map<String, dynamic>.from(map['data']);
      }

      int? successFlag;
      if (data != null && data.containsKey('successFlag')) {
        final sf = data['successFlag'];
        if (sf is int) successFlag = sf;
        else {
          // قد يكون String
          successFlag = int.tryParse(sf?.toString() ?? '');
        }
      }

      // ابحث عن resultImageUrl داخل data.response.*
      String? resultImageUrl;
      String? originImageUrl;
      if (data != null && data.containsKey('response') && data['response'] is Map) {
        final responseMap = Map<String, dynamic>.from(data['response']);
        if (responseMap.containsKey('resultImageUrl')) {
          resultImageUrl = responseMap['resultImageUrl']?.toString();
        }
        if (responseMap.containsKey('originImageUrl')) {
          originImageUrl = responseMap['originImageUrl']?.toString();
        }
      }

      // إن وجد resultImageUrl أو successFlag == 1 نوقف polling ونعرض النتيجة
      final bool finished =
          (successFlag != null && successFlag == 1) || resultImageUrl != null;

      if (finished) {
        _pollTimer?.cancel();

        setState(() {
          _loading = false;
          _error = null;
          _resultImageUrl = resultImageUrl;
        });

        // بعض الحالات قد تعيد الصورة كـ base64 داخل response (نادر حسب docs)
        // لذا نحاول العثور على أي base64 داخل الحقول
        Uint8List? maybeBytes;
        // تحقق استدعاء أعمق (response may contain images list)
        if (data != null && data.containsKey('response')) {
          final respObj = data['response'];
          // محاولة استخراج base64 من عناصر images إن وُجدت
          if (respObj is Map) {
            final rmap = Map<String, dynamic>.from(respObj);
            if (rmap.containsKey('images') && rmap['images'] is List) {
              final list = rmap['images'] as List;
              if (list.isNotEmpty) {
                final first = list[0];
                if (first is String) {
                  // قد تكون data url أو base64
                  if (first.startsWith('data:')) {
                    final comma = first.indexOf(',');
                    if (comma != -1) {
                      final base64part = first.substring(comma + 1);
                      try {
                        maybeBytes = base64Decode(base64part);
                      } catch (_) {}
                    }
                  } else {
                    try {
                      maybeBytes = base64Decode(first);
                    } catch (_) {}
                  }
                }
              }
            }
          }
        }

        if (maybeBytes != null) {
          setState(() => _resultImageBytes = maybeBytes);
        }

        return;
      }

      // إذا كانت هناك حالة فشل (successFlag == 2 أو 3) اعرض خطأ
      if (successFlag != null && (successFlag == 2 || successFlag == 3)) {
        _pollTimer?.cancel();
        String errMsg = 'Generation failed (status $successFlag).';
        if (data != null && data.containsKey('errorMessage')) {
          errMsg += ' ${data['errorMessage']}';
        }
        setState(() {
          _loading = false;
          _error = errMsg;
        });
        return;
      }

      // بخلاف ذلك ننتظر next poll
    } catch (e, st) {
      debugPrint('poll error: $e\n$st');
      // لا نلغي polling؛ لكن اذا أردت يمكنك إلغاء بعد عدة محاولات
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
                  'Result',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 14),

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
                            // preview original image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: SizedBox(
                                height: 300,
                                child: kIsWeb
                                    ? (widget.webBytes != null
                                        ? Image.memory(widget.webBytes!, fit: BoxFit.cover)
                                        : _placeholderImage())
                                    : FutureBuilder<Uint8List>(
                                        future: widget.pickedImage.readAsBytes(),
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
                            const Text('Your request:',
                                style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(widget.prompt.isEmpty ? '(No text entered)' : widget.prompt,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 14),

                            // result area
                            Container(
                              height: 320,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.18)),
                              ),
                              child: _buildResultArea(),
                            ),
                            const SizedBox(height: 14),

                            // عرض بعض بيانات الحالة
                            if (_taskId != null)
                              Text('taskId: $_taskId', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            if (_loading)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text('Processing...', style: TextStyle(color: Colors.white70)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

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
                        child: const Text('Back to Chat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
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

  Widget _buildResultArea() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _retry,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text('Processing... please wait', style: TextStyle(color: Colors.white70)),
        ],
      );
    }

    if (_resultImageBytes != null) {
      return Image.memory(_resultImageBytes!, fit: BoxFit.contain);
    }

    if (_resultImageUrl != null) {
      return Image.network(_resultImageUrl!, fit: BoxFit.contain);
    }

    return const Align(
      alignment: Alignment.topLeft,
      child: Text(
        'AI result will appear here later.\n(Waiting for the server result)',
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