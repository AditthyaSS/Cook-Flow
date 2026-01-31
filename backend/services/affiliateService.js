const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Affiliate network configurations
const AFFILIATE_NETWORKS = {
    amazon: {
        name: 'Amazon',
        baseUrl: 'https://www.amazon.com/s',
        idKey: 'tag',
        buildUrl: (productName, affiliateId) => {
            const searchTerm = encodeURIComponent(productName);
            return affiliateId
                ? `https://www.amazon.com/s?k=${searchTerm}&tag=${affiliateId}`
                : `https://www.amazon.com/s?k=${searchTerm}`;
        }
    },
    instacart: {
        name: 'Instacart',
        baseUrl: 'https://www.instacart.com/store/search',
        idKey: 'ref',
        buildUrl: (productName, affiliateId) => {
            const searchTerm = encodeURIComponent(productName);
            return affiliateId
                ? `https://www.instacart.com/store/search?q=${searchTerm}&ref=${affiliateId}`
                : `https://www.instacart.com/store/search?q=${searchTerm}`;
        }
    }
};

const PRODUCT_MAPPING_PROMPT = `You are a grocery shopping assistant. Given an ingredient name, suggest the best product search term for online grocery shopping.

Rules:
1. Convert recipe ingredients to purchasable product names
2. Remove quantities and measurements
3. Keep it simple and searchable
4. Return ONLY the product name, nothing else

Examples:
- "2 cups all-purpose flour" → "all-purpose flour"
- "1 lb chicken breast, boneless" → "boneless chicken breast"
- "3 medium tomatoes, diced" → "tomatoes"
- "½ cup olive oil (extra virgin)" → "extra virgin olive oil"`;

/**
 * Generate affiliate links for grocery items
 * @param {Array} groceryItems - Array of grocery item objects
 * @param {Object} options - Options like { network: 'amazon' | 'instacart' }
 * @returns {Promise<Array>} Array of items with affiliate links
 */
async function generateAffiliateLinks(groceryItems, options = {}) {
    if (!Array.isArray(groceryItems) || groceryItems.length === 0) {
        throw new Error('At least one grocery item is required');
    }

    const network = options.network || 'amazon';
    const affiliateConfig = AFFILIATE_NETWORKS[network];

    if (!affiliateConfig) {
        throw new Error(`Unsupported affiliate network: ${network}`);
    }

    // Get affiliate ID from environment
    const affiliateId = network === 'amazon'
        ? process.env.AMAZON_AFFILIATE_ID
        : process.env.INSTACART_AFFILIATE_ID;

    // Process each item
    const itemsWithLinks = await Promise.all(
        groceryItems.map(async (item) => {
            try {
                // Get optimized product search term
                const productName = await optimizeProductName(item.name);

                // Build affiliate URL
                const affiliateUrl = affiliateConfig.buildUrl(productName, affiliateId);

                return {
                    name: item.name,
                    quantity: item.quantity,
                    category: item.category,
                    affiliateUrl,
                    network: affiliateConfig.name,
                    hasAffiliateId: !!affiliateId
                };
            } catch (error) {
                console.error(`Failed to generate link for "${item.name}":`, error.message);
                // Return item without affiliate link on error
                return {
                    name: item.name,
                    quantity: item.quantity,
                    category: item.category,
                    affiliateUrl: null,
                    network: null,
                    hasAffiliateId: false,
                    error: error.message
                };
            }
        })
    );

    return itemsWithLinks;
}

/**
 * Optimize ingredient name for product search using Gemini
 * @param {string} ingredientName - Raw ingredient name from recipe
 * @returns {Promise<string>} Optimized product search term
 */
async function optimizeProductName(ingredientName) {
    // For simple cases, use basic cleaning
    if (isSingleWord(ingredientName)) {
        return ingredientName.trim();
    }

    // Use Gemini for complex ingredient names
    if (!process.env.GEMINI_API_KEY) {
        // Fallback to basic cleaning if no API key
        return basicProductNameCleaning(ingredientName);
    }

    try {
        const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });
        const prompt = `${PRODUCT_MAPPING_PROMPT}\n\nIngredient: "${ingredientName}"`;

        const timeoutPromise = new Promise((_, reject) => {
            setTimeout(() => reject(new Error('Timeout')), 5000);
        });

        const resultPromise = model.generateContent(prompt);
        const result = await Promise.race([resultPromise, timeoutPromise]);

        const response = await result.response;
        const productName = response.text().trim();

        return productName || basicProductNameCleaning(ingredientName);

    } catch (error) {
        // Fallback to basic cleaning on error
        console.log(`Using fallback cleaning for "${ingredientName}"`);
        return basicProductNameCleaning(ingredientName);
    }
}

/**
 * Basic product name cleaning (fallback)
 * @param {string} ingredientName - Raw ingredient name
 * @returns {string} Cleaned product name
 */
function basicProductNameCleaning(ingredientName) {
    return ingredientName
        .replace(/^\d+[\s\/]*(cups?|tbsp?|tsp?|oz|lb|g|kg|ml|l)\s*/i, '') // Remove quantities
        .replace(/,.*$/, '') // Remove everything after comma
        .replace(/\(.*?\)/g, '') // Remove parenthetical notes
        .trim();
}

/**
 * Check if string is a single word
 * @param {string} str - String to check
 * @returns {boolean}
 */
function isSingleWord(str) {
    return str.trim().split(/\s+/).length === 1;
}

/**
 * Get available affiliate networks
 * @returns {Array} Array of network info
 */
function getAvailableNetworks() {
    return Object.entries(AFFILIATE_NETWORKS).map(([key, config]) => ({
        id: key,
        name: config.name,
        configured: !!(key === 'amazon'
            ? process.env.AMAZON_AFFILIATE_ID
            : process.env.INSTACART_AFFILIATE_ID)
    }));
}

module.exports = {
    generateAffiliateLinks,
    getAvailableNetworks
};
