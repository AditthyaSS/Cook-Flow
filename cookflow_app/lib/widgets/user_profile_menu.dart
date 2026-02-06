import 'package:flutter/material.dart';
import 'package:cookflow_app/services/auth_service.dart';

/// User profile menu widget for app bar
/// Shows user avatar and provides quick access to account actions
class UserProfileMenu extends StatelessWidget {
  const UserProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 50),
      icon: CircleAvatar(
        radius: 18,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          (user.displayName?.substring(0, 1) ?? user.email?.substring(0, 1) ?? 'U').toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'User',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Divider(height: 16),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings),
              SizedBox(width: 12),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('Sign Out', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'settings':
            Navigator.pushNamed(context, '/settings');
            break;
          case 'signout':
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
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            }
            break;
        }
      },
    );
  }
}
