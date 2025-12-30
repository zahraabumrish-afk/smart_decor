import 'package:flutter/material.dart';

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

  void clear() {
    _items.clear();
    notifyListeners();
  }
}