import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage notification preferences
/// Uses SharedPreferences for persistence across app sessions
class NotificationService {
  static const String _notificationsEnabledKey = 'notifications_enabled';
  
  static NotificationService? _instance;
  SharedPreferences? _prefs;
  
  NotificationService._();
  
  /// Get singleton instance
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }
  
  /// Initialize the service
  /// Must be called before using other methods
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Get current notification enabled state
  /// Returns true by default if not set
  bool get notificationsEnabled {
    return _prefs?.getBool(_notificationsEnabledKey) ?? true;
  }
  
  /// Set notification enabled state
  /// Returns true if successfully saved
  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (_prefs == null) {
      await initialize();
    }
    return await _prefs!.setBool(_notificationsEnabledKey, enabled);
  }
  
  /// Toggle notification state
  /// Returns the new state
  Future<bool> toggleNotifications() async {
    final newState = !notificationsEnabled;
    await setNotificationsEnabled(newState);
    return newState;
  }
  
  /// Clear all notification preferences
  Future<bool> clearPreferences() async {
    if (_prefs == null) {
      await initialize();
    }
    return await _prefs!.remove(_notificationsEnabledKey);
  }
}
