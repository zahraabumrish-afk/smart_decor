import 'dart:ui';
import 'package:flutter/material.dart';
import 'gallery_screen.dart';

class RoomTypeScreen extends StatelessWidget {
  final String? userImagePath;

  const RoomTypeScreen({super.key, this.userImagePath});

  List<String> _roomImages(String folder) {
    // 6 images as assets: 1.jpg .. 10.jpg
    return List.generate(10, (i) => 'assets/$folder/${i + 1}.jpg');
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
          Container(color: Colors.black.withOpacity(0.40)),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.transparent),
          ),

          // Back button
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Choose Room Type',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 22),

                  _RoomButton(
                    text: 'Living Room',
                    icon: Icons.weekend_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryScreen(
                            title: 'Living Room Gallery',
                            images: _roomImages('living_room'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _RoomButton(
                    text: 'Kitchen',
                    icon: Icons.kitchen_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryScreen(
                            title: 'Kitchen Gallery',
                            images: _roomImages('kitchen'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _RoomButton(
                    text: 'Office',
                    icon: Icons.business_center_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryScreen(
                            title: 'Office Gallery',
                            images: _roomImages('office'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),_RoomButton(
                    text: 'Master Bedroom',
                    icon: Icons.bed_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryScreen(
                            title: 'Master Bedroom Gallery',
                            images: _roomImages('master_bedroom'),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  _RoomButton(
                    text: 'Kids Bedroom',
                    icon: Icons.child_care_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GalleryScreen(
                            title: 'Kids Bedroom Gallery',
                            images: _roomImages('kids_bedroom'),
                          ),
                        ),
                      );
                    },
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

class _RoomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _RoomButton({
    required this.text,
    required this.icon,
    required this.onTap,
  });@override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE3C9A8),
          foregroundColor: const Color(0xFF3B2A1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}