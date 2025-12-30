import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'screens/login_screen.dart';
import 'screens/paths_screen.dart';

void main() {
  runApp(const SmartDecorApp());
}

class SmartDecorApp extends StatelessWidget {
  const SmartDecorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Decor',
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.paths: (_) => const PathsScreen(),
      },
    );
  }
}