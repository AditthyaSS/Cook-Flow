import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService.instance;
  late TabController _tabController;
  List<Recipe> _allRecipes = [];
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() => _isLoading = true);
    final allRecipes = await _db.getAllRecipes();
    final favorites = await _db.getFavoriteRecipes();
    setState(() {
      _allRecipes = allRecipes;
      _favoriteRecipes = favorites;
      _isLoading = false;
    });
  }

  List<Recipe> get _filteredRecipes {
    final recipes = _tabController.index == 0 ? _allRecipes : _favoriteRecipes;
    if (_searchQuery.isEmpty) return recipes;
    return recipes.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  Future<void> _toggleFavorite(Recipe recipe) async {
    await _db.toggleRecipeFavorite(recipe.id!, !recipe.isFavorite);
    _loadRecipes();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(recipe.isFavorite ? 'Removed from favorites' : 'Added to favorites'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text('Are you sure you want to delete "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _db.deleteRecipe(recipe.id!);
      _loadRecipes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        title: Text(
          'Saved Recipes',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.textMedium,
          indicatorColor: AppTheme.primaryOrange,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'All Recipes'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Recipe list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecipes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeCard(_filteredRecipes[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFavoritesTab = _tabController.index == 1;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFavoritesTab ? Icons.favorite_border : Icons.receipt_long,
              size: 80,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 24),
            Text(
              isFavoritesTab ? 'No Favorite Recipes' : 'No Saved Recipes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFavoritesTab
                  ? 'Tap the heart icon on recipes to save them as favorites'
                  : 'Extract and save recipes to see them here',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Recipe info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.restaurant, size: 16, color: AppTheme.textMedium),
                        const SizedBox(width: 4),
                        Text(
                          recipe.servings,
                          style: TextStyle(color: AppTheme.textMedium),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.list_alt, size: 16, color: AppTheme.textMedium),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.ingredients.length} ingredients',
                          style: TextStyle(color: AppTheme.textMedium),
                        ),
                      ],
                    ),
                    // Time info
                    if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (recipe.prepTimeMinutes != null) ...[
                            Icon(Icons.schedule, size: 14, color: AppTheme.primaryOrange),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.prepTimeMinutes}m prep',
                              style: TextStyle(color: AppTheme.textMedium, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (recipe.cookTimeMinutes != null) ...[
                            Icon(Icons.timer, size: 14, color: AppTheme.accentGreen),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookTimeMinutes}m cook',
                              style: TextStyle(color: AppTheme.textMedium, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Favorite button
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: recipe.isFavorite ? Colors.red[400] : AppTheme.textMedium,
                ),
                onPressed: () => _toggleFavorite(recipe),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Title and actions
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: recipe.isFavorite ? Colors.red[400] : AppTheme.textMedium,
                          ),
                          onPressed: () {
                            _toggleFavorite(recipe);
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteRecipe(recipe);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Servings
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant, size: 16, color: AppTheme.accentGreen),
                          const SizedBox(width: 4),
                          Text(
                            recipe.servings,
                            style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ingredients
                    Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...recipe.ingredients.map((ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 16, color: AppTheme.textDark),
                                    children: [
                                      TextSpan(
                                        text: '${ing['quantity']} ',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      TextSpan(text: ing['item']),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 24),

                    // Steps
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...recipe.steps.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(fontSize: 16, color: AppTheme.textDark, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
