import 'package:flutter/material.dart';
import '../theme.dart';
import 'premium_badge.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final bool isPremium;
  final String planType; // 'Free', 'Monthly', 'Annual'
  final DateTime? renewalDate;
  final VoidCallback? onUpgrade;
  final VoidCallback? onManage;

  const SubscriptionStatusCard({
    super.key,
    required this.isPremium,
    required this.planType,
    this.renewalDate,
    this.onUpgrade,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isPremium
            ? const LinearGradient(
                colors: [
                  AppTheme.premiumGradientStart,
                  AppTheme.premiumGradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPremium ? null : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: isPremium
                ? AppTheme.premiumGold.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPremium
                        ? Colors.white
                        : Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                PremiumBadge(
                  isPremium: isPremium,
                  size: PremiumBadgeSize.medium,
                  variant: PremiumBadgeVariant.profile,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPlanInfo(context),
            if (renewalDate != null && isPremium) ...[
              const SizedBox(height: 12),
              _buildRenewalInfo(context),
            ],
            const SizedBox(height: 20),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanInfo(BuildContext context) {
    String description;
    IconData icon;

    if (isPremium) {
      if (planType == 'Annual') {
        description = '\$39.99/year • Save 33%';
        icon = Icons.calendar_month_rounded;
      } else {
        description = '\$4.99/month';
        icon = Icons.calendar_today_rounded;
      }
    } else {
      description = 'Limited features';
      icon = Icons.info_outline_rounded;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isPremium
              ? Colors.white.withOpacity(0.9)
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
        const SizedBox(width: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: isPremium
                ? Colors.white.withOpacity(0.9)
                : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildRenewalInfo(BuildContext context) {
    final formattedDate = _formatDate(renewalDate!);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_renew_rounded,
            size: 18,
            color: Colors.white.withOpacity(0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Renews on $formattedDate',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isPremium) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onManage,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
          child: const Text(
            'Manage Subscription',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onUpgrade,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: 4,
            shadowColor: AppTheme.primaryOrange.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.workspace_premium_rounded, size: 22),
              SizedBox(width: 8),
              Text(
                'Upgrade to Premium',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
