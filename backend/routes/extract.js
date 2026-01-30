const express = require('express');
const { extractRecipe } = require('../services/geminiService');

const router = express.Router();

/**
 * POST /extract-recipe
 * Extract recipe from raw text input
 */
router.post('/extract-recipe', async (req, res) => {
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
                error: 'raw_text must be at least 50 characters'
            });
        }

        // Extract recipe using Gemini
        const recipe = await extractRecipe(raw_text);

        // Return success response
        res.json({
            success: true,
            data: recipe
        });

    } catch (error) {
        console.error('Extract recipe error:', error);

        res.status(500).json({
            success: false,
            error: error.message || 'Failed to extract recipe'
        });
    }
});

module.exports = router;
