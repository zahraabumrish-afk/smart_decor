import 'dart:ui';
import 'package:flutter/material.dart';

import '../data/style_quiz_data.dart';
import '../models/style_quiz_models.dart';
import 'style_quiz_result_screen.dart';

class StyleQuizQuestionScreen extends StatefulWidget {
  const StyleQuizQuestionScreen({super.key});

  @override
  State<StyleQuizQuestionScreen> createState() =>
      _StyleQuizQuestionScreenState();
}

class _StyleQuizQuestionScreenState extends State<StyleQuizQuestionScreen> {
  int _index = 0;

  // نخزن styleId لكل سؤال
  late final List<String?> _pickedStyleIds;

  int? _selectedOptionIndex; // لتحديد صورة واحدة فقط
  String? _selectedStyleId;

  // ألواننا المتفق عليها
  static const Color _sand = Color(0xFFDCC7A1);
  static const Color _black = Color(0xFF111111);

  @override
  void initState() {
    super.initState();
    _pickedStyleIds =
    List<String?>.filled(StyleQuizData.questions.length, null);
  }

  // اختيار صورة واحدة فقط
  void _onSelect(int optionIndex, String styleId) {
    setState(() {
      _selectedOptionIndex = optionIndex;
      _selectedStyleId = styleId;
    });
  }

  void _onNext() {
    if (_selectedStyleId == null) return;

    _pickedStyleIds[_index] = _selectedStyleId;

    final isLast = _index == StyleQuizData.questions.length - 1;

    if (isLast) {
      final picked = _pickedStyleIds.whereType<String>().toList();
      final result = StyleQuizData.calculateResult(picked);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StyleQuizResultScreen(result: result),
        ),
      );
      return;
    }

    setState(() {
      _index++;
      _selectedStyleId = _pickedStyleIds[_index];
      _selectedOptionIndex = null; // مهم جداً
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = StyleQuizData.questions[_index];
    final total = StyleQuizData.questions.length;
    final isLast = _index == total - 1;

    return Scaffold(
      body: Stack(
        children: [
      Positioned.fill(
      child: Image.asset(
        'assets/backgrounds/1.jpg',
        fit: BoxFit.cover,
      ),
    ),

    SafeArea(
    child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
    children: [
    Align(
    alignment: Alignment.centerLeft,
    child: InkWell(
    borderRadius: BorderRadius.circular(24),
    onTap: () => Navigator.pop(context),
    child: Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.35),
    borderRadius: BorderRadius.circular(24),
    border:
    Border.all(color: Colors.white.withOpacity(0.20)),
    ),
    child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Icon(Icons.arrow_back,
    color: Colors.white, size: 18),
    SizedBox(width: 6),
    Text('Back',
    style: TextStyle(color: Colors.white)),
    ],
    ),
    ),
    ),
    ),

    const SizedBox(height: 14),

    Expanded(
    child: Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(18),
    border:
    Border.all(color: Colors.white.withOpacity(0.25)),),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    question.title,
    style: const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: _sand,
    ),
    ),
    const SizedBox(height: 6),
    Text(
    question.subtitle,
    style: const TextStyle(
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: _black,
    ),
    ),
    const SizedBox(height: 14),

    Expanded(
    child: GridView.builder(
    itemCount: question.options.length,
    gridDelegate:
    const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.65,
    ),
    itemBuilder: (context, i) {
    final opt = question.options[i];
    final selected =
    _selectedOptionIndex == i;

    return InkWell(
    onTap: () => _onSelect(i, opt.styleId),
    borderRadius: BorderRadius.circular(16),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Stack(
    children: [
    Positioned.fill(
    child: Image.asset(
    opt.assetPath,
    fit: BoxFit.cover,
    ),
    ),

    Positioned.fill(
    child: AnimatedContainer(
    duration: const Duration(
    milliseconds: 160),
    color: selected
    ? Colors.black.withOpacity(0.25)
        : Colors.black.withOpacity(0.08),
    ),
    ),

    Positioned.fill(
    child: AnimatedContainer(
    duration: const Duration(
    milliseconds: 160),
    decoration: BoxDecoration(
    borderRadius:
    BorderRadius.circular(16),
    border: Border.all(
    color: selected
    ? _sand
        : Colors.transparent,
    width: 2,
    ),
    ),
    ),
    ),],
    ),
    ),
    );
    },
    ),
    ),

      const SizedBox(height: 12),

      SizedBox(
        width: 220,
        height: 46,
        child: ElevatedButton(
          onPressed:
          (_selectedStyleId == null) ? null : _onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: _sand,
            disabledBackgroundColor:
            _sand.withOpacity(0.45),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            isLast ? 'Finish' : 'Next',
            style: const TextStyle(
              color: _black,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),

      const SizedBox(height: 10),

      Center(
        child: Text(
          '${_index + 1} / $total',
          style: TextStyle(
            color: _black.withOpacity(0.75),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
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