import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class NotificationPermissionService {
  static const MethodChannel _channel = MethodChannel('com.example.test_app/notification');

  // Check if notifications are enabled for the app
  static Future<bool> areNotificationsEnabled() async {
    if (!Platform.isAndroid) return true; // Only implemented for Android for now
    
    try {
      final bool result = await _channel.invokeMethod('areNotificationsEnabled');
      debugPrint('NotificationPermissionService: Notifications enabled: $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint('NotificationPermissionService: Failed to check notification status: ${e.message}');
      return true; // Default to true on error
    }
  }

  // Open notification settings page
  static Future<void> openNotificationSettings() async {
    if (!Platform.isAndroid) return; // Only implemented for Android for now
    
    try {
      await _channel.invokeMethod('openNotificationSettings');
      debugPrint('NotificationPermissionService: Opened notification settings');
    } on PlatformException catch (e) {
      debugPrint('NotificationPermissionService: Failed to open notification settings: ${e.message}');
    }
  }

  // Show dialog to prompt user to enable notifications
  static Future<void> showEnableNotificationsDialog(BuildContext context) async {
    final bool enabled = await areNotificationsEnabled();
    if (!enabled && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enable Notifications'),
            content: const Text(
              'Notifications are disabled for this app. Please enable them in the app settings to receive transaction reminders.',
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Not Now'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Enable'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openNotificationSettings();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
