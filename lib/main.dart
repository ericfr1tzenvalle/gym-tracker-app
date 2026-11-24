import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'widgets/glass_surface.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker App',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => GlassBackground(child: child!),
      home: const AuthGate(),
    );
  }
}
