import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeData {
  final String title;
  final dynamic servings;
  final List<Ingredient> ingredients;
  final List<String> steps;

  RecipeData({
    required this.title,
    required this.servings,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeData.fromJson(Map<String, dynamic> json) {
    return RecipeData(
      title: json['title'] as String,
      servings: json['servings'],
      ingredients: (json['ingredients'] as List)
          .map((i) => Ingredient.fromJson(i as Map<String, dynamic>))
          .toList(),
      steps: (json['steps'] as List).map((s) => s as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'servings': servings,
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'steps': steps,
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

class ApiService {
  // Update this URL to your backend server
  // For local testing: 'http://10.0.2.2:3000' (Android emulator)
  // For local testing: 'http://localhost:3000' (iOS simulator/web)
  static const String baseUrl = 'http://10.0.2.2:3000';
  
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
}
