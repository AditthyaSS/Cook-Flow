const { GoogleGenerativeAI } = require('@google/generative-ai');
const { validateRecipeJSON } = require('../utils/jsonValidator');

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const EXTRACTION_PROMPT = `Extract a cooking recipe from the provided text and return ONLY valid JSON.

SCHEMA (return this exact structure):
{
  "title": string,
  "servings": string or number,
  "prep_time_minutes": number,
  "cook_time_minutes": number,
  "difficulty": "easy" | "medium" | "hard",
  "cuisine": string,
  "tags": [string],
  "ingredients": [
    { "quantity": "string", "item": "string" }
  ],
  "steps": [string],
  "notes": string (optional chef tips or important notes)
}

EXTRACTION GUIDELINES:

Ingredients:
- Parse quantities carefully (handle fractions like 1/2, ranges like 2-3, units)
- Keep original measurements (cups, tbsp, grams, etc.)
- Normalize ingredient names (lowercase, remove extra spaces)
- For "to taste" or "as needed", use those exact phrases in quantity

Steps:
- Number sequentially and keep concise
- Combine very short consecutive steps if they're part of the same action
- Remove duplicate or redundant steps
- Preserve temperature and time specifications exactly

Time Estimation:
- prep_time_minutes: chopping, mixing, marinating (exclude cooking/baking)
- cook_time_minutes: active cooking, baking, simmering time
- Be realistic: simple salad = 10-15 min prep, roasted chicken = 60-90 min cook

Difficulty:
- "easy": < 30 min total, < 10 ingredients, basic techniques
- "medium": 30-60 min, moderate ingredients, some skill required
- "hard": > 60 min, many ingredients/steps, advanced techniques

Cuisine: Italian, Mexican, Chinese, Indian, French, American, Mediterranean, etc.

Tags: vegetarian, vegan, gluten-free, dairy-free, quick, one-pot, dessert, breakfast, lunch, dinner, appetizer, etc.

Notes: Extract any chef tips, substitution suggestions, or important warnings from the text.

CRITICAL: Return ONLY the JSON object. No markdown, no explanations, no extra text.`;

/**
 * Preprocess recipe text to improve extraction quality
 * @param {string} rawText - The raw recipe text
 * @returns {string} Cleaned and normalized text
 */
function preprocessRecipeText(rawText) {
    let text = rawText;

    // Normalize line endings
    text = text.replace(/\r\n/g, '\n').replace(/\r/g, '\n');

    // Remove excessive whitespace while preserving structure
    text = text.replace(/[ \t]+/g, ' '); // Multiple spaces/tabs to single space
    text = text.replace(/\n{3,}/g, '\n\n'); // Max 2 consecutive newlines

    // Trim each line
    text = text.split('\n').map(line => line.trim()).join('\n');

    // Remove common HTML remnants (in case of copy-paste from web)
    text = text.replace(/<[^>]+>/g, '');
    text = text.replace(/&nbsp;/g, ' ');
    text = text.replace(/&amp;/g, '&');
    text = text.replace(/&lt;/g, '<');
    text = text.replace(/&gt;/g, '>');

    // Remove common blog fluff patterns
    text = text.replace(/\[Print Recipe\]/gi, '');
    text = text.replace(/\[Pin Recipe\]/gi, '');
    text = text.replace(/Jump to Recipe/gi, '');

    // Trim overall
    text = text.trim();

    return text;
}

/**
 * Calculate quality score for extracted recipe
 * @param {Object} recipe - The extracted recipe object
 * @returns {number} Quality score from 0 to 1
 */
function calculateQualityScore(recipe) {
    let score = 0;
    const checks = [];

    // Title check (0.15)
    if (recipe.title && recipe.title.length >= 3 && recipe.title.length <= 100) {
        score += 0.15;
        checks.push('title_valid');
    }

    // Servings check (0.1)
    if (recipe.servings) {
        score += 0.1;
        checks.push('servings_present');
    }

    // Ingredients check (0.3)
    if (recipe.ingredients && recipe.ingredients.length >= 2) {
        score += 0.15;
        checks.push('ingredients_count');

        // Check ingredient quality
        const validIngredients = recipe.ingredients.filter(ing =>
            ing.quantity && ing.item && ing.item.length > 2
        );
        if (validIngredients.length === recipe.ingredients.length) {
            score += 0.15;
            checks.push('ingredients_quality');
        }
    }

    // Steps check (0.3)
    if (recipe.steps && recipe.steps.length >= 2) {
        score += 0.15;
        checks.push('steps_count');

        // Check step quality (not too short, not empty)
        const validSteps = recipe.steps.filter(step =>
            step && step.trim().length >= 10
        );
        if (validSteps.length === recipe.steps.length) {
            score += 0.15;
            checks.push('steps_quality');
        }
    }

    // Time estimates check (0.1)
    if (recipe.prep_time_minutes > 0 && recipe.cook_time_minutes >= 0) {
        // Realistic time check (total < 8 hours)
        const totalTime = recipe.prep_time_minutes + recipe.cook_time_minutes;
        if (totalTime > 0 && totalTime < 480) {
            score += 0.1;
            checks.push('time_realistic');
        }
    }

    // Metadata check (0.05 bonus for having additional fields)
    if (recipe.difficulty || recipe.cuisine || (recipe.tags && recipe.tags.length > 0)) {
        score += 0.05;
        checks.push('metadata_present');
    }

    return Math.min(score, 1.0); // Cap at 1.0
}

/**
 * Extract recipe from raw text using Gemini AI
 * @param {string} rawText - The raw recipe text to extract
 * @returns {Promise<Object>} The extracted recipe JSON with metadata
 */
async function extractRecipe(rawText) {
    if (!process.env.GEMINI_API_KEY) {
        throw new Error('GEMINI_API_KEY is not configured');
    }

    const startTime = Date.now();

    // Preprocess the input text
    const cleanedText = preprocessRecipeText(rawText);

    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const fullPrompt = `${EXTRACTION_PROMPT}\n\nRecipe Text:\n${cleanedText}`;

    let attempt = 0;
    const maxAttempts = 2;
    const warnings = [];

    while (attempt < maxAttempts) {
        attempt++;

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

            // Try to parse the response
            let recipeData;
            try {
                // Remove any markdown code blocks if present
                const cleanedResponse = text.replace(/```json\n?|\n?```/g, '').trim();
                recipeData = JSON.parse(cleanedResponse);
            } catch (parseError) {
                throw new Error(`Failed to parse Gemini response as JSON: ${parseError.message}`);
            }

            // Validate the structure
            const validation = validateRecipeJSON(recipeData);
            if (!validation.valid) {
                throw new Error(`Invalid recipe structure: ${validation.errors.join(', ')}`);
            }

            // Add warnings from validation if any
            if (validation.warnings && validation.warnings.length > 0) {
                warnings.push(...validation.warnings);
            }

            // Calculate quality score
            const qualityScore = calculateQualityScore(recipeData);

            // Add quality-based warnings
            if (qualityScore < 0.7) {
                warnings.push('Extraction quality is lower than expected - please verify the recipe details');
            }
            if (!recipeData.difficulty) {
                warnings.push('Difficulty level not detected');
            }
            if (!recipeData.cuisine) {
                warnings.push('Cuisine type not detected');
            }

            const extractionTime = Date.now() - startTime;

            // Return recipe with metadata
            return {
                recipe: recipeData,
                metadata: {
                    quality_score: qualityScore,
                    warnings: warnings,
                    extraction_time_ms: extractionTime
                }
            };

        } catch (error) {
            if (attempt >= maxAttempts) {
                // Last attempt failed
                throw new Error(`Gemini extraction failed: ${error.message}`);
            }
            // Retry once more
            console.log(`Attempt ${attempt} failed, retrying...`);
            await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1 second before retry
        }
    }
}

module.exports = { extractRecipe };
