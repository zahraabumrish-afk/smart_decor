import 'dart:ui';
import 'package:flutter/material.dart';
import 'paths_screen.dart';
import '../main.dart';
import 'auth_screen.dart';
// هذا الاستيراد لنستطيع استدعاء setLocale()
// من أجل تبديل لغة التطبيق (AR / EN)

import '../core/localization/app_strings.dart';
// هذا الملف يحتوي على النصوص المترجمة
// ويعيد النص المناسب حسب اللغة الحالية للتطبيق

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // نستخدم Stack لأن الشاشة تحتوي على:
      // صورة خلفية + Overlay + Blur + محتوى فوقهم
        body: Stack(
          children: [

          // -------------------------------
          // 1) Background image
          // -------------------------------
          // صورة الخلفية التي تغطي الشاشة كاملة
          Image.asset(
          'assets/backgrounds/1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // -------------------------------
        // 2) Dark overlay
        // -------------------------------
        // طبقة شفافة سوداء لتغميق الخلفية
        Container(
          color: Colors.black.withOpacity(0.45),
        ),

        // -------------------------------
        // 3) Blur effect
        // -------------------------------
        // تأثير تمويه (Blur) فوق الخلفية
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.transparent),
        ),

        // -------------------------------
        // 4) Language switch button
        // -------------------------------
        // زر تبديل اللغة (أعلى اليمين)
        // AR: تحويل التطبيق للعربي
        // EN: تحويل التطبيق للإنكليزي
        // هذا الزر لا يؤثر على تصميم الشاشة
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // زر اللغة العربية
                    TextButton(
                      onPressed: () {
                        SmartDecorApp.setLocale(
                          context,
                          const Locale('ar'),
                        );
                      },
                      child: const Text(
                        'AR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const Text(
                      '|',
                      style: TextStyle(color: Colors.white70),
                    ),

                    // زر اللغة الإنكليزية
                    TextButton(
                      onPressed: () {
                        SmartDecorApp.setLocale(
                          context,
                          const Locale('en'),
                        );
                      },
                      child: const Text(
                        'EN',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // -------------------------------
        // 5) Main content (Logo + Text + Button)
        // -------------------------------
        SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                // Logo
                Image.asset(
                'assets/logo/logo.png',
                height: 220,
              ),const SizedBox(height: 24),

                  // App name (مترجم حسب اللغة)
                  Text(
                    AppStrings.of(context, 'appName'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phrase (سطرين – مترجمين)
                  Column(
                    children: [
                      Text(
                        AppStrings.of(context, 'taglineLine1'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.of(context, 'taglineLine2'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Login button -> PathsScreen
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC7A17A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        AppStrings.of(context, 'login'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
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