import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ✅ Backend
import 'package:smart_decor/features/style_quiz/data/repositories/room_session_repository.dart';

import 'style_quiz_apply_preview_screen.dart';

enum RoomAngle { front, right, left, back }

class StyleQuizUploadRoomImagesScreen extends StatefulWidget {
  final String styleTitle;
  final String designImageAssetPath;
  final List<String> paletteHex;

  // ✅ Optional: comes from Saved Design screen
  final String? sessionId;

  const StyleQuizUploadRoomImagesScreen({
    super.key,
    required this.styleTitle,
    required this.designImageAssetPath,
    required this.paletteHex,
    this.sessionId,
  });

  @override
  State<StyleQuizUploadRoomImagesScreen> createState() =>
      _StyleQuizUploadRoomImagesScreenState();
}

class _StyleQuizUploadRoomImagesScreenState
    extends State<StyleQuizUploadRoomImagesScreen> {
  final ImagePicker _picker = ImagePicker();

  final Map<RoomAngle, XFile?> _images = {
    RoomAngle.front: null,
    RoomAngle.right: null,
    RoomAngle.left: null,
    RoomAngle.back: null,
  };

  final Map<RoomAngle, Uint8List?> _bytes = {
    RoomAngle.front: null,
    RoomAngle.right: null,
    RoomAngle.left: null,
    RoomAngle.back: null,
  };

  // Colors (beige sandy)
  static const Color _sandBeige = Color(0xFFD8C3A5);
  static const Color _cardGlass = Color(0x33000000);
  static const Color _cardBorder = Color(0x22FFFFFF);

  bool get _allSelected => _bytes.values.every((b) => b != null);

  String _label(RoomAngle a) {
    switch (a) {
      case RoomAngle.front:
        return "front";
      case RoomAngle.right:
        return "right";
      case RoomAngle.left:
        return "left";
      case RoomAngle.back:
        return "back";
    }
  }

  Future<void> _pickImage(RoomAngle angle, ImageSource source) async {
    final XFile? img = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1800,
    );

    if (!mounted) return;

    if (img != null) {
      final Uint8List b = await img.readAsBytes();
      if (!mounted) return;

      setState(() {
        _images[angle] = img;
        _bytes[angle] = b;
      });
    }

    if (mounted) Navigator.pop(context);
  }

  void _showPickSheet(RoomAngle angle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414).withOpacity(0.94),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Add ${_label(angle)} photo",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                _sheetBtn(
                  icon: Icons.photo_camera_outlined,
                  text: "Camera",
                  onTap: () => _pickImage(angle, ImageSource.camera),
                ),
                const SizedBox(height: 10),
                _sheetBtn(
                  icon: Icons.photo_library_outlined,
                  text: "Gallery",
                  onTap: () => _pickImage(angle, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _continue() async {
    if (!_allSelected) return;// ✅ make them non-null (because _allSelected is true)
    final Uint8List front = _bytes[RoomAngle.front]!;
    final Uint8List right = _bytes[RoomAngle.right]!;
    final Uint8List left = _bytes[RoomAngle.left]!;
    final Uint8List back = _bytes[RoomAngle.back]!;

    // ✅ If sessionId exists => save to backend (SQLite + files)
    final String? sessionId = widget.sessionId;

    if (sessionId != null) {
      // Loading (no UI design change)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final repo = RoomSessionRepository();

        await repo.saveAnglePhoto(
          sessionId: sessionId,
          angleKey: 'front',
          bytes: front,
        );
        await repo.saveAnglePhoto(
          sessionId: sessionId,
          angleKey: 'right',
          bytes: right,
        );
        await repo.saveAnglePhoto(
          sessionId: sessionId,
          angleKey: 'left',
          bytes: left,
        );
        await repo.saveAnglePhoto(
          sessionId: sessionId,
          angleKey: 'back',
          bytes: back,
        );
      } catch (e) {
        // If Web or any DB error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not save locally (DB not available on Web). Continue without saving.\n$e',
              ),
            ),
          );
        }
      } finally {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // close loading
        }
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StyleQuizApplyPreviewScreen(
          styleTitle: widget.styleTitle,
          designImageAssetPath: widget.designImageAssetPath,
          paletteHex: widget.paletteHex,
          roomPhotosBytes: {
            'front': front,
            'right': right,
            'left': left,
            'back': back,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
      // Background
      Positioned.fill(
      child: Image.asset(
        'assets/backgrounds/1.jpg',
        fit: BoxFit.cover,
      ),
    ),

    // Light blur overlay
    Positioned.fill(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
    child: Container(color: Colors.black.withOpacity(0.08)),
    ),
    ),

    SafeArea(
    child: Stack(
    children: [
    // Back button
    Positioned(
    left: 12,
    top: 12,
    child: InkWell(
    onTap: () => Navigator.pop(context),
    borderRadius: BorderRadius.circular(18),
    child: Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
    ),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.30),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
    color: Colors.white.withOpacity(0.10),
    ),
    ),
    child: const Row(
    children: [
    Icon(
    Icons.arrow_back_ios_new,
    size: 16,
    color: Colors.white,
    ),
    SizedBox(width: 6),
    Text(
    "Back",
    style: TextStyle(
    color: Colors.white,fontWeight: FontWeight.w700,
    ),
    ),
    ],
    ),
    ),
    ),
    ),

      Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 74, 18, 18),
          child: Column(
            children: [
              const SizedBox(height: 6),
              const Text(
                "Upload Room Images",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Please add 4 photos from different angles",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),

              // ✅ تصغير + توسيط (بدون كارد إضافي تحت)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _grid(),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Continue واحد تحت بالوسط (مو بعرض الشاشة)
              Center(child: _bottomContinueBtn()),

              const SizedBox(height: 12),
            ],
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

  // ✅ مربعات أصغر لتظهر بالنص
  Widget _grid() {
    return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
        children: RoomAngle.values.map((a) {
          final Uint8List? b = _bytes[a];

          return InkWell(
              onTap: () => _showPickSheet(a),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                  decoration: BoxDecoration(
                    color: _cardGlass,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Center(
                      child: b == null
                          ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          const Icon(Icons.add,
                          color: Colors.white70, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        _label(a),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _sandBeige.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "Add Photo",style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                          ),
                      ),
                          ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          b,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          gaplessPlayback: true,
                        ),
                      ),
                  ),
              ),
          );
        }).toList(),
    );
  }

  Widget _sheetBtn({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: _sandBeige.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.black87, size: 20),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ زر Continue تحت بالوسط + يصير أوضح/أغمق لما تكملي 4 صور
  Widget _bottomContinueBtn() {
    final bool enabled = _allSelected;

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: SizedBox(
        width: 240,
        height: 48,
        child: ElevatedButton(
          onPressed: enabled ? _continue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _sandBeige.withOpacity(enabled ? 0.95 : 0.65),
            foregroundColor: Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Continue",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}