const { GoogleGenerativeAI } = require('@google/generative-ai');
const { validateRecipeJSON } = require('../utils/jsonValidator');

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const EXTRACTION_PROMPT = `Extract a cooking recipe from the provided text.
Return ONLY valid JSON with this exact schema:
{
  "title": string,
  "servings": string or number,
  "prep_time_minutes": number (estimate prep time in minutes),
  "cook_time_minutes": number (estimate cooking time in minutes),
  "ingredients": [
    { "quantity": string, "item": string }
  ],
  "steps": [string]
}
Estimate prep_time_minutes based on ingredient preparation complexity.
Estimate cook_time_minutes based on cooking methods mentioned in steps.
No markdown.
No explanation.
No extra text.`;

/**
 * Extract recipe from raw text using Gemini AI
 * @param {string} rawText - The raw recipe text to extract
 * @returns {Promise<Object>} The extracted recipe JSON
 */
async function extractRecipe(rawText) {
    if (!process.env.GEMINI_API_KEY) {
        throw new Error('GEMINI_API_KEY is not configured');
    }

    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const fullPrompt = `${EXTRACTION_PROMPT}\n\nRecipe Text:\n${rawText}`;

    let attempt = 0;
    const maxAttempts = 2;

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
                const cleanedText = text.replace(/```json\n?|\n?```/g, '').trim();
                recipeData = JSON.parse(cleanedText);
            } catch (parseError) {
                throw new Error(`Failed to parse Gemini response as JSON: ${parseError.message}`);
            }

            // Validate the structure
            const validation = validateRecipeJSON(recipeData);
            if (!validation.valid) {
                throw new Error(`Invalid recipe structure: ${validation.errors.join(', ')}`);
            }

            return recipeData;

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
