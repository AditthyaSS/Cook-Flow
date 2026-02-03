import '../services/api_service.dart';
import '../services/database_service.dart';

/// Utility class to format recipes as shareable text
class RecipeFormatter {
  /// Format RecipeData (from API) as shareable text
  static String formatRecipeData(RecipeData recipe) {
    final buffer = StringBuffer();
    
    // Title
    buffer.writeln('🍳 ${recipe.title}');
    buffer.writeln('=' * (recipe.title.length + 3));
    buffer.writeln();
    
    // Servings and time info
    buffer.writeln('📋 DETAILS');
    buffer.writeln('Servings: ${recipe.servings}');
    if (recipe.prepTimeMinutes != null) {
      buffer.writeln('Prep Time: ${recipe.prepTimeMinutes} minutes');
    }
    if (recipe.cookTimeMinutes != null) {
      buffer.writeln('Cook Time: ${recipe.cookTimeMinutes} minutes');
    }
    if (recipe.prepTimeMinutes != null && recipe.cookTimeMinutes != null) {
      buffer.writeln('Total Time: ${recipe.prepTimeMinutes! + recipe.cookTimeMinutes!} minutes');
    }
    buffer.writeln();
    
    // Ingredients
    buffer.writeln('🥘 INGREDIENTS');
    for (var ingredient in recipe.ingredients) {
      buffer.writeln('• ${ingredient.quantity} ${ingredient.item}');
    }
    buffer.writeln();
    
    // Steps
    buffer.writeln('👨‍🍳 INSTRUCTIONS');
    for (var i = 0; i < recipe.steps.length; i++) {
      buffer.writeln('${i + 1}. ${recipe.steps[i]}');
    }
    buffer.writeln();
    
    // Footer
    buffer.writeln('---');
    buffer.writeln('Shared from CookFlow 🍳');
    
    return buffer.toString();
  }
  
  /// Format Recipe (from database) as shareable text
  static String formatRecipe(Recipe recipe) {
    final buffer = StringBuffer();
    
    // Title
    buffer.writeln('🍳 ${recipe.title}');
    buffer.writeln('=' * (recipe.title.length + 3));
    buffer.writeln();
    
    // Servings and time info
    buffer.writeln('📋 DETAILS');
    buffer.writeln('Servings: ${recipe.servings}');
    if (recipe.prepTimeMinutes != null) {
      buffer.writeln('Prep Time: ${recipe.prepTimeMinutes} minutes');
    }
    if (recipe.cookTimeMinutes != null) {
      buffer.writeln('Cook Time: ${recipe.cookTimeMinutes} minutes');
    }
    if (recipe.prepTimeMinutes != null && recipe.cookTimeMinutes != null) {
      buffer.writeln('Total Time: ${recipe.prepTimeMinutes! + recipe.cookTimeMinutes!} minutes');
    }
    buffer.writeln();
    
    // Ingredients
    buffer.writeln('🥘 INGREDIENTS');
    for (var ingredient in recipe.ingredients) {
      buffer.writeln('• ${ingredient['quantity']} ${ingredient['item']}');
    }
    buffer.writeln();
    
    // Steps
    buffer.writeln('👨‍🍳 INSTRUCTIONS');
    for (var i = 0; i < recipe.steps.length; i++) {
      buffer.writeln('${i + 1}. ${recipe.steps[i]}');
    }
    buffer.writeln();
    
    // Footer
    buffer.writeln('---');
    buffer.writeln('Shared from CookFlow 🍳');
    
    return buffer.toString();
  }
}
