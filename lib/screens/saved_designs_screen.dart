import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/saved_designs_store.dart';

class SavedDesignsScreen extends StatefulWidget {
  const SavedDesignsScreen({super.key});

  @override
  State<SavedDesignsScreen> createState() => _SavedDesignsScreenState();
}

class _SavedDesignsScreenState extends State<SavedDesignsScreen> {
  @override
  void initState() {
    super.initState();
    SavedDesignsStore.instance.addListener(_onChanged);
  }

  @override
  void dispose() {
    SavedDesignsStore.instance.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

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
    child: InkWell(
    onTap: () => Navigator.pop(context),
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
    ),
    ),
    ),
    const SizedBox(height: 4),
    const Text(
    'Saved Designs',
    style: TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    ),
    ),
    const SizedBox(height: 12),

    Expanded(
    child: items.isEmpty
    ? const Center(
    child: Text(
    'No saved designs yet.',
    style: TextStyle(color: Colors.white70),
    ),
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
    AspectRatio(
    aspectRatio: 4 / 3,
    child: Image.asset(d.imagePath, fit: BoxFit.cover),
    ),
    if (d.overlayColor != null)
    Positioned.fill(
    child: Container(color: d.overlayColor!.withOpacity(0.18)),),
      Positioned(
        left: 12,
        right: 12,
        bottom: 10,
        child: Row(
          children: [
            Expanded(
              child: Text(
                d.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
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