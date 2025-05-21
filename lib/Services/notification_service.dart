import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/notification_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  // Channel IDs for different notification types
  static const String transactionReminderChannelId = 'transaction_reminder_channel';
  static const String testChannelId = 'test_channel';
  static const int transactionReminderId = 999;
  static const int debugNotificationId = 888;
  
  /// Initialize the notification service
  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    // Create notification channels for Android 8.0+
    await _setupNotificationChannels();
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification clicked handler
      },
    );
  }
  
  // Setup notification channels for Android
  Future<void> _setupNotificationChannels() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
                  
      if (androidImplementation != null) {
        // Transaction reminders channel
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            transactionReminderChannelId,
            'Transaction Reminders',
            description: 'Regular reminders to fill your transactions',
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
      }
    }
  }

  /// Request notification permissions
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
          
      if (Platform.version.contains('13') || Platform.version.contains('14')) {
        await androidPlugin?.requestNotificationsPermission();
      }
    } else if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Show a test notification
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
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await _flutterLocalNotificationsPlugin.show(
      debugNotificationId,
      'Test Notification',
      'This is a test notification from SBMA',
      platformChannelSpecifics,
      payload: 'test',
    );
  }

  /// Show budget tips as notifications 
  Future<void> showBudgetTips(BuildContext context, List<String> tips) async {
    // Just log the tips, don't show actual notifications
    for (int i = 0; i < tips.length && i < 3; i++) {
      debugPrint('Budget tip ${i + 1}: ${tips[i]}');
    }
    return;
  }

  /// Schedule a repeating reminder with the specified interval
  Future<void> scheduleRepeatingReminder({
    required int hours,
    required String title,
    required String body,
  }) async {
    // Ensure timezone is initialized
    tz.initializeTimeZones();
    final localTz = tz.local;
    
    // Calculate next scheduled time
    final now = tz.TZDateTime.now(localTz);
    var scheduledTime = tz.TZDateTime(
      localTz, 
      now.year, 
      now.month, 
      now.day, 
      now.hour, 
      now.minute + 1, // Schedule 1 minute from now for first occurrence
    );
    
    // If scheduled time is in the past, add a minute
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(minutes: 1));
    }
          
    // Create notification details with improved settings
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      transactionReminderChannelId,
      'Transaction Reminders',
      channelDescription: 'Regular reminders to fill your transactions',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
      autoCancel: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    // Cancel any existing reminders to avoid duplicates
    await _flutterLocalNotificationsPlugin.cancel(transactionReminderId);
    
    // Schedule the notification
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      transactionReminderId, 
      title,
      body,
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    // Set up a repeating timer to re-schedule the notification at the specified interval
    Timer.periodic(Duration(hours: hours), (timer) async {
      final now = tz.TZDateTime.now(localTz);
      final nextTime = tz.TZDateTime(
        localTz, 
        now.year, 
        now.month, 
        now.day, 
        now.hour + hours,
      );
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        transactionReminderId, 
        title,
        body,
        nextTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    });
  }

  /// Show an immediate debug notification
  Future<void> showImmediateDebugNotification() async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'debug_channel',
      'Debug Notifications',
      channelDescription: 'Channel for immediate debug notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      debugNotificationId,
      'Debug Notification',
      'This is a debug notification from SBMA. If you see this, notifications are working!',
      platformChannelSpecifics,
      payload: 'debug',
    );
  }

  /// Load notifications from Firebase and SharedPreferences into the model
  Future<void> loadNotifications(NotificationModel model) async {
    // Clear existing notifications in model
    model.clearNotifications();
    
    try {
      // First try to load from Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .get();
        
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final notification = model.createNotificationObject(
              doc.id,
              data['icon'] ?? 'lib/assets/Notification.png',
              data['title'] ?? 'Untitled',
              data['message'] ?? 'No message',
              data['time'] ?? '',
            );
            
            model.addNotification(notification);
          }
          return;
        }
      }
      
      // If Firebase failed or no docs, fall back to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('notifications') ?? [];
      final deletedTip = prefs.getString('deleted_tip');
      
      for (var s in saved) {
        final parts = s.split('|');
        if (parts.length == 5) {
          final tipData = '${parts[1]}|${parts[2]}|${parts[3]}';
          final exists = model.notifications
              .any((n) => n['title'] == parts[2] && n['message'] == parts[3]);
          if (!exists && (deletedTip == null || tipData != deletedTip)) {
            final notification = model.createNotificationObject(
              parts[0], // id
              parts[1], // icon
              parts[2], // title
              parts[3], // message
              parts[4], // time
            );
            model.addNotification(notification);
            
            // Also sync to Firebase if user is logged in
            if (user != null) {
              await _saveNotificationToFirebase(notification);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  /// Save a notification to both SharedPreferences and Firebase
  Future<void> saveNotification(Map<String, dynamic> notification) async {
    // Save to SharedPreferences
    _saveToSharedPreferences([notification]);
    
    // Save to Firebase if user is logged in
    await _saveNotificationToFirebase(notification);
  }

  /// Remove a notification
  Future<void> removeNotification(String id) async {
    // Remove from SharedPreferences by loading, removing, and saving
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('notifications') ?? [];
    final newSaved = saved.where((s) {
      final parts = s.split('|');
      return parts[0] != id;
    }).toList();
    await prefs.setStringList('notifications', newSaved);
    
    // Remove from Firebase if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint('Error removing notification from Firebase: $e');
      }
    }
  }

  /// Clear all notifications from SharedPreferences and Firebase
  Future<void> clearAllNotifications() async {
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notifications', []);
    
    // Clear Firebase if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final batch = FirebaseFirestore.instance.batch();
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .get();
        
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
      } catch (e) {
        debugPrint('Error clearing notifications from Firebase: $e');
      }
    }
  }

  /// Mark a tip as deleted in SharedPreferences
  Future<void> markTipAsDeleted(Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();
    final tipData = '${notification['icon']}|${notification['title']}|${notification['message']}';
    await prefs.setString('deleted_tip', tipData);
  }

  /// Clear all cached tips
  Future<void> clearCachedTips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('budget_tip_0');
    await prefs.remove('budget_tip_1');
    await prefs.remove('budget_tip_2');
    await prefs.remove('deleted_tip');
  }

  /// Cache a tip in SharedPreferences
  Future<void> cacheTip(String title, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final tipData = 'lib/assets/Notification.png|$title|$message';
    await prefs.setString('budget_tip_0', tipData);
  }

  // Helper method to save notifications to SharedPreferences
  Future<void> _saveToSharedPreferences(List<Map<String, dynamic>> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList('notifications') ?? [];
      
      // Convert notifications to strings
      final notificationStrings = notifications.map((n) =>
        '${n['id']}|${n['icon']}|${n['title']}|${n['message']}|${n['time']}'
      ).toList();
      
      // Combine with existing
      final allNotifications = [...existing, ...notificationStrings];
      
      await prefs.setStringList('notifications', allNotifications);
    } catch (e) {
      debugPrint('Error saving notifications to SharedPreferences: $e');
    }
  }

  // Helper method to save a notification to Firebase
  Future<void> _saveNotificationToFirebase(Map<String, dynamic> notification) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notification['id'])
          .set({
            'icon': notification['icon'],
            'title': notification['title'],
            'message': notification['message'],
            'time': notification['time'],
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
    } catch (e) {
      debugPrint('Error saving notification to Firebase: $e');
    }
  }
}
