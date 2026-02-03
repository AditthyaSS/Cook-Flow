import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Recipe data model
class Recipe {
  final int? id;
  final String title;
  final String servings;
  final List<Map<String, String>> ingredients; // {quantity, item}
  final List<String> steps;
  final DateTime createdDate;
  final bool isFavorite;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;

  Recipe({
    this.id,
    required this.title,
    required this.servings,
    required this.ingredients,
    required this.steps,
    DateTime? createdDate,
    this.isFavorite = false,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'servings': servings,
      'ingredients': _encodeIngredients(ingredients),
      'steps': _encodeSteps(steps),
      'createdDate': createdDate.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as int?,
      title: map['title'] as String,
      servings: map['servings'] as String,
      ingredients: _decodeIngredients(map['ingredients'] as String),
      steps: _decodeSteps(map['steps'] as String),
      createdDate: DateTime.parse(map['createdDate'] as String),
      isFavorite: (map['isFavorite'] as int) == 1,
      prepTimeMinutes: map['prepTimeMinutes'] as int?,
      cookTimeMinutes: map['cookTimeMinutes'] as int?,
    );
  }

  // Encode ingredients list as JSON string
  static String _encodeIngredients(List<Map<String, String>> ingredients) {
    final items = ingredients.map((i) => '${i['quantity']}|||${i['item']}').join(';;;');
    return items;
  }

  // Decode ingredients JSON string to list
  static List<Map<String, String>> _decodeIngredients(String encoded) {
    if (encoded.isEmpty) return [];
    return encoded.split(';;;').map((item) {
      final parts = item.split('|||');
      return {'quantity': parts[0], 'item': parts[1]};
    }).toList();
  }

  // Encode steps list as JSON string
  static String _encodeSteps(List<String> steps) {
    return steps.join('|||');
  }

  // Decode steps JSON string to list
  static List<String> _decodeSteps(String encoded) {
    if (encoded.isEmpty) return [];
    return encoded.split('|||');
  }

  Recipe copyWith({
    int? id,
    String? title,
    String? servings,
    List<Map<String, String>>? ingredients,
    List<String>? steps,
    DateTime? createdDate,
    bool? isFavorite,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      createdDate: createdDate ?? this.createdDate,
      isFavorite: isFavorite ?? this.isFavorite,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
    );
  }
}

/// Meal Plan data model
class MealPlan {
  final int? id;
  final int recipeId;
  final DateTime date;
  final String mealType; // breakfast, lunch, dinner, snack
  final String? notes;
  final DateTime createdDate;

  // Computed field (not stored in DB, populated via join)
  Recipe? recipe;

  MealPlan({
    this.id,
    required this.recipeId,
    required this.date,
    required this.mealType,
    this.notes,
    DateTime? createdDate,
    this.recipe,
  }) : createdDate = createdDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'date': _dateOnly(date),
      'mealType': mealType,
      'notes': notes,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'] as int?,
      recipeId: map['recipeId'] as int,
      date: DateTime.parse(map['date'] as String),
      mealType: map['mealType'] as String,
      notes: map['notes'] as String?,
      createdDate: DateTime.parse(map['createdDate'] as String),
    );
  }

  // Helper to store date without time component
  static String _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  MealPlan copyWith({
    int? id,
    int? recipeId,
    DateTime? date,
    String? mealType,
    String? notes,
    DateTime? createdDate,
    Recipe? recipe,
  }) {
    return MealPlan(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      recipe: recipe ?? this.recipe,
    );
  }
}

class PantryItem {
  final int? id;
  final String name;
  final String quantity;
  final String? category;
  final DateTime? expiryDate;
  final DateTime addedDate;

  PantryItem({
    this.id,
    required this.name,
    required this.quantity,
    this.category,
    this.expiryDate,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'expiryDate': expiryDate?.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory PantryItem.fromMap(Map<String, dynamic> map) {
    return PantryItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      quantity: map['quantity'] as String,
      category: map['category'] as String?,
      expiryDate: map['expiryDate'] != null
          ? DateTime.parse(map['expiryDate'] as String)
          : null,
      addedDate: DateTime.parse(map['addedDate'] as String),
    );
  }

  /// Check if item is expiring soon (within 7 days)
  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
  }

  /// Check if item is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  /// Get days until expiry (negative if expired)
  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cookflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create pantry_items table
    await db.execute('''
      CREATE TABLE pantry_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        category TEXT,
        expiryDate TEXT,
        addedDate TEXT NOT NULL
      )
    ''');

    // Create recipes table
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        servings TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL,
        createdDate TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0,
        prepTimeMinutes INTEGER,
        cookTimeMinutes INTEGER
      )
    ''');

    // Create meal_plans table
    await db.execute('''
      CREATE TABLE meal_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipeId INTEGER NOT NULL,
        date TEXT NOT NULL,
        mealType TEXT NOT NULL,
        notes TEXT,
        createdDate TEXT NOT NULL,
        FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Create index for efficient date queries
    await db.execute('''
      CREATE INDEX idx_meal_plans_date ON meal_plans(date)
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add recipes table
      await db.execute('''
        CREATE TABLE recipes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          servings TEXT NOT NULL,
          ingredients TEXT NOT NULL,
          steps TEXT NOT NULL,
          createdDate TEXT NOT NULL,
          isFavorite INTEGER DEFAULT 0
        )
      ''');

      // Add meal_plans table
      await db.execute('''
        CREATE TABLE meal_plans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recipeId INTEGER NOT NULL,
          date TEXT NOT NULL,
          mealType TEXT NOT NULL,
          notes TEXT,
          createdDate TEXT NOT NULL,
          FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
        )
      ''');

      // Create index
      await db.execute('''
        CREATE INDEX idx_meal_plans_date ON meal_plans(date)
      ''');
    }
    
    if (oldVersion < 3) {
      // Add time fields to recipes table
      await db.execute('''
        ALTER TABLE recipes ADD COLUMN prepTimeMinutes INTEGER
      ''');
      await db.execute('''
        ALTER TABLE recipes ADD COLUMN cookTimeMinutes INTEGER
      ''');
    }
  }

  /// Create a new pantry item
  Future<PantryItem> createPantryItem(PantryItem item) async {
    final db = await database;
    final id = await db.insert('pantry_items', item.toMap());
    return item.copyWith(id: id);
  }

  /// Get all pantry items
  Future<List<PantryItem>> getAllPantryItems() async {
    final db = await database;
    final result = await db.query(
      'pantry_items',
      orderBy: 'addedDate DESC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Get pantry items by category
  Future<List<PantryItem>> getPantryItemsByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'pantry_items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'addedDate DESC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Get expiring items (within days)
  Future<List<PantryItem>> getExpiringItems({int days = 7}) async {
    final db = await database;
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    final result = await db.query(
      'pantry_items',
      where: 'expiryDate IS NOT NULL AND expiryDate <= ?',
      whereArgs: [futureDate.toIso8601String()],
      orderBy: 'expiryDate ASC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Search pantry items by name
  Future<List<PantryItem>> searchPantryItems(String query) async {
    final db = await database;
    final result = await db.query(
      'pantry_items',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'addedDate DESC',
    );
    return result.map((map) => PantryItem.fromMap(map)).toList();
  }

  /// Update a pantry item
  Future<int> updatePantryItem(PantryItem item) async {
    final db = await database;
    return db.update(
      'pantry_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Delete a pantry item
  Future<int> deletePantryItem(int id) async {
    final db = await database;
    return db.delete(
      'pantry_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all expired items
  Future<int> deleteExpiredItems() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return db.delete(
      'pantry_items',
      where: 'expiryDate IS NOT NULL AND expiryDate < ?',
      whereArgs: [now],
    );
  }

  // ========== RECIPE METHODS ==========

  /// Save a new recipe
  Future<Recipe> createRecipe(Recipe recipe) async {
    final db = await database;
    final id = await db.insert('recipes', recipe.toMap());
    return recipe.copyWith(id: id);
  }

  /// Get all saved recipes
  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final result = await db.query(
      'recipes',
      orderBy: 'createdDate DESC',
    );
    return result.map((map) => Recipe.fromMap(map)).toList();
  }

  /// Get favorite recipes
  Future<List<Recipe>> getFavoriteRecipes() async {
    final db = await database;
    final result = await db.query(
      'recipes',
      where: 'isFavorite = ?',
      whereArgs: [1],
      orderBy: 'createdDate DESC',
    );
    return result.map((map) => Recipe.fromMap(map)).toList();
  }

  /// Get recipe by ID
  Future<Recipe?> getRecipeById(int id) async {
    final db = await database;
    final result = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Recipe.fromMap(result.first);
  }

  /// Search recipes by title
  Future<List<Recipe>> searchRecipes(String query) async {
    final db = await database;
    final result = await db.query(
      'recipes',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'createdDate DESC',
    );
    return result.map((map) => Recipe.fromMap(map)).toList();
  }

  /// Toggle favorite status
  Future<int> toggleRecipeFavorite(int id, bool isFavorite) async {
    final db = await database;
    return db.update(
      'recipes',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update a recipe
  Future<int> updateRecipe(Recipe recipe) async {
    final db = await database;
    return db.update(
      'recipes',
      recipe.toMap(),
      where: 'id = ?',
      whereArgs: [recipe.id],
    );
  }

  /// Delete a recipe
  Future<int> deleteRecipe(int id) async {
    final db = await database;
    return db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== MEAL PLAN METHODS ==========

  /// Create a meal plan
  Future<MealPlan> createMealPlan(MealPlan mealPlan) async {
    final db = await database;
    final id = await db.insert('meal_plans', mealPlan.toMap());
    return mealPlan.copyWith(id: id);
  }

  /// Get meal plans for a specific date
  Future<List<MealPlan>> getMealPlansByDate(DateTime date) async {
    final db = await database;
    final dateStr = MealPlan._dateOnly(date);
    
    final result = await db.rawQuery('''
      SELECT mp.*, r.*
      FROM meal_plans mp
      LEFT JOIN recipes r ON mp.recipeId = r.id
      WHERE mp.date = ?
      ORDER BY 
        CASE mp.mealType
          WHEN 'breakfast' THEN 1
          WHEN 'lunch' THEN 2
          WHEN 'dinner' THEN 3
          WHEN 'snack' THEN 4
        END
    ''', [dateStr]);

    return result.map((map) {
      final mealPlan = MealPlan.fromMap({
        'id': map['id'],
        'recipeId': map['recipeId'],
        'date': map['date'],
        'mealType': map['mealType'],
        'notes': map['notes'],
        'createdDate': map['createdDate'],
      });
      
      // Attach recipe if exists
      if (map['title'] != null) {
        mealPlan.recipe = Recipe.fromMap({
          'id': map['recipeId'],
          'title': map['title'],
          'servings': map['servings'],
          'ingredients': map['ingredients'],
          'steps': map['steps'],
          'createdDate': map['r.createdDate'] ?? map['createdDate'],
          'isFavorite': map['isFavorite'] ?? 0,
        });
      }
      
      return mealPlan;
    }).toList();
  }

  /// Get meal plans for a date range (e.g., week view)
  Future<List<MealPlan>> getMealPlansByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final startStr = MealPlan._dateOnly(startDate);
    final endStr = MealPlan._dateOnly(endDate);

    final result = await db.rawQuery('''
      SELECT mp.*, r.*
      FROM meal_plans mp
      LEFT JOIN recipes r ON mp.recipeId = r.id
      WHERE mp.date >= ? AND mp.date <= ?
      ORDER BY mp.date ASC, 
        CASE mp.mealType
          WHEN 'breakfast' THEN 1
          WHEN 'lunch' THEN 2
          WHEN 'dinner' THEN 3
          WHEN 'snack' THEN 4
        END
    ''', [startStr, endStr]);

    return result.map((map) {
      final mealPlan = MealPlan.fromMap({
        'id': map['id'],
        'recipeId': map['recipeId'],
        'date': map['date'],
        'mealType': map['mealType'],
        'notes': map['notes'],
        'createdDate': map['createdDate'],
      });
      
      if (map['title'] != null) {
        mealPlan.recipe = Recipe.fromMap({
          'id': map['recipeId'],
          'title': map['title'],
          'servings': map['servings'],
          'ingredients': map['ingredients'],
          'steps': map['steps'],
          'createdDate': map['r.createdDate'] ?? map['createdDate'],
          'isFavorite': map['isFavorite'] ?? 0,
        });
      }
      
      return mealPlan;
    }).toList();
  }

  /// Update a meal plan
  Future<int> updateMealPlan(MealPlan mealPlan) async {
    final db = await database;
    return db.update(
      'meal_plans',
      mealPlan.toMap(),
      where: 'id = ?',
      whereArgs: [mealPlan.id],
    );
  }

  /// Delete a meal plan
  Future<int> deleteMealPlan(int id) async {
    final db = await database;
    return db.delete(
      'meal_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all meal plans for a specific date
  Future<int> deleteMealPlansByDate(DateTime date) async {
    final db = await database;
    final dateStr = MealPlan._dateOnly(date);
    return db.delete(
      'meal_plans',
      where: 'date = ?',
      whereArgs: [dateStr],
    );
  }

  /// Get aggregated ingredients from meal plans in a date range
  Future<Map<String, String>> getAggregatedIngredients(DateTime startDate, DateTime endDate) async {
    final mealPlans = await getMealPlansByDateRange(startDate, endDate);
    final Map<String, String> aggregated = {};

    for (final plan in mealPlans) {
      if (plan.recipe != null) {
        for (final ingredient in plan.recipe!.ingredients) {
          final item = ingredient['item']!.toLowerCase();
          final quantity = ingredient['quantity']!;
          
          if (aggregated.containsKey(item)) {
            // Simple concatenation for now (could be improved with unit parsing)
            aggregated[item] = '${aggregated[item]} + $quantity';
          } else {
            aggregated[item] = quantity;
          }
        }
      }
    }

    return aggregated;
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// Extension to add copyWith method
extension PantryItemCopyWith on PantryItem {
  PantryItem copyWith({
    int? id,
    String? name,
    String? quantity,
    String? category,
    DateTime? expiryDate,
    DateTime? addedDate,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}
