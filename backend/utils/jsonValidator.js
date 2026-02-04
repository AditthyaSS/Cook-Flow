/**
 * Validates the structure of a recipe JSON object
 * @param {Object} recipe - The recipe object to validate
 * @returns {Object} { valid: boolean, errors: string[], warnings: string[] }
 */
function validateRecipeJSON(recipe) {
  const errors = [];
  const warnings = [];

  // Check if recipe is an object
  if (!recipe || typeof recipe !== 'object') {
    return { valid: false, errors: ['Recipe must be a valid object'], warnings: [] };
  }

  // Validate title
  if (!recipe.title || typeof recipe.title !== 'string' || recipe.title.trim() === '') {
    errors.push('Title is required and must be a non-empty string');
  }

  // Validate servings
  if (!recipe.servings) {
    errors.push('Servings is required');
  } else if (typeof recipe.servings !== 'string' && typeof recipe.servings !== 'number') {
    errors.push('Servings must be a string or number');
  }

  // Validate prep_time_minutes (optional but recommended)
  if (recipe.prep_time_minutes !== undefined && recipe.prep_time_minutes !== null) {
    if (typeof recipe.prep_time_minutes !== 'number' || recipe.prep_time_minutes < 0) {
      errors.push('prep_time_minutes must be a non-negative number');
    }
  } else {
    warnings.push('prep_time_minutes is missing');
  }

  // Validate cook_time_minutes (optional but recommended)
  if (recipe.cook_time_minutes !== undefined && recipe.cook_time_minutes !== null) {
    if (typeof recipe.cook_time_minutes !== 'number' || recipe.cook_time_minutes < 0) {
      errors.push('cook_time_minutes must be a non-negative number');
    }
  } else {
    warnings.push('cook_time_minutes is missing');
  }

  // Validate difficulty (optional)
  if (recipe.difficulty !== undefined && recipe.difficulty !== null) {
    const validDifficulties = ['easy', 'medium', 'hard'];
    if (typeof recipe.difficulty !== 'string' || !validDifficulties.includes(recipe.difficulty.toLowerCase())) {
      warnings.push('difficulty should be one of: easy, medium, hard');
    }
  }

  // Validate cuisine (optional)
  if (recipe.cuisine !== undefined && recipe.cuisine !== null) {
    if (typeof recipe.cuisine !== 'string' || recipe.cuisine.trim() === '') {
      warnings.push('cuisine should be a non-empty string');
    }
  }

  // Validate tags (optional)
  if (recipe.tags !== undefined && recipe.tags !== null) {
    if (!Array.isArray(recipe.tags)) {
      warnings.push('tags should be an array of strings');
    } else {
      recipe.tags.forEach((tag, index) => {
        if (typeof tag !== 'string' || tag.trim() === '') {
          warnings.push(`Tag at index ${index} should be a non-empty string`);
        }
      });
    }
  }

  // Validate notes (optional)
  if (recipe.notes !== undefined && recipe.notes !== null) {
    if (typeof recipe.notes !== 'string') {
      warnings.push('notes should be a string');
    }
  }

  // Validate ingredients
  if (!Array.isArray(recipe.ingredients)) {
    errors.push('Ingredients must be an array');
  } else {
    if (recipe.ingredients.length === 0) {
      errors.push('Ingredients array cannot be empty');
    }

    recipe.ingredients.forEach((ingredient, index) => {
      if (!ingredient || typeof ingredient !== 'object') {
        errors.push(`Ingredient at index ${index} must be an object`);
      } else {
        if (!ingredient.quantity || typeof ingredient.quantity !== 'string') {
          errors.push(`Ingredient at index ${index} must have a quantity (string)`);
        }
        if (!ingredient.item || typeof ingredient.item !== 'string') {
          errors.push(`Ingredient at index ${index} must have an item (string)`);
        }
      }
    });
  }

  // Validate steps
  if (!Array.isArray(recipe.steps)) {
    errors.push('Steps must be an array');
  } else {
    if (recipe.steps.length === 0) {
      errors.push('Steps array cannot be empty');
    }

    recipe.steps.forEach((step, index) => {
      if (typeof step !== 'string' || step.trim() === '') {
        errors.push(`Step at index ${index} must be a non-empty string`);
      }
    });
  }

  return {
    valid: errors.length === 0,
    errors,
    warnings
  };
}

module.exports = { validateRecipeJSON };
