import 'package:flutter/material.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _t = {
    'en': {
      'appName': 'Smart Decor',
      'taglineLine1': 'Because your design reflects you',
      'taglineLine2': 'We are here',
      'login': 'Log in',
    },
    'ar': {
      'appName': 'Smart Decor',
      'taglineLine1': 'لأن تصميمك يعبر عنك',
      'taglineLine2': 'نحن هنا',
      'login': 'تسجيل الدخول',
    },
  };

  static String of(BuildContext context, String key) {
    final String code = Localizations.localeOf(context).languageCode;
    return _t[code]?[key] ?? _t['en']![key] ?? key;
  }
}