import 'package:flutter/material.dart';
import '../theme.dart';

enum PremiumBadgeSize { small, medium, large }
enum PremiumBadgeVariant { profile, featureLock, upgradeButton }

class PremiumBadge extends StatefulWidget {
  final bool isPremium;
  final PremiumBadgeSize size;
  final PremiumBadgeVariant variant;
  final VoidCallback? onUpgradeTap;

  const PremiumBadge({
    super.key,
    required this.isPremium,
    this.size = PremiumBadgeSize.medium,
    this.variant = PremiumBadgeVariant.profile,
    this.onUpgradeTap,
  });

  @override
  State<PremiumBadge> createState() => _PremiumBadgeState();
}

class _PremiumBadgeState extends State<PremiumBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case PremiumBadgeVariant.profile:
        return _buildProfileBadge();
      case PremiumBadgeVariant.featureLock:
        return _buildFeatureLock();
      case PremiumBadgeVariant.upgradeButton:
        return _buildUpgradeButton();
    }
  }

  Widget _buildProfileBadge() {
    final double badgeHeight = _getBadgeHeight();
    final double fontSize = _getFontSize();
    final double iconSize = _getIconSize();

    if (widget.isPremium) {
      return AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            height: badgeHeight,
            padding: EdgeInsets.symmetric(
              horizontal: badgeHeight * 0.4,
              vertical: badgeHeight * 0.2,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.premiumGold,
                  AppTheme.premiumGoldLight,
                  AppTheme.premiumGold,
                ],
                stops: [
                  (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                  _shimmerAnimation.value.clamp(0.0, 1.0),
                  (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                ],
              ),
              borderRadius: BorderRadius.circular(badgeHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.premiumGold.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  size: iconSize,
                  color: Colors.white,
                ),
                SizedBox(width: badgeHeight * 0.15),
                Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Container(
        height: badgeHeight,
        padding: EdgeInsets.symmetric(
          horizontal: badgeHeight * 0.4,
          vertical: badgeHeight * 0.2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(badgeHeight / 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_outline,
              size: iconSize,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            SizedBox(width: badgeHeight * 0.15),
            Text(
              'Free',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFeatureLock() {
    final double iconSize = _getIconSize() * 1.2;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.premiumGold, AppTheme.premiumGoldLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.premiumGold.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.lock_rounded,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return InkWell(
      onTap: widget.onUpgradeTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppTheme.premiumGradientStart,
              AppTheme.premiumGradientEnd,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Upgrade to Premium',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getBadgeHeight() {
    switch (widget.size) {
      case PremiumBadgeSize.small:
        return 28.0;
      case PremiumBadgeSize.medium:
        return 36.0;
      case PremiumBadgeSize.large:
        return 44.0;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case PremiumBadgeSize.small:
        return 12.0;
      case PremiumBadgeSize.medium:
        return 14.0;
      case PremiumBadgeSize.large:
        return 16.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case PremiumBadgeSize.small:
        return 16.0;
      case PremiumBadgeSize.medium:
        return 20.0;
      case PremiumBadgeSize.large:
        return 24.0;
    }
  }
}
