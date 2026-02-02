import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/recipe_screen.dart';
import 'screens/pantry_screen.dart';
import 'screens/meal_plan_screen.dart';

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
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RecipeScreen(),
    PantryScreen(),
    MealPlanScreen(),
  ];

  final List<String> _titles = const [
    'Extract Recipe',
    'My Pantry',
    'Meal Planning',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: AppTheme.textMedium,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Extract',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Pantry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Meal Plan',
          ),
        ],
      ),
    );
  }
}
