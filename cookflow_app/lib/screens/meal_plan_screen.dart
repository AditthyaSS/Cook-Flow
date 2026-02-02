import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme.dart';
import 'package:intl/intl.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final DatabaseService _db = DatabaseService.instance;
  DateTime _selectedWeekStart = DateTime.now();
  Map<DateTime, List<MealPlan>> _weekMealPlans = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedWeekStart = _getWeekStart(DateTime.now());
    _loadWeekMealPlans();
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday == 7 ? 0 : weekday));
  }

  Future<void> _loadWeekMealPlans() async {
    setState(() => _isLoading = true);
    
    final endDate = _selectedWeekStart.add(const Duration(days: 6));
    final mealPlans = await _db.getMealPlansByDateRange(_selectedWeekStart, endDate);
    
    // Group by date
    final Map<DateTime, List<MealPlan>> groupedPlans = {};
    for (final plan in mealPlans) {
      final dateKey = DateTime(plan.date.year, plan.date.month, plan.date.day);
      groupedPlans.putIfAbsent(dateKey, () => []);
      groupedPlans[dateKey]!.add(plan);
    }
    
    setState(() {
      _weekMealPlans = groupedPlans;
      _isLoading = false;
    });
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
    _loadWeekMealPlans();
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
    _loadWeekMealPlans();
  }

  void _goToToday() {
    setState(() {
      _selectedWeekStart = _getWeekStart(DateTime.now());
    });
    _loadWeekMealPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        title: Text(
          'Meal Planning',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildWeekSelector(),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildWeekView(),
                ),
              ],
            ),
    );
  }

  Widget _buildWeekSelector() {
    final endDate = _selectedWeekStart.add(const Duration(days: 6));
    final weekLabel = '${DateFormat('MMM d').format(_selectedWeekStart)} - ${DateFormat('MMM d, yyyy').format(endDate)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 32),
            onPressed: _previousWeek,
            color: AppTheme.primaryOrange,
          ),
          GestureDetector(
            onTap: _goToToday,
            child: Column(
              children: [
                Text(
                  weekLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to go to today',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 32),
            onPressed: _nextWeek,
            color: AppTheme.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = _selectedWeekStart.add(Duration(days: index));
        final isToday = _isSameDay(date, DateTime.now());
        final plansForDay = _weekMealPlans[DateTime(date.year, date.month, date.day)] ?? [];

        return _buildDayCard(date, plansForDay, isToday);
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDayCard(DateTime date, List<MealPlan> mealPlans, bool isToday) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isToday
            ? BorderSide(color: AppTheme.primaryOrange, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isToday ? AppTheme.primaryOrange : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d').format(date),
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textMedium,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Today',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: AppTheme.accentGreen,
                    size: 28,
                  ),
                  onPressed: () => _showAddMealDialog(date),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (mealPlans.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No meals planned',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...mealPlans.map((plan) => _buildMealPlanItem(plan)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanItem(MealPlan plan) {
    final mealIcon = _getMealIcon(plan.mealType);
    final mealColor = _getMealColor(plan.mealType);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: mealColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mealColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(mealIcon, color: mealColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.mealType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: mealColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.recipe?.title ?? 'Recipe not found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (plan.notes != null && plan.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    plan.notes!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: Colors.red[400],
            onPressed: () => _deleteMealPlan(plan),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.bakery_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange[700]!;
      case 'lunch':
        return Colors.green[700]!;
      case 'dinner':
        return Colors.purple[700]!;
      case 'snack':
        return Colors.pink[600]!;
      default:
        return AppTheme.textMedium;
    }
  }

  Future<void> _showAddMealDialog(DateTime date) async {
    final recipes = await _db.getAllRecipes();
    
    if (!mounted) return;
    
    if (recipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved recipes! Extract and save a recipe first.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String selectedMealType = 'breakfast';
    Recipe? selectedRecipe = recipes.first;
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Meal for ${DateFormat('MMM d').format(date)}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meal Type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedMealType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                    DropdownMenuItem(value: 'snack', child: Text('Snack')),
                  ],
                  onChanged: (value) {
                    setState(() => selectedMealType = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recipe',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Recipe>(
                  value: selectedRecipe,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: recipes.map((recipe) {
                    return DropdownMenuItem(
                      value: recipe,
                      child: Text(recipe.title),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedRecipe = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Notes (Optional)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(
                    hintText: 'Any special notes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final mealPlan = MealPlan(
                  recipeId: selectedRecipe!.id!,
                  date: date,
                  mealType: selectedMealType,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
                await _db.createMealPlan(mealPlan);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadWeekMealPlans();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Meal added successfully!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
              ),
              child: const Text('Add Meal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMealPlan(MealPlan plan) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan'),
        content: Text('Remove "${plan.recipe?.title}" from this day?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteMealPlan(plan.id!);
      _loadWeekMealPlans();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan deleted')),
        );
      }
    }
  }
}
