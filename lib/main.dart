import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/paths_screen.dart';

// Path 3
import 'desing_request/screens/design_request_upload_screen.dart';

void main() {
  runApp(const SmartDecorApp());
}

class SmartDecorApp extends StatefulWidget {
  const SmartDecorApp({super.key});

  /// نداء عام لتغيير لغة التطبيق من أي شاشة
  static void setLocale(BuildContext context, Locale locale) {
    final _SmartDecorAppState? state =
    context.findAncestorStateOfType<_SmartDecorAppState>();
    state?.setLocale(locale);
  }

  @override
  State<SmartDecorApp> createState() => _SmartDecorAppState();
}

class _SmartDecorAppState extends State<SmartDecorApp> {
  Locale _locale = const Locale('en'); // الافتراضي إنكليزي

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Decor',

      // ✅ اللغة الحالية للتطبيق
      locale: _locale,

      // ✅ اللغات المدعومة
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      // ✅ ضروري لعمل RTL + دعم الترجمة
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // هذا يخلي Flutter يطبّق RTL تلقائياً للعربي
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (final s in supportedLocales) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return supportedLocales.first;
      },

      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.paths: (_) => const PathsScreen(),

        // Path 3 route
        AppRoutes.designRequestUpload: (_) => const DesignRequestUploadScreen(),
      },
    );
  }
}