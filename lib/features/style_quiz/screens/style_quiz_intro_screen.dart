import 'package:flutter/material.dart';

import 'style_quiz_question_screen.dart';

class StyleQuizIntroScreen extends StatelessWidget {
  const StyleQuizIntroScreen({super.key});

  // نفس لون زر Login عندك (بني رملي)
  static const Color _sand = Color(0xFFC7A17A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (بدون blur)
          Image.asset(
            'assets/backgrounds/1.jpg',
            fit: BoxFit.cover,
          ),

          // Overlay خفيف جداً فقط لحتى النص يبين (مو تغبيش)
          Container(color: Colors.black.withOpacity(0.12)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button (pill صغيرة)
                  _BackPill(
                    onTap: () => Navigator.pop(context),
                  ),

                  const Spacer(),

                  // Title block (يسار تحت)
                  Text(
                    'Style Quiz',
                    style: TextStyle(
                      color: _sand, // بني رملي مثل ما بدك
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      shadows: const [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.black38,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Answer a few visual questions and we will discover your interior design style.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tags (صغار مثل قبل)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _TagChip('5 Questions'),
                      _TagChip('Rooms'),
                      _TagChip('Colors'),
                      _TagChip('Furniture'),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Start button (بنص الشاشة تحت)
                  Center(
                    child: SizedBox(
                      width: 320,
                      height: 46,
                      child: _PrimaryButton(
                        label: 'Start Quiz',
                        background: _sand,
                        border: _sand.withOpacity(0.25),
                        textColor: Colors.black, // ✅ نص أسود
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StyleQuizQuestionScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- UI Components ----------------

class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  const _BackPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.28),
              borderRadius: BorderRadius.circular(999),border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.arrow_back, size: 18, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.background,
    required this.border,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],


          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}