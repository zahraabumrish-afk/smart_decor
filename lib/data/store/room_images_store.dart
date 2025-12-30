import 'package:image_picker/image_picker.dart';

enum RoomAngle { front, right, left, back }

class RoomImagesStore {
  RoomImagesStore._();

  static final Map<RoomAngle, XFile?> _images = {
    RoomAngle.front: null,
    RoomAngle.right: null,
    RoomAngle.left: null,
    RoomAngle.back: null,
  };

  static XFile? get(RoomAngle angle) => _images[angle];

  static void set(RoomAngle angle, XFile file) {
    _images[angle] = file;
  }

  static bool get allSelected =>
      _images.values.every((file) => file != null);

  static void clear() {
    for (final k in _images.keys) {
      _images[k] = null;
    }
  }

  static Map<String, String> toPathMap() {
    // جاهزة للباك لاحقاً: (front/right/left/back) -> path
    return {
      'front': _images[RoomAngle.front]!.path,
      'right': _images[RoomAngle.right]!.path,
      'left': _images[RoomAngle.left]!.path,
      'back': _images[RoomAngle.back]!.path,
    };
  }
}