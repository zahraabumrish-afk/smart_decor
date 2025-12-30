import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'room_type_screen.dart';

enum RoomAngle { front, right, left, back }

class UploadPhotoScreen extends StatefulWidget {
  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();

  // 4 images (one per angle)
  final Map<RoomAngle, XFile?> _images = {
    RoomAngle.front: null,
    RoomAngle.right: null,
    RoomAngle.left: null,
    RoomAngle.back: null,
  };

  // Your design colors (same style)
  static const Color _btnBg = Color(0xFFE5C9A8);
  static const Color _btnFg = Color(0xFF3B2A1E);

  bool get _allSelected => _images.values.every((x) => x != null);

  String _label(RoomAngle a) {
    switch (a) {
      case RoomAngle.front:
        return "Front";
      case RoomAngle.right:
        return "Right";
      case RoomAngle.left:
        return "Left";
      case RoomAngle.back:
        return "Back";
    }
  }

  IconData _icon(RoomAngle a) {
    switch (a) {
      case RoomAngle.front:
        return Icons.crop_portrait;
      case RoomAngle.right:
        return Icons.chevron_right;
      case RoomAngle.left:
        return Icons.chevron_left;
      case RoomAngle.back:
        return Icons.flip_camera_android;
    }
  }

  Future<void> _pick(RoomAngle angle, ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (!mounted) return;
      if (file == null) return;

      setState(() => _images[angle] = file);
    } catch (_) {
      // keep silent (no crash)
    }
  }

  void _showPickSheet(RoomAngle angle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add ${_label(angle)} Photo",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _sheetBtn(
                icon: Icons.photo_camera,
                text: "Camera",
                onTap: () {
                  Navigator.pop(context);
                  _pick(angle, ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _sheetBtn(
                icon: Icons.photo_library,
                text: "Gallery",
                onTap: () {
                  Navigator.pop(context);
                  _pick(angle, ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetBtn({required IconData icon, required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _btnBg,
          foregroundColor: _btnFg,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  void _continue() {
    if (!_allSelected) return;

    // IMPORTANT: we keep your current flow (no params to avoid red lines)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoomTypeScreen()),
    );
  }@override
  Widget build(BuildContext context) {return Scaffold(
    body: Stack(
      children: [
        // Background image
        Image.asset(
          'assets/backgrounds/1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // Blur overlay
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),

        // Back button (same as your style)
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
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
        ),

        // Content
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 18),
                  const Text(
                    "Upload Room Images",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Please add 4 photos from different angles",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.88),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // 2x2 grid
                  _grid(),

                  const SizedBox(height: 18),

                  // Continue button
                  SizedBox(
                    width: 280,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _allSelected ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _btnBg,
                        foregroundColor: _btnFg,
                        disabledBackgroundColor: _btnBg.withOpacity(0.45),
                        disabledForegroundColor: _btnFg.withOpacity(0.55),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_allSelected ? Icons.check_circle : Icons.lock),
                          const SizedBox(width: 10),
                          Text(_allSelected ? "Continue" : "Add all 4 photos"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }Widget _grid() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: Column(
        children: [Row(
          children: [
            Expanded(child: _tile(RoomAngle.front)),
            const SizedBox(width: 12),
            Expanded(child: _tile(RoomAngle.right)),
          ],
        ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _tile(RoomAngle.left)),
              const SizedBox(width: 12),
              Expanded(child: _tile(RoomAngle.back)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(RoomAngle angle) {
    final file = _images[angle];

    return InkWell(
      onTap: () => _showPickSheet(angle),
      borderRadius: BorderRadius.circular(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Stack(
            children: [
              if (file != null)
                Positioned.fill(
                  child: Image.network(
                    file.path, // works on web + shows instantly
                    fit: BoxFit.cover,
                  ),
                ),

              // dark overlay for readability
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(file != null ? 0.12 : 0.18)),
              ),

              // center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      file != null ? Icons.check_circle : Icons.add_circle_outline,
                      color: Colors.white,
                      size: 34,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _label(angle),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Icon(_icon(angle), color: Colors.white.withOpacity(0.85), size: 18),
                  ],
                ),
              ),

              // small edit hint bottom
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _btnBg.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(file != null ? Icons.edit : Icons.upload, size: 16, color: _btnFg),
                      const SizedBox(width: 8),
                      Text(
                        file != null ? "Change" : "Add Photo",
                        style: const TextStyle(color: _btnFg, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}