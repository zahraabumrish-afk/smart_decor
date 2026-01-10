import 'dart:typed_data';
import 'package:flutter/material.dart';

class PhotoMeasureScreen extends StatelessWidget {
  const PhotoMeasureScreen({
    super.key,
    required this.frontBytes,
    required this.rightBytes,
    required this.leftBytes,
    required this.backBytes,
  });

  final Uint8List frontBytes;
  final Uint8List rightBytes;
  final Uint8List leftBytes;
  final Uint8List backBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Estimate"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "4 photos received ✅",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _imgCard("Front", frontBytes),
                  _imgCard("Right", rightBytes),
                  _imgCard("Left", leftBytes),
                  _imgCard("Back", backBytes),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // زر متابعة (مكانه جاهز للخطوة اللي بعد القياسات)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: next step later
                  Navigator.pop(context);
                },
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgCard(String label, Uint8List bytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(bytes, fit: BoxFit.cover),
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}