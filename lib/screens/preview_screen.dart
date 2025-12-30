import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

/// -------------------- In-memory store (no extra files) --------------------
class SavedDesign {
  final String id;
  final String imagePath;
  final String title;
  final Color? overlayColor;
  final DateTime savedAt;

  SavedDesign({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.overlayColor,
    required this.savedAt,
  });
}

class SavedDesignsStore extends ChangeNotifier {
  SavedDesignsStore._();
  static final SavedDesignsStore instance = SavedDesignsStore._();

  final List<SavedDesign> _items = [];

  List<SavedDesign> get items => List.unmodifiable(_items);

  void add(SavedDesign design) {
    _items.insert(0, design);
    notifyListeners();
  }

  void removeById(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

/// -------------------- Preview Screen (with AI demo) --------------------
class PreviewScreen extends StatefulWidget {
  final String imagePath;
  final String title;

  const PreviewScreen({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Color? _overlayColor;

  final List<Color?> _colors = const [
    null, // Clear
    Color(0xFFF2EFEA),
    Color(0xFFE6D1B5),
    Color(0xFFD7BFA3),
    Color(0xFFB08B6E),
    Color(0xFFB7C4A0),
    Color(0xFF7C8B6F),
    Color(0xFF3E4A40),
    Color(0xFFBFC2C6),
    Color(0xFFD6B7C9),
    Color(0xFFB7C7D9),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: [
      // background
      Positioned.fill(
      child: Image.asset(widget.imagePath, fit: BoxFit.cover),
    ),
    // blur overlay
    Positioned.fill(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
    child: Container(color: Colors.black.withOpacity(0.30)),
    ),
    ),

    SafeArea(
    child: Column(
    children: [
    Padding(
    padding: const EdgeInsets.all(12),
    child: Align(
    alignment: Alignment.centerLeft,
    child: _BackPill(onTap: () => Navigator.pop(context)),
    ),
    ),
    Text(
    widget.title,
    style: const TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    ),
    ),
    const SizedBox(height: 14),

    Expanded(
    child: Center(
    child: Container(
    width: 720,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.12),
    borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    // small neat preview card (like gallery)
    Center(
    child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 520),
    child: AspectRatio(
    aspectRatio: 4 / 3,
    child: ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Stack(
    children: [
    Positioned.fill(
    child: Image.asset(
    widget.imagePath,
    fit: BoxFit.cover,
    ),
    ),
    if (_overlayColor != null)
    Positioned.fill(
    child: Container(
    color: _overlayColor!.withOpacity(0.18),
    ),
    ),
    ],
    ),
    ),
    ),
    ),
    ),

    const SizedBox(height: 14),
    const Text(
    "Color Preview (Concept)",
    style: TextStyle(
    color: Colors.white70,
    fontWeight: FontWeight.w600,
    ),
    ),
    const SizedBox(height: 10),

    // Tap colors -> overlay changes (A)
    SizedBox(
    height: 44,
    child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    itemCount: _colors.length,
    separatorBuilder: (_, __) => const SizedBox(width: 10),
    itemBuilder: (context, index) {
    final c = _colors[index];
    final selected =
    (c == null && _overlayColor == null) ||
    (c != null && _overlayColor != null && c.value == _overlayColor!.value);

    return GestureDetector(
    onTap: () => setState(() => _overlayColor = c),
    child: AnimatedContainer(
    duration: const Duration(milliseconds: 180),
    width: 34,
    height: 34,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: c ?? Colors.transparent,
    border: Border.all(
    color: selected ? Colors.white : Colors.white24,
    width: selected ? 2.2 : 1.2,
    ),
    ),
    child: c == null
    ? const Icon(Icons.close, size: 18, color: Colors.white)
        : null,
    ),
    );
    },
    ),
    ),

    const SizedBox(height: 16),

    // Generate AI (demo)
    SizedBox(
    width: 360,
    height: 52,
    child: ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFE6D1B5),
    foregroundColor: Colors.black87,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
    ),
    elevation: 0,
    ),
    icon: const Icon(Icons.auto_awesome_outlined),
    label: const Text("Generate AI Design",
      style: TextStyle(fontWeight: FontWeight.w800),
    ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GeneratingScreen(
              imagePath: widget.imagePath,
              title: widget.title,
              chosenOverlay: _overlayColor,
            ),
          ),
        );
      },
    ),
    ),
    ],
    ),
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
}

/// -------------------- Generating Screen --------------------
class GeneratingScreen extends StatefulWidget {
  final String imagePath;
  final String title;
  final Color? chosenOverlay;

  const GeneratingScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.chosenOverlay,
  });

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AiResultScreen(
            imagePath: widget.imagePath,
            title: widget.title,
            startOverlay: widget.chosenOverlay,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(widget.imagePath, fit: BoxFit.cover)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withOpacity(0.40)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BackPill(onTap: () => Navigator.pop(context)),
                  ),
                ),
                const Spacer(),
                const Text(
                  "Generating AI Design…",
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                const SizedBox(height: 10),
                const Text("Demo Mode", style: TextStyle(color: Colors.white70)),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// -------------------- AI Result + Save --------------------
class AiResultScreen extends StatefulWidget {
  final String imagePath;
  final String title;
  final Color? startOverlay;

  const AiResultScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.startOverlay,
  });

  @override
  State<AiResultScreen> createState() => _AiResultScreenState();
}

class _AiResultScreenState extends State<AiResultScreen> {
  Color? _overlay;

  final List<Color?> _colors = const [
    null,
    Color(0xFFF2EFEA),
    Color(0xFFE6D1B5),
    Color(0xFFD7BFA3),
    Color(0xFFB08B6E),
    Color(0xFFB7C4A0),
    Color(0xFF7C8B6F),
    Color(0xFF3E4A40),
    Color(0xFFBFC2C6),
    Color(0xFFD6B7C9),
    Color(0xFFB7C7D9),
  ];

  @override
  void initState() {
    super.initState();_overlay = widget.startOverlay;
  }

  void _saveAndOpenSaved() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    SavedDesignsStore.instance.add(
      SavedDesign(
        id: id,
        imagePath: widget.imagePath,
        title: "AI Design - ${widget.title}",
        overlayColor: _overlay,
        savedAt: DateTime.now(),
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedDesignsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
            children: [
        Positioned.fill(child: Image.asset(widget.imagePath, fit: BoxFit.cover)),
    Positioned.fill(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
    child: Container(color: Colors.black.withOpacity(0.30)),
    ),
    ),
    SafeArea(
    child: Column(
    children: [
    Padding(
    padding: const EdgeInsets.all(12),
    child: Align(
    alignment: Alignment.centerLeft,
    child: _BackPill(onTap: () => Navigator.pop(context)),
    ),
    ),
    const Text(
    "AI Generated Design (Demo)",
    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
    ),
    const SizedBox(height: 14),

    Expanded(
    child: Center(
    child: Container(
    width: 720,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.12),
    borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Center(
    child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 520),
    child: AspectRatio(
    aspectRatio: 4 / 3,
    child: ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Stack(
    children: [
    Positioned.fill(
    child: Image.asset(widget.imagePath, fit: BoxFit.cover),
    ),
    if (_overlay != null)
    Positioned.fill(
    child: Container(color: _overlay!.withOpacity(0.18)),
    ),
    ],
    ),
    ),
    ),
    ),
    ),

    const SizedBox(height: 14),
    const Text(
    "Color Suggestions (Concept)",
    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    ),
    const SizedBox(height: 10),

    SizedBox(
    height: 44,
    child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    itemCount: _colors.length,
    separatorBuilder: (_, __) => const SizedBox(width: 10),
    itemBuilder: (context, index) {final c = _colors[index];
    final selected =
        (c == null && _overlay == null) ||
            (c != null && _overlay != null && c.value == _overlay!.value);

    return GestureDetector(
      onTap: () => setState(() => _overlay = c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c ?? Colors.transparent,
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 2.2 : 1.2,
          ),
        ),
        child: c == null
            ? const Icon(Icons.close, size: 18, color: Colors.white)
            : null,
      ),
    );
    },
    ),
    ),

      const SizedBox(height: 16),

      SizedBox(
        width: 360,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE6D1B5),
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text(
            "Save Design",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          onPressed: _saveAndOpenSaved,
        ),
      ),
    ],
    ),
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
}

/// -------------------- Saved Designs Screen --------------------
class SavedDesignsScreen extends StatefulWidget {
  const SavedDesignsScreen({super.key});

  @override
  State<SavedDesignsScreen> createState() => _SavedDesignsScreenState();
}

class _SavedDesignsScreenState extends State<SavedDesignsScreen> {
  @override
  void initState() {
    super.initState();
    SavedDesignsStore.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    SavedDesignsStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

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
    Padding(padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: _BackPill(onTap: () => Navigator.pop(context)),
      ),
    ),
      const SizedBox(height: 4),
      const Text(
        'Saved Designs',
        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: items.isEmpty
            ? const Center(
          child: Text('No saved designs yet.', style: TextStyle(color: Colors.white70)),
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
                  Center(
                    child: SizedBox(
                      width: 600,
                      height: 420,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          d.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (d.overlayColor != null)
                    Positioned.fill(
                      child: Container(color: d.overlayColor!.withOpacity(0.18)),
                    ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            d.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
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

/// -------------------- UI helper --------------------
class _BackPill extends StatelessWidget {
  final VoidCallback onTap;
  const _BackPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
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
    );
  }
}