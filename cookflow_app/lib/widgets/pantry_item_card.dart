import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../theme.dart';

class PantryItemCard extends StatelessWidget {
  final PantryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PantryItemCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getExpiryColor() {
    if (item.isExpired) {
      return AppTheme.errorRed;
    } else if (item.isExpiringSoon) {
      return Colors.orange;
    } else {
      return AppTheme.accentGreen;
    }
  }

  String _getExpiryText() {
    if (item.expiryDate == null) {
      return 'No expiry date';
    }
    
    final days = item.daysUntilExpiry!;
    
    if (days < 0) {
      return 'Expired ${-days} days ago';
    } else if (days == 0) {
      return 'Expires today!';
    } else if (days == 1) {
      return 'Expires tomorrow';
    } else if (days <= 7) {
      return 'Expires in $days days';
    } else {
      return 'Expires ${item.expiryDate!.year}-${item.expiryDate!.month.toString().padLeft(2, '0')}-${item.expiryDate!.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiryColor = _getExpiryColor();
    final expiryText = _getExpiryText();

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            // Icon indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: expiryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                item.expiryDate == null
                    ? Icons.inventory_2
                    : item.isExpired
                        ? Icons.dangerous
                        : item.isExpiringSoon
                            ? Icons.warning_amber
                            : Icons.check_circle,
                color: expiryColor,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),

            // Item info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.quantity,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMedium,
                        ),
                  ),
                  if (item.category != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        item.category!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: expiryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        expiryText,
                        style: TextStyle(
                          fontSize: 12,
                          color: expiryColor,
                          fontWeight: item.isExpired || item.isExpiringSoon
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  color: AppTheme.primaryOrange,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  color: AppTheme.errorRed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
