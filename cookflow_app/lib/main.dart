import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/recipe_screen.dart';

void main() {
  runApp(const CookFlowApp());
}

class CookFlowApp extends StatelessWidget {
  const CookFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CookFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RecipeScreen(),
    );
  }
}
