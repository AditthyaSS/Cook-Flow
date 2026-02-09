import 'package:flutter/material.dart';
import 'package:cookflow_app/services/auth_service.dart';
import 'package:cookflow_app/services/firestore_service.dart';
import 'package:cookflow_app/services/notification_service.dart';
import 'package:cookflow_app/theme.dart';
import 'package:cookflow_app/widgets/subscription_status_card.dart';
import 'package:cookflow_app/screens/paywall_screen.dart';

/// User Profile Screen
/// Displays account details, settings, and subscription information
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = AuthService.instance.currentUser;
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    await NotificationService.instance.initialize();
    setState(() {
      _notificationsEnabled = NotificationService.instance.notificationsEnabled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(
          child: Text('Please sign in to view your profile'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: _editProfile,
          ),
        ],
      ),
      body: ListView(
        children: [
          // User Header Section
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    (user.displayName?.substring(0, 1) ?? user.email?.substring(0, 1) ?? 'U').toUpperCase(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                Text(
                  user.displayName ?? 'User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  user.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildAccountBadge(),
              ],
            ),
          ),

          // Account Information
          _buildSection(
            'Account Information',
            [
              _buildInfoTile(
                Icons.email,
                'Email',
                user.email ?? 'Not set',
                subtitle: user.emailVerified ? 'Verified' : 'Not verified',
                trailing: user.emailVerified
                    ? const Icon(Icons.verified, color: Colors.green, size: 20)
                    : TextButton(
                        onPressed: _sendVerificationEmail,
                        child: const Text('Verify'),
                      ),
              ),
              _buildInfoTile(
                Icons.phone,
                'Phone',
                user.phoneNumber ?? 'Not set',
              ),
              _buildInfoTile(
                Icons.calendar_today,
                'Member Since',
                _formatDate(user.metadata.creationTime),
              ),
              _buildInfoTile(
                Icons.login,
                'Last Sign In',
                _formatDate(user.metadata.lastSignInTime),
              ),
            ],
          ),

          // Subscription Section
          _buildSection(
            'Subscription',
            [
              _buildSubscriptionCard(),
            ],
          ),

          // Settings & Preferences
          _buildSection(
            'Settings & Preferences',
            [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('App Settings'),
                subtitle: const Text('Theme, notifications, and more'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                subtitle: const Text('Manage notification preferences'),
                trailing: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Switch(
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                      ),
              ),
            ],
          ),

          // Account Actions
          _buildSection(
            'Account Actions',
            [
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.orange),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changePassword,
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _signOut,
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: _deleteAccount,
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingXL),
        ],
      ),
    );
  }

  Widget _buildAccountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            'Free Plan', // Will be dynamic when Phase 4 is implemented
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingM,
            AppTheme.spacingL,
            AppTheme.spacingM,
            AppTheme.spacingS,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String value, {
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: subtitle.contains('Verified')
                    ? Colors.green
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ],
      ),
      trailing: trailing,
    );
  }

  Widget _buildSubscriptionCard() {
    // UI-only implementation - hardcoded as Free plan
    // Will be dynamic when RevenueCat is integrated
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: SubscriptionStatusCard(
        isPremium: false, // Hardcoded for now
        planType: 'Free',
        renewalDate: null,
        onUpgrade: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaywallScreen(),
            ),
          );
        },
        onManage: null,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing coming soon!\n\nYou\'ll be able to update your name, photo, and other details.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('A password reset email will be sent to your email address.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService.instance.resetPassword(user!.email!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await AuthService.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\n\n'
          'This action is PERMANENT and cannot be undone.\n\n'
          'All your recipes, pantry items, and data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Forever', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Deleting account...'),
            ],
          ),
        ),
      );

      try {
        // Delete all user data from Firestore
        await FirestoreService.instance.deleteAllUserData();
        
        // Delete the Firebase Auth account
        await AuthService.instance.deleteAccount();
        
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          
          // Note: Can't show SnackBar after navigation, but account is deleted
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _toggleNotifications(bool value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationService.instance.setNotificationsEnabled(value);
      setState(() {
        _notificationsEnabled = value;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Notifications enabled'
                  : 'Notifications disabled',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


}
