import 'dart:async'; // للتأخير البسيط قبل رد النظام (محاكاة "تفكير")
import 'dart:ui'; // للـ Blur
import 'dart:typed_data'; // للـ bytes على الويب

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'design_request_result_screen.dart'; // شاشة النتيجة

// ===============================
// ✅ DesignRequestChatScreen (Smart Step-Based)
// - شات ذكي محلي (بدون API)
// - كل رسالة من المستخدم تُعتبر جواب للخطوة الحالية
// - النظام ينتقل للخطوة التالية بناءً على جواب المستخدم
// - يمنع تكرار نفس السؤال بعد الإجابة
// - يدعم الغرف: قعدة / مطبخ / مكتب / نوم رئيسية / نوم أطفال (نضيفها لاحقاً بسهولة)
// ===============================
class DesignRequestChatScreen extends StatefulWidget {
  final XFile pickedImage; // الصورة المرفوعة
  final Uint8List? webBytes; // bytes للويب

  const DesignRequestChatScreen({
    super.key,
    required this.pickedImage,
    required this.webBytes,
  });

  @override
  State<DesignRequestChatScreen> createState() => _DesignRequestChatScreenState();
}

// ===============================
// ✅ Model للرسالة داخل الشات
// ===============================
class _Message {
  final String text;
  final bool isUser;

  _Message({
    required this.text,
    required this.isUser,
  });
}

// ===============================
// ✅ أنواع الغرف المعتمدة عندك بالمشروع
// ===============================
enum _RoomType {
  livingRoom,     // غرفة قعدة
  kitchen,        // مطبخ
  office,         // مكتب
  masterBedroom,  // نوم رئيسية
  kidsBedroom,    // نوم أطفال
}

// ===============================
// ✅ خطوات الحوار (Flow)
// كل غرفة إلها مجموعة خطوات
// ===============================
enum _FlowStep {
  needRoomType, // أول شي لازم نعرف نوع الغرفة

  // -------- غرفة قعدة --------
  living_needCounts,   // عدد الكنبا + الكراسي
  living_needStyle,    // مودرن/كلاسيك...
  living_needColor,    // اللون الأساسي
  living_needLayout,   // L / مستقيم...

  // -------- مطبخ --------
  kitchen_needStyle,   // مودرن/كلاسيك
  kitchen_needColor,   // لون الخزائن
  kitchen_needLayout,  // L/U/Y/مستقيم
  kitchen_needIsland,  // جزيرة أو لا

  done, // اكتملت المعلومات الأساسية
}

class _DesignRequestChatScreenState extends State<DesignRequestChatScreen> {
  // ===============================
  // ✅ Controller لحقل الكتابة
  // ===============================
  final TextEditingController _controller = TextEditingController();

  // ===============================
  // ✅ قائمة الرسائل داخل الشات
  // ===============================
  final List<_Message> _messages = [];

  // لتتبع آخر رسالة كتبها المستخدم (حتى نسمح بالتعديل)
  int? _lastUserMessageIndex;

  // ===============================
  // ✅ حالة الفهم الحالية (State)
  // ===============================
  _RoomType? _roomType; // نوع الغرفة
  _FlowStep _step = _FlowStep.needRoomType; // نحن بأي خطوة حالياً

  // معلومات مشتركة
  String? _style; // مودرن/كلاسيك...
  String? _color; // بيج/رمادي...

  // غرفة قعدة
  int? _sofaCount; // عدد الكنبايات
  int? _chairCount; // عدد الكراسي
  String? _livingLayout; // شكل الترتيب

  // مطبخ
  String? _kitchenLayout; // L / U / Y / مستقيم
  bool? _kitchenIsland; // مع جزيرة أو بدون// ===============================
  // ✅ إرسال رسالة المستخدم + توليد رد النظام
  // ===============================
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // 1) إضافة رسالة المستخدم للقائمة
      _messages.add(_Message(text: text, isUser: true));
      _lastUserMessageIndex = _messages.length - 1;
    });

    // 2) تفريغ حقل الكتابة
    _controller.clear();

    // 3) اعتبر هذه الرسالة "جواب" للخطوة الحالية وحللها
    _consumeAnswerByStep(text);

    // 4) رد النظام بعد تأخير بسيط (يحاكي التفكير)
    Future.delayed(const Duration(milliseconds: 350), () {
      final reply = _buildReplyForCurrentStep();
      setState(() {
        _messages.add(_Message(text: reply, isUser: false));
      });
    });
  }

  // ===============================
  // ✅ تعديل آخر رسالة (اختياري)
  // - يرجع النص لحقل الكتابة
  // - يحذف الرسالة القديمة من الشات
  // ===============================
  void _editLastMessage() {
    if (_lastUserMessageIndex == null) return;

    final oldText = _messages[_lastUserMessageIndex!].text;
    _controller.text = oldText;

    setState(() {
      _messages.removeAt(_lastUserMessageIndex!);
      _lastUserMessageIndex = null;
    });

    // ملاحظة: للتبسيط ما عم نرجع التحليل للخلف.
    // إذا بدك لاحقاً: نعيد بناء الحالة من كل رسائل المستخدم.
  }

  // ===============================
  // ✅ تحليل الرسالة على أنها جواب للخطوة الحالية
  // ===============================
  void _consumeAnswerByStep(String raw) {
    final t = _normalize(raw);

    // 1) حاول تعرف نوع الغرفة من أي رسالة
    _detectRoomType(t);

    // 2) حسب الخطوة الحالية، نقرأ الجواب وننتقل للخطوة التالية
    switch (_step) {
    // -----------------------
    // (A) إذا ما عرفنا الغرفة بعد
    // -----------------------
      case _FlowStep.needRoomType:
        if (_roomType != null) {
          _step = _firstStepForRoom(_roomType!);
        }
        break;

    // -----------------------
    // (B) غرفة قعدة
    // -----------------------
      case _FlowStep.living_needCounts:
        _detectLivingCounts(t);
        if (_sofaCount != null || _chairCount != null) {
          _step = _FlowStep.living_needStyle;
        }
        break;

      case _FlowStep.living_needStyle:
        _style = raw; // نخزن جواب المستخدم كما هو
        _step = _FlowStep.living_needColor;
        break;

      case _FlowStep.living_needColor:
        _color = raw;
        _step = _FlowStep.living_needLayout;
        break;

      case _FlowStep.living_needLayout:
        _livingLayout = raw;
        _step = _FlowStep.done;
        break;

    // -----------------------
    // (C) مطبخ
    // -----------------------
      case _FlowStep.kitchen_needStyle:
        _style = raw;
        _step = _FlowStep.kitchen_needColor;
        break;

      case _FlowStep.kitchen_needColor:
        _color = raw;
        _step = _FlowStep.kitchen_needLayout;
        break;

      case _FlowStep.kitchen_needLayout:
        _kitchenLayout = _detectKitchenLayout(t) ?? raw;
        _step = _FlowStep.kitchen_needIsland;
        break;

      case _FlowStep.kitchen_needIsland:
        _kitchenIsland = _detectKitchenIsland(t);
        if (_kitchenIsland != null) {
          _step = _FlowStep.done;
        }
        break;

    // -----------------------
    // (D) Done
    // -----------------------
      case _FlowStep.done:
      // بعد ما نخلص… أي رسالة جديدة تعتبر "ملاحظة إضافية"
      // (حالياً ما رح نغير شي، بس ممكن لاحقاً نخزن ملاحظات)
        break;
    }
  }

  // ===============================
  // ✅ أول خطوة حسب نوع الغرفة
  // ===============================
  _FlowStep _firstStepForRoom(_RoomType room) {
    switch (room) {
    case _RoomType.livingRoom:
    return _FlowStep.living_needCounts;
    case _RoomType.kitchen:
    return _FlowStep.kitchen_needStyle;
    case _RoomType.office:
    // لاحقاً منضيف خطوات المكتب
    return _FlowStep.done;
    case _RoomType.masterBedroom:
    // لاحقاً منضيف خطوات النوم
      return _FlowStep.done;
      case _RoomType.kidsBedroom:
      // لاحقاً منضيف خطوات أطفال
        return _FlowStep.done;
    }
  }// ===============================
  // ✅ بناء رد النظام حسب الخطوة الحالية
  // ===============================
  String _buildReplyForCurrentStep() {
    // إذا لسه ما عرفنا نوع الغرفة
    if (_roomType == null) {
      _step = _FlowStep.needRoomType;
      return "تمام ✨ بس قوليلي أي نوع غرفة تقصدي؟\n"
          "• غرفة قعدة\n• مطبخ\n• مكتب\n• غرفة نوم رئيسية\n• غرفة نوم أطفال";
    }

    // ردود حسب الخطوة
    switch (_step) {
    // -------- غرفة قعدة --------
      case _FlowStep.living_needCounts:
        return "${_summaryPrefix("غرفة قعدة")}\n"
            "كم عدد الكنبايات والكراسي؟ (مثلاً: 3 كنبايات وكرسين)";

      case _FlowStep.living_needStyle:
        return "${_summaryPrefix("غرفة قعدة")}\n"
            "تمام 👍 شو الستايل؟ (مودرن / كلاسيك / نيوكلاسيك)";

      case _FlowStep.living_needColor:
        return "${_summaryPrefix("غرفة قعدة")}\n"
            "حلو 👌 شو اللون الأساسي اللي بدك يطلع؟ (بيج/رمادي/أوف وايت/خشبي)";

      case _FlowStep.living_needLayout:
        return "${_summaryPrefix("غرفة قعدة")}\n"
            "آخر شي ✨ بتحبي الترتيب حرف L ولا مستقيم؟";

    // -------- مطبخ --------
      case _FlowStep.kitchen_needStyle:
        return "${_summaryPrefix("مطبخ")}\n"
            "بدك ستايل المطابخ مودرن ولا كلاسيك؟";

      case _FlowStep.kitchen_needColor:
        return "${_summaryPrefix("مطبخ")}\n"
            "شو لون الخزائن اللي بتحبيه؟";

      case _FlowStep.kitchen_needLayout:
        return "${_summaryPrefix("مطبخ")}\n"
            "بالترتيب… بدك ياه حرف L ولا U ولا Y ولا خط مستقيم؟";

      case _FlowStep.kitchen_needIsland:
        return "${_summaryPrefix("مطبخ")}\n"
            "تمام 👌 بدك جزيرة بالنص ولا بدون؟ (قولي: مع / بدون)";

    // -------- Done --------
      case _FlowStep.done:
        return "${_summaryAll()}\n"
            "✅ هيك صار عندي تفاصيل كافية.\n"
            "إذا بدك، اضغطي Continue to Result.";

    // -------- needRoomType --------
      case _FlowStep.needRoomType:
        return "قوليلي أي نوع غرفة؟";
    }
  }

  // ===============================
  // ✅ تلخيص صغير حسب الغرفة (حتى يكون الرد مو “ركيك”)
  // ===============================
  String _summaryPrefix(String roomName) {
    final parts = <String>[];

    if (_style != null) parts.add("ستايل: $_style");
    if (_color != null) parts.add("لون: $_color");

    if (_roomType == _RoomType.livingRoom) {
      if (_sofaCount != null) parts.add("كنبا: $_sofaCount");
      if (_chairCount != null) parts.add("كراسي: $_chairCount");
      if (_livingLayout != null) parts.add("ترتيب: $_livingLayout");
    }

    if (_roomType == _RoomType.kitchen) {
      if (_kitchenLayout != null) parts.add("ترتيب: $_kitchenLayout");
      if (_kitchenIsland != null) {
        parts.add(_kitchenIsland! ? ": نعم" : ": لا");
      }
    }

    final tail = parts.isEmpty ? "" : " (${parts.join(" • ")})";
    return "تمام ✨ $roomName$tail";
  }

  // ===============================
  // ✅ تلخيص نهائي لكل المعلومات
  // ===============================
  String _summaryAll() {
    String room = "غرفة";
    if (_roomType == _RoomType.livingRoom) room = "غرفة قعدة";
    if (_roomType == _RoomType.kitchen) room = "مطبخ";
    if (_roomType == _RoomType.office) room = "مكتب";
    if (_roomType == _RoomType.masterBedroom) room = "غرفة نوم رئيسية";
    if (_roomType == _RoomType.kidsBedroom) room = "غرفة نوم أطفال";

    return _summaryPrefix(room);
  }

  // ===============================
  // ✅ Helpers: تنظيف النص لتسهيل المطابقة
  // ===============================
  String _normalize(String input) {
    var t = input.toLowerCase().trim();
    t = t
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
    return t;
  }

  // ===============================
  // ✅ كشف نوع الغرفة من كلام المستخدم
  // ===============================
  void _detectRoomType(String t) {
    if (t.contains('قعده') || t.contains('قعدة') || t.contains('صالون')) {
    _roomType = _RoomType.livingRoom;// إذا كنا بحاجة لتحديد الغرفة، ننتقل لأول خطوة
    if (_step == _FlowStep.needRoomType) {
    _step = _FlowStep.living_needCounts;
    }
    return;
    }

    if (t.contains('مطبخ')) {
    _roomType = _RoomType.kitchen;
    if (_step == _FlowStep.needRoomType) {
    _step = _FlowStep.kitchen_needStyle;
    }
    return;
    }

    if (t.contains('مكتب')) {
    _roomType = _RoomType.office;
    return;
    }

    if (t.contains('نوم') && (t.contains('اطفال') || t.contains('أطفال'))) {
    _roomType = _RoomType.kidsBedroom;
    return;
    }

    if (t.contains('نوم')) {
    _roomType = _RoomType.masterBedroom;
    return;
    }
  }

  // ===============================
  // ✅ استخراج عدد الكنبايات والكراسي من كلام المستخدم
  // - يدعم: 3 / ٣
  // - مثال: "3 كنبايات و 2 كراسي"
  // ===============================
  void _detectLivingCounts(String t) {
    final normalized = _convertArabicDigitsToEnglish(t);

    final sofaMatch = RegExp(r'(\d+)\s*(كنبا|كنبه|كنبات|كنبايات)')
        .firstMatch(normalized);
    if (sofaMatch != null) {
      _sofaCount = int.tryParse(sofaMatch.group(1) ?? '');
    }

    final chairMatch = RegExp(r'(\d+)\s*(كرسي|كراسي)')
        .firstMatch(normalized);
    if (chairMatch != null) {
      _chairCount = int.tryParse(chairMatch.group(1) ?? '');
    }
  }

  // ===============================
  // ✅ كشف ترتيب المطبخ (L / U / Y / مستقيم)
  // ===============================
  String? _detectKitchenLayout(String t) {
    if (t.contains('l')) return "حرف L";
    if (t.contains('u')) return "حرف U";
    if (t.contains('y')) return "حرف Y";
    if (t.contains('مستقيم') || t.contains('خط')) return "مستقيم";
    return null;
  }

  // ===============================
  // ✅ كشف هل بدها جزيرة ولا لا
  // - "مع" => true
  // - "بدون" أو "لا" => false
  // ===============================
  bool? _detectKitchenIsland(String t) {
    if (t.contains('مع')) return true;
    if (t.contains('بدون') || t == 'لا') return false;
    return null;
  }

  // ===============================
  // ✅ تحويل الأرقام العربية الهندية إلى أرقام عادية
  // مثال: ٣ -> 3
  // ===============================
  String _convertArabicDigitsToEnglish(String input) {
    const arabicDigits = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    var out = input;
    for (int i = 0; i < arabicDigits.length; i++) {
      out = out.replaceAll(arabicDigits[i], i.toString());
    }
    return out;
  }@override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
          // ======================
          // خلفية التطبيق الأساسية
          // ======================
          Image.asset(
          'assets/backgrounds/1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // ======================
        // غباش خفيف للخلفية
        // ======================
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),

        SafeArea(
          child: Column(
              children: [
          // ======================
          // زر الرجوع (بالزاوية)
          // ======================
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 4),

        // ======================
        // عنوان الشاشة
        // ======================
        const Text(
          'Design Chat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        // ======================
        // صندوق الرسائل
        // ======================
        Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.10)),
                    ),
                    child: _messages.isEmpty
                        ? const Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'اكتب طلبك… ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                        : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];

                          return Align(
                              alignment: msg.isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: msg.isUser
                                      ? const Color(0xFFF3C9A8)
                                      : Colors.black.withOpacity(0.30),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: msg.isUser
                                        ? const Color(0xFF3B2A1E)
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          );
                        },
                    ),
                ),
            ),
        ),

        // ======================
        // شريط الكتابة + زر الإرسال
        // ======================
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'اكتب طلبك هنا...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 56,
                width: 56,
                child: ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3C9A8),
                    foregroundColor: const Color(0xFF3B2A1E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),

        // ======================
        // زر تعديل آخر رسالة
        // ======================
        if (_lastUserMessageIndex != null)
    TextButton(
      onPressed: _editLastMessage,
      child: const Text(
        "Edit last message",
        style: TextStyle(color: Colors.white70),
      ),
    ),

    // ======================
    // زر الانتقال للنتيجة
    // ======================
    Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: ElevatedButton(
    onPressed: () {
    // نجمع كل رسائل المستخدم كنص واحد
    final prompt = _messages.where((m) => m.isUser)
        .map((m) => m.text)
        .join(" ");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DesignRequestResultScreen(
          prompt: prompt,
          pickedImage: widget.pickedImage,
          webBytes: widget.webBytes,
        ),
      ),
    );
    },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC7A17A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Text(
          "Continue to Result",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
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