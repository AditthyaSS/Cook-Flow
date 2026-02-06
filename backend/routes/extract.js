const express = require('express');
const { extractRecipe } = require('../services/geminiService');
const { authenticateUser } = require('../middleware/auth-middleware');

const router = express.Router();

/**
 * POST /extract-recipe
 * Extract recipe from raw text input
 */
router.post('/extract-recipe', authenticateUser, async (req, res) => {
    try {
        const { raw_text } = req.body;

        // Validate input
        if (!raw_text) {
            return res.status(400).json({
                success: false,
                error: 'raw_text is required'
            });
        }

        if (typeof raw_text !== 'string') {
            return res.status(400).json({
                success: false,
                error: 'raw_text must be a string'
            });
        }

        if (raw_text.trim().length < 50) {
            return res.status(400).json({
                success: false,
                error: 'Recipe text must be at least 50 characters. Please include ingredients and cooking steps.'
            });
        }

        // Check if it looks like a URL
        const urlPattern = /^https?:\/\//i;
        if (urlPattern.test(raw_text.trim())) {
            return res.status(400).json({
                success: false,
                error: 'URL detected. Please copy and paste the recipe text instead of the URL.'
            });
        }

        // Extract recipe using Gemini
        const result = await extractRecipe(raw_text);

        // Return success response with metadata
        res.json({
            success: true,
            data: result.recipe,
            metadata: result.metadata
        });

    } catch (error) {
        console.error('Extract recipe error:', error);

        // Provide more helpful error messages
        let errorMessage = error.message || 'Failed to extract recipe';

        // Check for specific error types
        if (errorMessage.includes('timeout')) {
            errorMessage = 'Request timed out. The recipe might be too long or complex. Please try again or simplify the text.';
        } else if (errorMessage.includes('API key')) {
            errorMessage = 'API configuration error. Please contact support.';
        } else if (errorMessage.includes('parse')) {
            errorMessage = 'Unable to extract recipe structure. Please ensure the text includes clear ingredients and steps.';
        } else if (errorMessage.includes('Invalid recipe structure')) {
            errorMessage = 'Recipe extraction incomplete. Please ensure your text includes a title, ingredients, and cooking steps.';
        }

        res.status(500).json({
            success: false,
            error: errorMessage
        });
    }
});

module.exports = router;
