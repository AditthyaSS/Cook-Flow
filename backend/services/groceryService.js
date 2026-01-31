const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const CATEGORIZATION_PROMPT = `You are a grocery shopping assistant. Given a list of recipe ingredients, categorize them into standard grocery store sections.

Return ONLY valid JSON with this exact schema:
{
  "categories": [
    {
      "name": "category name (e.g., Produce, Dairy, Meat & Seafood, Pantry Staples, Bakery, Frozen, etc.)",
      "items": [
        {
          "name": "item name",
          "quantity": "quantity with unit",
          "recipeTitle": "source recipe title"
        }
      ]
    }
  ]
}

Rules:
1. Group similar items together intelligently
2. Use standard grocery store categories
3. Preserve quantity information exactly as given
4. If multiple recipes need the same item, list it separately with recipe source
5. Common categories: Produce, Dairy & Eggs, Meat & Seafood, Pantry Staples, Spices & Condiments, Bakery, Frozen Foods, Beverages
6. No markdown, no explanation, no extra text - ONLY JSON`;

/**
 * Generate categorized grocery list from recipes
 * @param {Array} recipes - Array of recipe objects with title, ingredients, etc.
 * @param {Object} options - Options like { aggregate: boolean }
 * @returns {Promise<Object>} Categorized grocery list
 */
async function generateGroceryList(recipes, options = {}) {
    if (!process.env.GEMINI_API_KEY) {
        throw new Error('GEMINI_API_KEY is not configured');
    }

    if (!Array.isArray(recipes) || recipes.length === 0) {
        throw new Error('At least one recipe is required');
    }

    // Extract ingredients from all recipes
    const ingredientsByRecipe = recipes.map(recipe => ({
        title: recipe.title,
        ingredients: recipe.ingredients || []
    }));

    // Build ingredient list for prompt
    const ingredientText = ingredientsByRecipe.map(recipeData => {
        const ingredientList = recipeData.ingredients
            .map(ing => `${ing.quantity} ${ing.item}`)
            .join('\n  - ');
        return `Recipe: "${recipeData.title}"\n  - ${ingredientList}`;
    }).join('\n\n');

    const fullPrompt = `${CATEGORIZATION_PROMPT}\n\nIngredients to categorize:\n${ingredientText}`;

    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    try {
        // Create timeout promise
        const timeoutPromise = new Promise((_, reject) => {
            setTimeout(() => reject(new Error('Request timeout after 30 seconds')), 30000);
        });

        // Make API call with timeout
        const resultPromise = model.generateContent(fullPrompt);
        const result = await Promise.race([resultPromise, timeoutPromise]);

        const response = await result.response;
        const text = response.text();

        // Parse response
        let groceryData;
        try {
            const cleanedText = text.replace(/```json\n?|\n?```/g, '').trim();
            groceryData = JSON.parse(cleanedText);
        } catch (parseError) {
            throw new Error(`Failed to parse Gemini response as JSON: ${parseError.message}`);
        }

        // Validate structure
        if (!groceryData.categories || !Array.isArray(groceryData.categories)) {
            throw new Error('Invalid grocery list structure: missing categories array');
        }

        // Optional: Aggregate quantities if requested
        if (options.aggregate) {
            groceryData = aggregateGroceryList(groceryData);
        }

        // Calculate total items
        const totalItems = groceryData.categories.reduce(
            (sum, category) => sum + (category.items?.length || 0),
            0
        );

        return {
            categories: groceryData.categories,
            totalItems,
            recipeCount: recipes.length
        };

    } catch (error) {
        throw new Error(`Grocery list generation failed: ${error.message}`);
    }
}

/**
 * Aggregate quantities for duplicate items
 * @param {Object} groceryData - Grocery list data
 * @returns {Object} Aggregated grocery list
 */
function aggregateGroceryList(groceryData) {
    const aggregated = { categories: [] };

    groceryData.categories.forEach(category => {
        const itemMap = new Map();

        category.items.forEach(item => {
            const key = item.name.toLowerCase().trim();
            if (itemMap.has(key)) {
                const existing = itemMap.get(key);
                // Combine quantities (simple concatenation for now)
                existing.quantity = `${existing.quantity} + ${item.quantity}`;
                existing.recipeTitle = `${existing.recipeTitle}, ${item.recipeTitle}`;
            } else {
                itemMap.set(key, { ...item });
            }
        });

        aggregated.categories.push({
            name: category.name,
            items: Array.from(itemMap.values())
        });
    });

    return aggregated;
}

module.exports = { generateGroceryList };
