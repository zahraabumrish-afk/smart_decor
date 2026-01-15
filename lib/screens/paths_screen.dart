import 'dart:ui';
import 'package:flutter/material.dart';

import 'upload_photo_screen.dart';
import 'package:smart_decor/features/style_quiz/screens/style_quiz_intro_screen.dart';
import '../app_routes.dart';

class PathsScreen extends StatelessWidget {
  const PathsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Image.asset(
            'assets/backgrounds/1.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top back
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topLeft,
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

                const Spacer(),

                const Text(
                  'Welcome, we are here for you',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                // Buttons
                _PathButton(
                  icon: Icons.image_outlined,
                  text: 'Upload Image',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UploadPhotoScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                _PathButton(
                  icon: Icons.quiz_outlined,
                  text: 'Style Quiz',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StyleQuizIntroScreen()
                        ),
                      );
                    },


                ),
                const SizedBox(height: 12),

                _PathButton(
                  icon: Icons.auto_awesome_outlined,
                  text: 'AI Design',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.designRequestUpload);
                  },
                ),

                const Spacer(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PathButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _PathButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 280,
        height: 56,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF3C9A8),
            foregroundColor: const Color(0xFF3B2A1E),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(icon, size: 20),const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
          ),
        ),
    );
  }
}