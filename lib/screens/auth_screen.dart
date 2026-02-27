import 'dart:convert'; // لتحويل بيانات المستخدمين إلى JSON للتخزين
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'paths_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // 0 = Sign In
  // 1 = Create Account
  int _tabIndex = 0;

  // ---------------------------------
  // Controllers لقراءة مدخلات المستخدم
  // ---------------------------------
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // ---------------------------------
  // نصوص الأخطاء (تظهر تحت الحقول مباشرة)
  // ---------------------------------
  String? _emailError;
  String? _passError;
  String? _confirmError;

  // ---------------------------------
  // مفتاح التخزين المحلي (SharedPreferences)
  // نخزن Map: { email : password }
  // ---------------------------------
  static const String _kUsersMap = 'sd_users_map';

  // ---------------------------------
  // دالة تتحقق أن كلمة السر تحتوي أحرف + أرقام
  // + طول لا يقل عن 6
  // ---------------------------------
  bool _isStrongPassword(String password) {
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasNumber && password.length >= 6;
  }

  // ---------------------------------
  // تحقق بسيط من شكل الإيميل
  // ---------------------------------
  bool _isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  // ---------------------------------
  // تنظيف الأخطاء قبل أي تحقق جديد
  // ---------------------------------
  void _clearErrors() {
    _emailError = null;
    _passError = null;
    _confirmError = null;
  }

  // ---------------------------------
  // قراءة المستخدمين من التخزين المحلي
  // ---------------------------------
  Future<Map<String, String>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsersMap);
    if (raw == null || raw.trim().isEmpty) return {};

    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};

    return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  // ---------------------------------
  // حفظ المستخدمين في التخزين المحلي
  // ---------------------------------
  Future<void> _writeUsers(Map<String, String> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsersMap, jsonEncode(users));
  }

  // ---------------------------------
  // الانتقال إلى PathsScreen
  // نستخدم pushReplacement حتى ما يرجع المستخدم لـ Auth بالزر Back
  // ---------------------------------
  void _goToPaths() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PathsScreen()),
    );
  }

  // ---------------------------------
  // Sign In logic
  // ---------------------------------
  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final pass = _passController.text;

    // نخفي الكيبورد
    FocusScope.of(context).unfocus();

    setState(() {
      _clearErrors();

      // 1) تحقق من الفراغات
      if (email.isEmpty) _emailError = 'Please enter your email';
      if (pass.isEmpty) _passError = 'Please enter your password';
    });

    // إذا في أخطاء لا نكمل
    if (_emailError != null || _passError != null) return;

    // 2) تحقق شكل الإيميل
    if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      return;
    }

    // 3) قراءة الحسابات
    final users = await _readUsers();

    // 4) إذا الحساب مو موجود
    if (!users.containsKey(email)) {
      setState(() {
        _emailError = 'Account not found. Please create an account.';
      });return;
    }

    // 5) إذا كلمة السر غلط
    if (users[email] != pass) {
      setState(() {
        _passError = 'Wrong password';
      });
      return;
    }

    // 6) نجاح
    _goToPaths();
  }

  // ---------------------------------
  // Create Account logic
  // ---------------------------------
  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final pass = _passController.text;
    final confirm = _confirmController.text;

    // نخفي الكيبورد
    FocusScope.of(context).unfocus();

    setState(() {
      _clearErrors();

      // 1) تحقق من الفراغات
      if (email.isEmpty) _emailError = 'Please enter your email';
      if (pass.isEmpty) _passError = 'Please enter your password';
      if (confirm.isEmpty) _confirmError = 'Please confirm your password';
    });

    // إذا في أخطاء لا نكمل
    if (_emailError != null || _passError != null || _confirmError != null) return;

    // 2) تحقق شكل الإيميل
    if (!_isValidEmail(email)) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      return;
    }

    // 3) تحقق قوة كلمة السر (أحرف + أرقام + طول ≥ 6)
    if (!_isStrongPassword(pass)) {
      setState(() {
        _passError = 'Password must contain letters and numbers';
      });
      return;
    }

    // 4) تحقق تطابق كلمات المرور
    if (pass != confirm) {
      setState(() {
        _confirmError = 'Passwords do not match';
      });
      return;
    }

    // 5) قراءة الحسابات
    final users = await _readUsers();

    // 6) إذا الإيميل مسجل مسبقاً
    if (users.containsKey(email)) {
      setState(() {
        _emailError = 'This email is already registered. Please sign in.';
      });
      return;
    }

    // 7) حفظ الحساب
    users[email] = pass;
    await _writeUsers(users);

    // 8) نجاح
    _goToPaths();
  }

  // ---------------------------------
  // تنظيف الذاكرة
  // ---------------------------------
  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نستخدم Stack لأن الشاشة فيها:
      // صورة خلفية + Overlay + Blur + محتوى فوقهم
        body: Stack(
          children: [
          // ---------------------------------
          // 1) صورة الخلفية
          // ---------------------------------
          Image.asset(
          'assets/backgrounds/1.jpg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),

        // ---------------------------------
        // 2) طبقة تغميق
        // ---------------------------------
        Container(
          color: Colors.black.withOpacity(0.45),
        ),

        // ---------------------------------
        // 3) تأثير Blur
        // ---------------------------------
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.transparent),
        ),

        // ---------------------------------
        // 4) زر Back ثابت بزاوية الشاشة (فوق يسار)
        // ---------------------------------
        SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.25),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14),
                            ),
                        ),
                    ),
                ),
            ),
        ),

        // ---------------------------------
        // 5) المحتوى الرئيسي بالنص (Box في وسط الشاشة)
        // ---------------------------------
        SafeArea(
          child: Center(
              child: SizedBox(
                  width: 400, // عرض البوكس بالنص
                  child: Column(
                      children: [
                      const SizedBox(height: 70),

                  // ---------------------------------
                  // Tabs (Sign In / Create)
                  // ---------------------------------
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.30),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _tabButton('Sign In', 0)),
                        Expanded(child: _tabButton('Create', 1)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------------------------
                  // الكارد (النموذج)
                  // ---------------------------------
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                        // Email
                        _inputField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        isPassword: false,
                        errorText: _emailError,
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                        },
                      ),

                      const SizedBox(height: 15),

                      // Password
                      _inputField(
                        controller: _passController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        errorText: _passError,
                        onChanged: (_) {
                          if (_passError != null) {
                            setState(() => _passError = null);
                          }
                        },
                      ),

                      // Confirm Password يظهر فقط عند Create
                      if (_tabIndex == 1) ...[
                  const SizedBox(height: 15),
              _inputField(
                controller: _confirmController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                isPassword: true,
                errorText: _confirmError,
                onChanged: (_) {
                  if (_confirmError != null) {
                    setState(() => _confirmError = null);
                  }
                },
              ),
              ],

              const SizedBox(height: 25),

    // ---------------------------------
    // زر أساسي (حسب التبويب)
    // ---------------------------------
                          SizedBox(
                            width: 220,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () {
                                // تشغيل المنطق حسب التبويب
                                if (_tabIndex == 0) {
                                  _signIn();
                                } else {
                                  _createAccount();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC7A17A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _tabIndex == 0 ? 'Sign In' : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // ---------------------------------
                          // Continue as guest (قابل للضغط)
                          // ---------------------------------
                          TextButton(
                            onPressed: _goToPaths,
                            child: const Text(
                              'Continue as guest',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                  ),
                      ],
                  ),
              ),
          ),
        ),
          ],
        ),
    );
  }

  // ---------------------------------
  // زر التبويب (Sign In / Create)
  // ---------------------------------
  Widget _tabButton(String text, int index) {
    final bool isActive = _tabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tabIndex = index;

          // تفريغ حقل Confirm عند الرجوع لـ Sign In
          if (_tabIndex == 0) {
            _confirmController.clear();
            _confirmError = null;
          }

          // تنظيف الأخطاء عند تبديل التبويب
          _emailError = null;
          _passError = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC7A17A) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---------------------------------
  // حقل إدخال (مربوط بـ Controller) + يدعم errorText تحت الحقل
  // ---------------------------------
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
        controller: controller,
        obscureText: isPassword,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white70),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            errorText: errorText, // ✅ هنا تظهر الرسالة تحت الحقل
            filled: true,
            fillColor: Colors.black.withOpacity(0.20),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
            ),
        ),
    );
  }
}