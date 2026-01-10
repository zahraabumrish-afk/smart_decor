import 'dart:ui';
import 'package:flutter/material.dart';

import 'style_quiz_room_types_screen.dart';
import 'style_quiz_preview_screen.dart';
class StyleQuizGalleryScreen extends StatelessWidget {
  final String styleId; // classic / modern / vintage / modern_mix
  final String styleTitle;
  final RoomType roomType;
  final String backgroundAssetPath;

  const StyleQuizGalleryScreen({
    super.key,
    required this.styleId,
    required this.styleTitle,
    required this.roomType,
    required this.backgroundAssetPath,
  });

  static const Color _sandBeige = Color(0xFFE6D3A3);

  List<String> _paths() {
    // 10 صور: 1.jpg .. 10.jpg
    return List.generate(
      10,
          (i) => 'assets/rooms/$styleId/${roomType.key}/${i + 1}.jpg',
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _paths();

    return Scaffold(
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Image.asset(
              backgroundAssetPath,
              fit: BoxFit.cover,
            ),
          ),

          // blur + overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                color: Colors.black.withOpacity(0.30),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BackPill(onTap: () => Navigator.pop(context)),
                  const SizedBox(height: 14),

                  Text(
                    '${roomType.title} Gallery',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose a design',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Expanded(
                    child: GridView.builder(
                      itemCount: images.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final path = images[index];
                        final label = 'Design ${index + 1}';

                        return _GalleryItem(
                          imagePath: path,
                          label: label,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StyleQuizPreviewScreen(
                                  title: styleTitle,                  // أو إذا بدك: '$styleTitle Style'
                                  selectedImageAsset: path,           // الصورة اللي كبستي عليها
                                  backgroundAssetPath: backgroundAssetPath, // نفس خلفية الجيليري
                                ),
                              ),
                            );
                          },
                        );
                      },
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

class _GalleryItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const _GalleryItem({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
                fit: StackFit.expand,
                children: [
                Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                      color: Colors.black.withOpacity(0.15),
                    alignment: Alignment.center,
                    child: Text(
                      'Missing\n${imagePath.split('/').last}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                      ),
                    ),
                  );
                },
                ),
                ],
            ),
        ),
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