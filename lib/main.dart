import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_controller.dart'; // <<< CORRECTED IMPORT
import 'screens/auth_gate.dart'; // <<< CORRECTED IMPORT

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppController(),
      child: const SkillShareApp(),
    ),
  );
}

class SkillShareApp extends StatelessWidget {
  const SkillShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillShare App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        useMaterial3: false,
      ),
      home: const AuthGate(),
    );
  }
}