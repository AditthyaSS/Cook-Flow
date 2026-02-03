import 'dart:convert';
import 'package:http/http.dart' as http;

// ============================================================================
// RECIPE DATA MODELS (Phase 1)
// ============================================================================

class RecipeData {
  final String title;
  final dynamic servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;

  RecipeData({
    required this.title,
    required this.servings,
    required this.ingredients,
    required this.steps,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
  });

  factory RecipeData.fromJson(Map<String, dynamic> json) {
    return RecipeData(
      title: json['title'] as String,
      servings: json['servings'],
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List).map((s) => s as String).toList(),
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      cookTimeMinutes: json['cook_time_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'servings': servings,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'steps': steps,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
    };
  }
}

class Ingredient {
  final String quantity;
  final String item;

  Ingredient({required this.quantity, required this.item});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      quantity: json['quantity'] as String,
      item: json['item'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'item': item,
    };
  }
}

// ============================================================================
// GROCERY LIST DATA MODELS (Phase 2)
// ============================================================================

class GroceryList {
  final List<GroceryCategory> categories;
  final int totalItems;
  final int recipeCount;

  GroceryList({
    required this.categories,
    required this.totalItems,
    required this.recipeCount,
  });

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      categories: (json['categories'] as List)
          .map((c) => GroceryCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalItems: json['totalItems'] as int,
      recipeCount: json['recipeCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': categories.map((c) => c.toJson()).toList(),
      'totalItems': totalItems,
      'recipeCount': recipeCount,
    };
  }
}

class GroceryCategory {
  final String name;
  final List<GroceryItem> items;

  GroceryCategory({
    required this.name,
    required this.items,
  });

  factory GroceryCategory.fromJson(Map<String, dynamic> json) {
    return GroceryCategory(
      name: json['name'] as String,
      items: (json['items'] as List)
          .map((i) => GroceryItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class GroceryItem {
  final String name;
  final String quantity;
  final String? recipeTitle;
  final String? affiliateUrl;
  final String? network;
  final bool? hasAffiliateId;
  bool isChecked;

  GroceryItem({
    required this.name,
    required this.quantity,
    this.recipeTitle,
    this.affiliateUrl,
    this.network,
    this.hasAffiliateId,
    this.isChecked = false,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      recipeTitle: json['recipeTitle'] as String?,
      affiliateUrl: json['affiliateUrl'] as String?,
      network: json['network'] as String?,
      hasAffiliateId: json['hasAffiliateId'] as bool?,
      isChecked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'recipeTitle': recipeTitle,
      'category': null, // Will be set when sending to backend
    };
  }
}

// ============================================================================
// API SERVICE
// ============================================================================

class ApiService {
  // Update this URL to your backend server
  // For local testing: 'http://10.0.2.2:3000' (Android emulator)
  // For local testing: 'http://localhost:3000' (iOS simulator/web)
  static const String baseUrl = 'http://10.0.2.2:3000';

  /// Extract recipe from raw text (Phase 1)
  static Future<RecipeData> extractRecipe(String rawText) async {
    if (rawText.trim().length < 50) {
      throw Exception('Recipe text must be at least 50 characters');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/extract-recipe'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'raw_text': rawText}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please try again');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return RecipeData.fromJson(jsonResponse['data']);
        } else {
          throw Exception(jsonResponse['error'] ?? 'Failed to extract recipe');
        }
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['error'] ?? 'Invalid input');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Network error - check your connection');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to extract recipe: ${e.toString()}');
    }
  }

  /// Generate grocery list from recipes (Phase 2)
  static Future<GroceryList> generateGroceryList(
    List<RecipeData> recipes, {
    bool aggregate = false,
  }) async {
    if (recipes.isEmpty) {
      throw Exception('At least one recipe is required');
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/generate-grocery-list'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'recipes': recipes.map((r) => r.toJson()).toList(),
              'options': {'aggregate': aggregate},
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please try again');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return GroceryList.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              jsonResponse['error'] ?? 'Failed to generate grocery list');
        }
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['error'] ?? 'Invalid input');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Network error - check your connection');
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Failed to generate grocery list: ${e.toString()}');
    }
  }

  /// Add affiliate links to grocery items (Phase 2)
  static Future<List<GroceryItem>> addAffiliateLinks(
    List<GroceryItem> items, {
    String network = 'amazon',
  }) async {
    if (items.isEmpty) {
      return items;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/generate-affiliate-links'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'groceryItems': items.map((i) => i.toJson()).toList(),
              'network': network,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout - please try again');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map((item) => GroceryItem.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
              jsonResponse['error'] ?? 'Failed to add affiliate links');
        }
      } else {
        // Non-critical failure - return original items without links
        return items;
      }
    } catch (e) {
      // Non-critical failure - return original items without links
      print('Failed to add affiliate links: $e');
      return items;
    }
  }
}
