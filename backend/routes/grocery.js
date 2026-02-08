const express = require('express');
const { generateGroceryList } = require('../services/groceryService');
const { generateAffiliateLinks, getAvailableNetworks } = require('../services/affiliateService');
const { authenticateUser } = require('../middleware/auth-middleware');

const router = express.Router();

/**
 * POST /generate-grocery-list
 * Generate categorized grocery list from recipes
 */
router.post('/generate-grocery-list', authenticateUser, async (req, res) => {
    try {
        const { recipes, options } = req.body;

        // Validate input
        if (!recipes || !Array.isArray(recipes)) {
            return res.status(400).json({
                success: false,
                error: 'Recipes array is required'
            });
        }

        if (recipes.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'At least one recipe is required'
            });
        }

        // Validate recipe structure
        for (const recipe of recipes) {
            if (!recipe.title || !recipe.ingredients) {
                return res.status(400).json({
                    success: false,
                    error: 'Each recipe must have title and ingredients'
                });
            }
        }

        // Generate grocery list
        const groceryList = await generateGroceryList(recipes, options || {});

        res.json({
            success: true,
            data: groceryList
        });

    } catch (error) {
        console.error('Generate grocery list error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Failed to generate grocery list'
        });
    }
});

/**
 * POST /generate-affiliate-links
 * Generate affiliate purchase links for grocery items
 */
router.post('/generate-affiliate-links', authenticateUser, async (req, res) => {
    try {
        const { groceryItems, network } = req.body;

        // Validate input
        if (!groceryItems || !Array.isArray(groceryItems)) {
            return res.status(400).json({
                success: false,
                error: 'Grocery items array is required'
            });
        }

        if (groceryItems.length === 0) {
            return res.status(400).json({
                success: false,
                error: 'At least one grocery item is required'
            });
        }

        // Generate affiliate links
        const itemsWithLinks = await generateAffiliateLinks(
            groceryItems,
            { network: network || 'amazon' }
        );

        res.json({
            success: true,
            data: itemsWithLinks
        });

    } catch (error) {
        console.error('Generate affiliate links error:', error);
        res.status(500).json({
            success: false,
            error: error.message || 'Failed to generate affiliate links'
        });
    }
});

/**
 * GET /affiliate-networks
 * Get available affiliate networks and their configuration status
 */
router.get('/affiliate-networks', (req, res) => {
    try {
        const networks = getAvailableNetworks();
        res.json({
            success: true,
            data: networks
        });
    } catch (error) {
        console.error('Get affiliate networks error:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to get affiliate networks'
        });
    }
});

module.exports = router;
