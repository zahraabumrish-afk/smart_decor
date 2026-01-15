import '../local/design_request_local_store.dart';
import '../models/design_request_model.dart';

/// Repository لمسار Design Request
/// UI ❌ ما يتعامل مع Local Store مباشرة
/// UI ✅ يتعامل مع Repository
class DesignRequestRepository {
  final DesignRequestLocalStore _store;

  DesignRequestRepository({DesignRequestLocalStore? store})
      : _store = store ?? DesignRequestLocalStore.instance;

  Future<void> init() async {
    await _store.init();
  }

  /// حفظ طلب جديد
  Future<DesignRequestModel> saveRequest({
    required String prompt,
    required String? imagePath,
    required String? imageBytesBase64,
  }) async {
    final model = DesignRequestModel(
      prompt: prompt,
      imagePath: imagePath,
      imageBytesBase64: imageBytesBase64,
      createdAt: DateTime.now(),
    );

    final id = await _store.insertRequest(model);
    return model.copyWith(id: id);
  }

  /// جلب كل الطلبات
  Future<List<DesignRequestModel>> getRequests() async {
    return _store.getAllRequests();
  }

  /// حذف طلب
  Future<void> deleteRequest(int id) async {
    await _store.deleteRequest(id);
  }

  /// مسح الكل
  Future<void> clearAll() async {
    await _store.clearAll();
  }
}