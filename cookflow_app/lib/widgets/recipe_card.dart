import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

class RecipeCard extends StatelessWidget {
  final RecipeData recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Servings
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.restaurant,
                        size: 16,
                        color: AppTheme.accentGreen,
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        recipe.servings.toString(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.accentGreen,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Time Information Badges
            if (recipe.prepTimeMinutes != null || recipe.cookTimeMinutes != null) ...[\n              const SizedBox(height: AppTheme.spacingM),\n              Wrap(\n                spacing: AppTheme.spacingS,\n                runSpacing: AppTheme.spacingS,\n                children: [\n                  if (recipe.prepTimeMinutes != null)\n                    _buildTimeBadge(\n                      context,\n                      Icons.schedule,\n                      'Prep: ${recipe.prepTimeMinutes} min',\n                      AppTheme.primaryOrange,\n                    ),\n                  if (recipe.cookTimeMinutes != null)\n                    _buildTimeBadge(\n                      context,\n                      Icons.timer,\n                      'Cook: ${recipe.cookTimeMinutes} min',\n                      AppTheme.accentGreen,\n                    ),\n                  if (recipe.prepTimeMinutes != null && recipe.cookTimeMinutes != null)\n                    _buildTimeBadge(\n                      context,\n                      Icons.access_time,\n                      'Total: ${recipe.prepTimeMinutes! + recipe.cookTimeMinutes!} min',\n                      AppTheme.textMedium,\n                    ),\n                ],\n              ),\n            ],\n            
            const SizedBox(height: AppTheme.spacingL),
            
            // Ingredients Section
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryOrange,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ...recipe.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.fiber_manual_record,
                        size: 8,
                        color: AppTheme.primaryOrange,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: [
                              TextSpan(
                                text: ingredient.quantity,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              TextSpan(
                                text: ' ${ingredient.item}',
                                style: const TextStyle(
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Steps Section
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryOrange,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            ...recipe.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          step,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBadge(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
