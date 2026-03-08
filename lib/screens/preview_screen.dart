import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// -------------------- In-memory store --------------------
class SavedDesign {
  final String id;
  final String imagePath; // صورة العفش الأصلية
  final String? resultImageUrl; // الصورة المولدة من الذكاء الاصطناعي
  final String title;
  final Color? overlayColor;
  final DateTime savedAt;

  SavedDesign({
    required this.id,
    required this.imagePath,
    this.resultImageUrl,
    required this.title,
    required this.overlayColor,
    required this.savedAt,
  });
}

class SavedDesignsStore extends ChangeNotifier {
  SavedDesignsStore._();
  static final SavedDesignsStore instance = SavedDesignsStore._();

  final List<SavedDesign> _items = [];

  List<SavedDesign> get items => List.unmodifiable(_items);

  void add(SavedDesign design) {
    _items.insert(0, design);
    notifyListeners();
  }

  void removeById(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

/// -------------------- Preview Screen --------------------
class PreviewScreen extends StatefulWidget {
  final String imagePath; // Furniture asset
  final String title;
  final XFile? frontImage; // Empty room image

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.title,
    this.frontImage,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Color? _overlayColor;

  final List<Color?> _colors = const [
    null,
    Color(0xFFF2EFEA),
    Color(0xFFE6D1B5),
    Color(0xFFD7BFA3),
    Color(0xFFB08B6E),
    Color(0xFFB7C4A0),
    Color(0xFF7C8B6F),
    Color(0xFF3E4A40),
    Color(0xFFBFC2C6),
    Color(0xFFD6B7C9),
    Color(0xFFB7C7D9),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(widget.imagePath, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withOpacity(0.30)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BackPill(onTap: () => Navigator.pop(context)),
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 720,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          widget.imagePath,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (_overlayColor != null)
                                        Positioned.fill(
                                          child: Container(
                                            color: _overlayColor!.withOpacity(0.18),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Color Preview (Concept)",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              itemCount: _colors.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final c = _colors[index];
                                final selected =
                                    (c == null && _overlayColor == null) ||
                                    (c != null && _overlayColor != null && c.value == _overlayColor!.value);

                                return GestureDetector(
                                  onTap: () => setState(() => _overlayColor = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: c ?? Colors.transparent,
                                      border: Border.all(
                                        color: selected ? Colors.white : Colors.white24,
                                        width: selected ? 2.2 : 1.2,
                                      ),
                                    ),
                                    child: c == null
                                        ? const Icon(Icons.close, size: 18, color: Colors.white)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 360,
                            height: 52,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE6D1B5),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.auto_awesome_outlined),
                              label: const Text(
                                "Generate AI Design",
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              onPressed: () {
                                if (widget.frontImage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Room image (frontImage) is missing!')),
                                  );
                                  return;
                                }
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AiIntegrationResultScreen(
                                      furnitureAssetPath: widget.imagePath,
                                      roomImageFile: widget.frontImage!,
                                      title: widget.title,
                                      overlayColor: _overlayColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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

/// -------------------- AI Integration Screen --------------------
class AiIntegrationResultScreen extends StatefulWidget {
  final String furnitureAssetPath;
  final XFile roomImageFile;
  final String title;
  final Color? overlayColor;

  const AiIntegrationResultScreen({
    super.key,
    required this.furnitureAssetPath,
    required this.roomImageFile,
    required this.title,
    this.overlayColor,
  });

  @override
  State<AiIntegrationResultScreen> createState() => _AiIntegrationResultScreenState();
}

class _AiIntegrationResultScreenState extends State<AiIntegrationResultScreen> {
  bool _loading = true;
  String _statusMessage = "Initializing...";
  String? _error;
  String? _resultImageUrl;
  String? _taskId;
  Timer? _pollTimer;
  
  Uint8List? _roomImageBytes;

  static const String _imgBBKey = '';
  static const String _nanoBananaToken = '';
  static const String _generateUrl = 'https://api.nanobananaapi.ai/api/v1/nanobanana/generate';
  static const String _recordInfoUrl = 'https://api.nanobananaapi.ai/api/v1/nanobanana/record-info';

  @override
  void initState() {
    super.initState();
    _startProcess();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<String> _uploadToImgBB(Uint8List bytes) async {
    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload'),
      body: {'key': _imgBBKey, 'image': base64Encode(bytes)},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']['url'];
    }
    throw Exception("Image upload failed");
  }

  Future<void> _startProcess() async {
    setState(() {
      _loading = true;
      _error = null;
      _statusMessage = "Loading images...";
    });

    try {
      // 1. قراءة بايتات الغرفة والعفش
      _roomImageBytes = await widget.roomImageFile.readAsBytes();
      final ByteData furnitureData = await rootBundle.load(widget.furnitureAssetPath);
      final Uint8List furnitureBytes = furnitureData.buffer.asUint8List();

      // 2. رفع الصورتين إلى الكلاود للحصول على روابط
      setState(() => _statusMessage = "Uploading room image...");
      final String roomUrl = await _uploadToImgBB(_roomImageBytes!);

      setState(() => _statusMessage = "Uploading furniture image...");
      final String furnitureUrl = await _uploadToImgBB(furnitureBytes);

      // 3. تجهيز البرومت باللغة الإنجليزية لعملية الدمج
      const String mergePrompt = 
          "Photorealistic interior design. Seamlessly merge and composite the furniture item "
          "(from the second image) into the empty room (from the first image). Ensure realistic "
          "proportions, accurate perspective, and natural lighting and shadows. The final result "
          "should look like a cohesive, professionally designed space.";

      setState(() => _statusMessage = "AI is designing the space...");

      // إرسال الصورتين ضمن مصفوفة
      final Map<String, dynamic> body = {
        'prompt': mergePrompt,
        'numImages': 1,
        'type': 'IMAGETOIAMGE', 
        'imageUrls': [roomUrl, furnitureUrl], 
        'image_size': '16:9',
        'callBackUrl': 'https://dummy-callback.com/api',
      };

      final response = await http.post(
        Uri.parse(_generateUrl),
        headers: {
          'Authorization': 'Bearer $_nanoBananaToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 300) throw Exception('API Error: ${response.body}');

      final decodedMap = Map<String, dynamic>.from(jsonDecode(response.body));
      String? foundTaskId;
      if (decodedMap.containsKey('taskId')) foundTaskId = decodedMap['taskId']?.toString();
      else if (decodedMap['data'] is Map) foundTaskId = decodedMap['data']['taskId']?.toString() ?? decodedMap['data']['id']?.toString();

      setState(() => _taskId = foundTaskId);

      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollOnce());

    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Error: $e";
      });
    }
  }

  Future<void> _pollOnce() async {
    if (_taskId == null) return;
    try {
      Uri uri = Uri.parse(_recordInfoUrl).replace(queryParameters: {'taskId': _taskId!});
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $_nanoBananaToken',
        'Content-Type': 'application/json',
      });

      if (response.statusCode >= 300) return;

      final data = jsonDecode(response.body)['data'];
      if (data == null || data is! Map) return;

      int? successFlag = int.tryParse(data['successFlag']?.toString() ?? '');
      String? resultImageUrl = data['response']?['resultImageUrl']?.toString();

      if (successFlag == 1 || resultImageUrl != null) {
        _pollTimer?.cancel();
        setState(() {
          _loading = false;
          _resultImageUrl = resultImageUrl;
        });
      } else if (successFlag == 2 || successFlag == 3) {
        _pollTimer?.cancel();
        setState(() {
          _loading = false;
          _error = 'AI Generation failed on server.';
        });
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  void _saveDesign() {
    if (_resultImageUrl == null) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    SavedDesignsStore.instance.add(
      SavedDesign(
        id: id,
        imagePath: widget.furnitureAssetPath,
        resultImageUrl: _resultImageUrl,
        title: "AI Room - ${widget.title}",
        overlayColor: widget.overlayColor,
        savedAt: DateTime.now(),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SavedDesignsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/backgrounds/1.jpg', fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(color: Colors.black87)),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withOpacity(0.40)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BackPill(onTap: () {
                      _pollTimer?.cancel();
                      Navigator.pop(context);
                    }),
                  ),
                ),
                const Text(
                  "AI Room Integration",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 720,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Inputs Section
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("Empty Room", style: TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: _roomImageBytes == null
                                              ? Container(color: Colors.black26)
                                              : Image.memory(_roomImageBytes!, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.add, color: Colors.white54),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("Furniture", style: TextStyle(color: Colors.white70)),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: SizedBox(
                                          height: 120,
                                          width: double.infinity,
                                          child: Image.asset(widget.furnitureAssetPath, fit: BoxFit.cover),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text("Final Result", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),

                            // 2. Result Section
                            Container(
                              height: 300,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: _buildResultArea(),
                            ),
                            const SizedBox(height: 20),

                            // 3. Save Button
                            if (_resultImageUrl != null)
                              SizedBox(
                                height: 50,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE6D1B5),
                                    foregroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  icon: const Icon(Icons.bookmark_add_outlined),
                                  label: const Text("Save Design", style: TextStyle(fontWeight: FontWeight.w800)),
                                  onPressed: _saveDesign,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
            TextButton(onPressed: _startProcess, child: const Text("Retry"))
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
          Text(_statusMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      );
    }
    if (_resultImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(_resultImageUrl!, fit: BoxFit.cover),
      );
    }
    return const SizedBox.shrink();
  }
}

/// -------------------- Saved Designs Screen --------------------
class SavedDesignsScreen extends StatefulWidget {
  const SavedDesignsScreen({super.key});

  @override
  State<SavedDesignsScreen> createState() => _SavedDesignsScreenState();
}

class _SavedDesignsScreenState extends State<SavedDesignsScreen> {
  @override
  void initState() {
    super.initState();
    SavedDesignsStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    SavedDesignsStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final items = SavedDesignsStore.instance.items;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/1.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BackPill(onTap: () => Navigator.pop(context)),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Saved Designs',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: Text('No saved designs yet.', style: TextStyle(color: Colors.white70)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final d = items[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: 600,
                                      height: 420,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: d.resultImageUrl != null 
                                            ? Image.network(d.resultImageUrl!, fit: BoxFit.cover)
                                            : Image.asset(d.imagePath, fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  if (d.overlayColor != null)
                                    Positioned.fill(
                                      child: Container(color: d.overlayColor!.withOpacity(0.18)),
                                    ),
                                  Positioned(
                                    left: 12,
                                    right: 12,
                                    bottom: 10,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            d.title,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => SavedDesignsStore.instance.removeById(d.id),
                                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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

/// -------------------- UI helper --------------------
class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  const _BackPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text("Back", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}