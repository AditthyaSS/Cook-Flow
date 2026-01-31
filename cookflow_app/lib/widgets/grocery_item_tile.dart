import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import 'package:url_launcher/url_launcher.dart';

class GroceryItemTile extends StatelessWidget {
  final GroceryItem item;
  final ValueChanged<bool> onCheckedChanged;

  const GroceryItemTile({
    super.key,
    required this.item,
    required this.onCheckedChanged,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.textLight.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingL,
          vertical: AppTheme.spacingS,
        ),
        leading: Checkbox(
          value: item.isChecked,
          onChanged: (value) => onCheckedChanged(value ?? false),
          activeColor: AppTheme.accentGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? AppTheme.textLight : AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.quantity,
              style: TextStyle(
                color: item.isChecked ? AppTheme.textLight : AppTheme.textMedium,
                fontSize: 13,
              ),
            ),
            if (item.recipeTitle != null) ...[
              const SizedBox(height: 4),
              Text(
                'From: ${item.recipeTitle}',
                style: TextStyle(
                  color: AppTheme.accentGreen,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (item.affiliateUrl != null && !item.isChecked) ...[
              const SizedBox(height: AppTheme.spacingS),
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(item.affiliateUrl!),
                  icon: const Icon(Icons.shopping_cart, size: 16),
                  label: Text(
                    'Buy on ${item.network ?? "Amazon"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
