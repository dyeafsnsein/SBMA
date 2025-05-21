import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;
  
  // Set notifications list (used when loading from Firebase through the service)
  void setNotifications(List<Map<String, dynamic>> notifications) {
    _notifications = notifications;
  }
  
  // Fetch notifications from Firebase for the current user
  Future<void> fetchNotificationsFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('NotificationModel: No user logged in to fetch notifications');
        return;
      }
      
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();
          
      _notifications = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'icon': doc.data()['icon'] ?? 'lib/assets/Notification.png',
                'title': doc.data()['title'] ?? 'Notification',
                'message': doc.data()['message'] ?? '',
                'time': doc.data()['time'] ?? '',
                'timestamp': doc.data()['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
              })
          .toList();
      
      debugPrint('NotificationModel: Fetched ${_notifications.length} notifications from Firebase');
    } catch (e) {
      debugPrint('NotificationModel: Error fetching notifications from Firebase: $e');
    }
  }
  // Add a notification to the local list
  void addNotification(Map<String, dynamic> notification) {
    _notifications.add(notification);
    debugPrint('NotificationModel: Added notification to local list: ${notification['title']}');
    // Save to Firebase in background
    _saveNotificationToFirebase(notification);
  }

  // Create a notification object
  Map<String, dynamic> createNotificationObject(
      String id, String icon, String title, String message, String time) {
    return {
      'id': id,
      'icon': icon,
      'title': title,
      'message': message,
      'time': time,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  // Save notification to Firebase
  Future<void> _saveNotificationToFirebase(Map<String, dynamic> notification) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('NotificationModel: No user logged in to save notification');
        return;
      }
      
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
            'timestamp': notification['timestamp'],
          });
      
      debugPrint('NotificationModel: Saved notification to Firebase: ${notification['id']}');
    } catch (e) {
      debugPrint('NotificationModel: Error saving notification to Firebase: $e');
    }
  }
  // Remove notification from local list and Firebase
  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((notification) => notification['id'] == id);
    debugPrint('NotificationModel: Removed notification from local list: $id');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('NotificationModel: No user logged in to remove notification');
        return;
      }
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(id)
          .delete();
          
      debugPrint('NotificationModel: Removed notification from Firebase: $id');
    } catch (e) {
      debugPrint('NotificationModel: Error removing notification from Firebase: $e');
    }
  }
  
  // Clear all notifications from local list and Firebase
  Future<void> clearNotifications() async {
    final notificationsToDelete = List<Map<String, dynamic>>.from(_notifications);
    _notifications.clear();
    debugPrint('NotificationModel: Cleared all notifications from local list');
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('NotificationModel: No user logged in to clear notifications');
        return;
      }
      
      // Delete each notification document from Firebase
      for (final notification in notificationsToDelete) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notification['id'])
            .delete();
      }
      
      debugPrint('NotificationModel: Cleared all notifications from Firebase');
    } catch (e) {
      debugPrint('NotificationModel: Error clearing notifications from Firebase: $e');
    }
  }
}
