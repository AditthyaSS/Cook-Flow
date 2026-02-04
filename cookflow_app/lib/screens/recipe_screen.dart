import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../widgets/recipe_card.dart';
import '../widgets/json_viewer.dart';
import '../widgets/loading_shimmer.dart';
import '../theme.dart';
import '../utils/recipe_formatter.dart';
import '../utils/recipe_examples.dart';
import 'grocery_list_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  RecipeData? _extractedRecipe;
  ExtractionMetadata? _extractionMetadata;
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
      _extractionMetadata = null;
    });

    try {
      final result = await ApiService.extractRecipe(rawText);
      setState(() {
        _extractedRecipe = result['recipe'] as RecipeData;
        _extractionMetadata = result['metadata'] as ExtractionMetadata;
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

  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        setState(() {
          _textController.text = clipboardData.text!;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppTheme.spacingM),
                Text('Pasted from clipboard'),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            margin: const EdgeInsets.all(AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to paste from clipboard');
    }
  }

  void _loadExample(int index) {
    setState(() {
      _textController.text = RecipeExamples.getExample(index);
      _extractedRecipe = null;
      _extractionMetadata = null;
      _errorMessage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded: ${RecipeExamples.getExampleName(index)}'),
        backgroundColor: AppTheme.primaryOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(AppTheme.spacingM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    );
  }

  Future<void> _generateGroceryList() async {
    if (_extractedRecipe == null) return;

    setState(() => _isLoading = true);

    try {
      final groceryList = await ApiService.generateGroceryList([_extractedRecipe!]);
      
      setState(() => _isLoading = false);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroceryListScreen(groceryList: groceryList),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to generate grocery list: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _saveRecipe() async {
    if (_extractedRecipe == null) return;

    try {
      final recipe = Recipe(
        title: _extractedRecipe!.title,
        servings: _extractedRecipe!.servings.toString(),
        ingredients: _extractedRecipe!.ingredients
            .map((ing) => {'quantity': ing.quantity, 'item': ing.item})
            .toList(),
        steps: _extractedRecipe!.steps,
        prepTimeMinutes: _extractedRecipe!.prepTimeMinutes,
        cookTimeMinutes: _extractedRecipe!.cookTimeMinutes,
        difficulty: _extractedRecipe!.difficulty,
        cuisine: _extractedRecipe!.cuisine,
        tags: _extractedRecipe!.tags,
        notes: _extractedRecipe!.notes,
      );

      await DatabaseService.instance.createRecipe(recipe);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: AppTheme.spacingM),
              Text('Recipe saved successfully!'),
            ],
          ),
          backgroundColor: AppTheme.accentGreen,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to save recipe: ${e.toString()}');
    }
  }

  Future<void> _shareRecipe() async {
    if (_extractedRecipe == null) return;

    try {
      final formattedText = RecipeFormatter.formatRecipeData(_extractedRecipe!);
      await Share.share(
        formattedText,
        subject: '🍳 ${_extractedRecipe!.title}',
      );
    } catch (e) {
      _showError('Failed to share recipe: ${e.toString()}');
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recipe Text',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Row(
                              children: [
                                // Try Example button
                                PopupMenuButton<int>(
                                  icon: Icon(Icons.lightbulb, color: AppTheme.primaryOrange),
                                  tooltip: 'Try Example Recipe',
                                  onSelected: _loadExample,
                                  itemBuilder: (context) => List.generate(
                                    RecipeExamples.count,
                                    (index) => PopupMenuItem(
                                      value: index,
                                      child: Text(RecipeExamples.getExampleName(index)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                // Paste button
                                IconButton(
                                  icon: Icon(Icons.content_paste, color: AppTheme.accentGreen),
                                  tooltip: 'Paste from Clipboard',
                                  onPressed: _pasteFromClipboard,
                                ),
                              ],
                            ),
                          ],
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
                
                // Quality Score and Warnings (if available)
                if (_extractionMetadata != null && _extractedRecipe != null) ...[
                  Card(
                    color: _extractionMetadata!.qualityScore >= 0.8 
                        ? Colors.green.shade50 
                        : _extractionMetadata!.qualityScore >= 0.6
                            ? Colors.orange.shade50
                            : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _extractionMetadata!.qualityScore >= 0.8
                                    ? Icons.check_circle
                                    : Icons.info,
                                color: _extractionMetadata!.qualityScore >= 0.8
                                    ? AppTheme.accentGreen
                                    : AppTheme.primaryOrange,
                              ),
                              const SizedBox(width: AppTheme.spacingS),
                              Text(
                                'Quality: ${(_extractionMetadata!.qualityScore * 100).toInt()}%',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_extractionMetadata!.warnings.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingS),
                            Wrap(
                              spacing: AppTheme.spacingS,
                              runSpacing: AppTheme.spacingS,
                              children: _extractionMetadata!.warnings.map((warning) {
                                return Chip(
                                  label: Text(
                                    warning,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  backgroundColor: Colors.orange.shade100,
                                  padding: const EdgeInsets.all(4),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                ],
                if (_isLoading) ...[
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: const RecipeCardShimmer(),
                  ),
                ] else if (_extractedRecipe != null) ...[
                  RecipeCard(recipe: _extractedRecipe!),
                  const SizedBox(height: AppTheme.spacingM),
                  
                  // Phase 2: Grocery List Button
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Next Steps',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingM),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _generateGroceryList,
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Generate Grocery List'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              backgroundColor: AppTheme.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _saveRecipe,
                            icon: const Icon(Icons.bookmark),
                            label: const Text('Save Recipe'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              foregroundColor: AppTheme.accentGreen,
                              side: BorderSide(color: AppTheme.accentGreen),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingS),
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : _shareRecipe,
                            icon: const Icon(Icons.share),
                            label: const Text('Share Recipe'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              foregroundColor: AppTheme.primaryOrange,
                              side: BorderSide(color: AppTheme.primaryOrange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
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
