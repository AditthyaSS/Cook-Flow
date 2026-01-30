import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/json_viewer.dart';
import '../theme.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  RecipeData? _extractedRecipe;
  String? _errorMessage;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _extractRecipe() async {
    final rawText = _textController.text.trim();

    if (rawText.isEmpty) {
      _showError('Please paste or enter a recipe');
      return;
    }

    if (rawText.length < 50) {
      _showError('Recipe text must be at least 50 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _extractedRecipe = null;
    });

    try {
      final recipe = await ApiService.extractRecipe(rawText);
      setState(() {
        _extractedRecipe = recipe;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _showError(_errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppTheme.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu, color: AppTheme.primaryOrange),
            const SizedBox(width: AppTheme.spacingS),
            const Text('CookFlow'),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 48,
                          color: AppTheme.primaryOrange,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Extract Recipe',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          'Paste any recipe text and let AI structure it for you',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingL),
                
                // Input Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Recipe Text',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        TextField(
                          controller: _textController,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: 'Paste your recipe here...\n\nExample:\nChocolate Chip Cookies\n\nIngredients:\n- 2 cups flour\n- 1 cup butter\n- 1 cup sugar\n...',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _extractRecipe,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_fix_high),
                                      const SizedBox(width: AppTheme.spacingS),
                                      Text(
                                        _isLoading
                                            ? 'Extracting...'
                                            : 'Extract Recipe',
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacingL),
                
                // Results Section
                if (_extractedRecipe != null) ...[
                  RecipeCard(recipe: _extractedRecipe!),
                  const SizedBox(height: AppTheme.spacingM),
                  JsonViewer(data: _extractedRecipe!.toJson()),
                ],
                
                // Empty State
                if (!_isLoading && _extractedRecipe == null && _errorMessage == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingXL),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 64,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          Text(
                            'No recipe extracted yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.textMedium,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            'Paste a recipe above to get started',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
