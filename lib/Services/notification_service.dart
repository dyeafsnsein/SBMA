import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  // Define channel IDs as constants for consistency
  static const String transactionReminderChannelId = 'transaction_reminder_channel';
  static const String testChannelId = 'test_channel';
  static const String budgetTipsChannelId = 'budget_tips_channel';
  
  // Track if reminders are enabled - static to ensure it persists
  static bool _remindersEnabled = false;
  static Timer? _recurringReminderTimer;
  
  // Returns the current status of reminders
  bool get remindersEnabled => _remindersEnabled;
  
  Future<void> init() async {
    debugPrint('NotificationService: Initializing');
    tz.initializeTimeZones();
    
    // Use 'mipmap/ic_launcher' instead of 'app_icon' as it's the default app icon in Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    // Create notification channels for Android 8.0+
    await _setupNotificationChannels();
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
            'NotificationService: Notification clicked: [36m${response.payload}[0m');
        // You can handle click actions here
      },
    );
    debugPrint('NotificationService: Initialized');
  }
  
  // Setup notification channels explicitly for Android 8.0+
  Future<void> _setupNotificationChannels() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
                  
      if (androidImplementation != null) {
        // Transaction reminders channel
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            transactionReminderChannelId,
            'Transaction Reminders',
            description: 'Daily reminders to fill your transactions',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            showBadge: true,
          ),
        );
        
        // Test notifications channel
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            testChannelId,
            'Test Notifications',
            description: 'Channel for test notifications',
            importance: Importance.high,
            enableVibration: true,
          ),
        );
        
        // Budget tips channel
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            budgetTipsChannelId,
            'Budget Tips',
            description: 'Channel for budget tips notifications',
            importance: Importance.high,
            enableVibration: true,
          ),
        );
        
        debugPrint('NotificationService: Created notification channels');
      }
    }
  }

  Future<void> requestPermissions() async {
    debugPrint('NotificationService: Requesting permissions');
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (Platform.version.contains('13') || Platform.version.contains('14')) {
        final granted = await androidPlugin?.requestNotificationsPermission();
        debugPrint('NotificationService: Android permission granted: $granted');
        if (granted == null || !granted) {
          debugPrint(
              'NotificationService: Notification permission not granted');
        }
      } else {
        debugPrint(
            'NotificationService: Skipping permission request (Android 12 or lower)');
      }
    } else if (Platform.isIOS) {
      final granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('NotificationService: iOS permission granted: $granted');
    }
  }

  Future<void> showTestNotification(BuildContext context) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      testChannelId,
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification from SBMA',
      platformChannelSpecifics,
      payload: 'test',
    );
    debugPrint('NotificationService: Test notification shown');
  }

  // This is a non-recurring notification that's meant to be displayed once
  // and does not create entries in the notifications list
  Future<void> showBudgetTips(BuildContext context, List<String> tips) async {
    debugPrint('NotificationService: Scheduling budget tips: $tips');
    try {
      // Ensure timezone is initialized
      tz.initializeTimeZones();
      final localTz = tz.local;
      for (int i = 0; i < tips.length && i < 3; i++) {
        // Use a longer delay to ensure future time
        final scheduledTime =
            tz.TZDateTime.now(localTz).add(Duration(seconds: 10 + i * 5));
        final androidPlatformChannelSpecifics = AndroidNotificationDetails(
          budgetTipsChannelId + '_$i',
          'Budget Tips',
          channelDescription: 'Channel for budget tips notifications',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(tips[i]),
          icon: '@mipmap/ic_launcher',
          visibility: NotificationVisibility.public,
          playSound: true,
          enableVibration: true,
        );
        final platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
        );
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          i + 100, // Use a different ID range (100-102) to avoid conflicts
          'Budget Tip [36m${i + 1}[0m',
          tips[i],
          scheduledTime,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint(
            'NotificationService: Scheduled budget tip [36m${i + 1}[0m at $scheduledTime');
      }
    } catch (e, stackTrace) {
      debugPrint(
          'NotificationService: Error scheduling budget tips: $e\n$stackTrace');
      rethrow;
    }
  }

  // Schedule a daily transaction reminder notification
  Future<void> scheduleTransactionReminder({bool testMode = false}) async {
    debugPrint('NotificationService: Scheduling transaction reminder, enabled=$_remindersEnabled');
    
    // Make sure to set the flag to true
    _remindersEnabled = true;
    
    // Cancel any existing recurring timer to avoid duplicates
    _recurringReminderTimer?.cancel();
    _recurringReminderTimer = null;
    
    try {
      // Ensure timezone is initialized
      tz.initializeTimeZones();
      final localTz = tz.local;
      
      // For test mode (every 30 seconds) or daily at 8 PM
      final Duration interval = testMode
          ? const Duration(seconds: 30)
          : const Duration(days: 1);

      // Calculate next scheduled time
      final now = tz.TZDateTime.now(localTz);
      final scheduledTime = testMode
          ? now.add(const Duration(seconds: 5)) // Start in 5 seconds for testing
          : tz.TZDateTime(localTz, now.year, now.month, now.day, 20, 0); // 8 PM daily

      // If scheduled time is in the past, add an interval
      final effectiveScheduledTime = scheduledTime.isBefore(now)
          ? scheduledTime.add(interval)
          : scheduledTime;
          
      // Create notification details with improved settings
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        transactionReminderChannelId,
        'Transaction Reminders',
        channelDescription: 'Daily reminders to fill your transactions',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        autoCancel: true,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true, // This helps with visibility on locked screens
      );

      const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // Cancel any existing reminders to avoid duplicates
      await _flutterLocalNotificationsPlugin.cancel(999);
      
      // Double-check that reminders are still enabled
      if (!_remindersEnabled) {
        debugPrint('NotificationService: Reminders were disabled during setup, canceling');
        return;
      }
      
      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        999, // Unique ID for transaction reminders
        'Transaction Reminder',
        'Fill your transactions for today',
        effectiveScheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: testMode ? null : DateTimeComponents.time,
      );

      debugPrint('NotificationService: Transaction reminder scheduled for $effectiveScheduledTime');

      // If in test mode, schedule the next one after this fires
      if (testMode && _remindersEnabled) {
        _setupRecurringTestReminders();
      }
    } catch (e, stackTrace) {
      debugPrint('NotificationService: Error scheduling transaction reminder: $e\n$stackTrace');
      rethrow;
    }
  }
  
  // Helper method to set up recurring test reminders
  Future<void> _setupRecurringTestReminders() async {
    // Check if reminders are still enabled before scheduling the next one
    if (!_remindersEnabled) {
      debugPrint('NotificationService: Skipping recurring reminder setup because reminders are disabled');
      return;
    }
    
    try {
      // Cancel any existing timer
      _recurringReminderTimer?.cancel();
      _recurringReminderTimer = null;
      
      // Only schedule the next reminder if reminders are still enabled
      if (_remindersEnabled) {
        // Set a delay before scheduling the next reminder
        _recurringReminderTimer = Timer(const Duration(seconds: 32), () async {
          // Double-check reminders are still enabled before executing
          if (_remindersEnabled) {
            await scheduleTransactionReminder(testMode: true);
            debugPrint('NotificationService: Set up next recurring reminder');
          } else {
            debugPrint('NotificationService: Reminder was disabled before the recurring timer executed');
          }
        });
      } else {
        debugPrint('NotificationService: Not setting up recurring reminders because they are disabled');
      }
    } catch (e) {
      debugPrint('NotificationService: Error setting up recurring reminders: $e');
    }
  }

  // Show an immediate notification for debugging purposes
  Future<void> showImmediateDebugNotification() async {
    debugPrint('NotificationService: Showing immediate debug notification');
    try {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'debug_channel',
        'Debug Notifications',
        channelDescription: 'Channel for immediate debug notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        visibility: NotificationVisibility.public,
        ticker: 'SBMA Debug Notification',
      );
      
      const platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      
      // Create and show the notification immediately
      await _flutterLocalNotificationsPlugin.show(
        888, // Debug notification ID
        'Debug Notification',
        'This is a debug notification from SBMA. If you see this, notifications are working!',
        platformChannelSpecifics,
        payload: 'debug',
      );
      
      debugPrint('NotificationService: Debug notification shown');
    } catch (e, stackTrace) {
      debugPrint('NotificationService: Error showing debug notification: $e\n$stackTrace');
    }
  }

  // Cancel transaction reminders
  Future<void> cancelTransactionReminders() async {
    debugPrint('NotificationService: Cancelling transaction reminders');
    
    // First set the flag to disable recurring reminders
    _remindersEnabled = false;
    
    // Cancel the recurring timer if it exists
    if (_recurringReminderTimer != null) {
      _recurringReminderTimer!.cancel();
      _recurringReminderTimer = null;
      debugPrint('NotificationService: Cancelled recurring reminder timer');
    }
    
    // Cancel all pending notifications
    await _flutterLocalNotificationsPlugin.cancel(999);
    debugPrint('NotificationService: Transaction reminders canceled');
    
    // Double-check that reminders are still disabled
    debugPrint('NotificationService: Reminders enabled status after cancellation: $_remindersEnabled');
  }
}
