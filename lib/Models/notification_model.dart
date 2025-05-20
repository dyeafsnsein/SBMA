import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  List<Map<String, dynamic>> _notifications = [];
  final bool _useFirebase = true; // Set to true to enable Firebase storage

  List<Map<String, dynamic>> get notifications => _notifications;

  // Save notification both locally and to Firebase if user is logged in
  Future<void> saveNotification(
      String id, String icon, String title, String message, String time) async {
    final notification = {
      'id': id,
      'icon': icon,
      'title': title,
      'message': message,
      'time': time,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    _notifications.add(notification);
    
    // Save to Firebase if enabled and user is logged in
    if (_useFirebase) {
      await _saveToFirebase(notification);
    }
  }

  // Delete notification both locally and from Firebase
  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((notification) => notification['id'] == id);
    
    // Delete from Firebase if enabled and user is logged in
    if (_useFirebase) {
      await _deleteFromFirebase(id);
    }
  }
  // Save notification to Firebase
  Future<void> _saveToFirebase(Map<String, dynamic> notification) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(notification['id'])
            .set(notification);
        debugPrint('NotificationModel: Saved notification to Firebase: ${notification['title']}');
      }
    } catch (e) {
      debugPrint('NotificationModel: Error saving notification to Firebase: $e');
    }
  }
  
  // Delete notification from Firebase
  Future<void> _deleteFromFirebase(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .doc(id)
            .delete();
        debugPrint('NotificationModel: Deleted notification from Firebase: $id');
      }
    } catch (e) {
      debugPrint('NotificationModel: Error deleting notification from Firebase: $e');
    }
  }
  
  // Load notifications from Firebase
  Future<void> loadFromFirebase() async {
    if (!_useFirebase) return;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .get();
            
        _notifications = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'icon': doc['icon'] ?? 'lib/assets/Notification.png',
                  'title': doc['title'] ?? 'No Title',
                  'message': doc['message'] ?? 'No Message',
                  'time': doc['time'] ?? '',
                  'timestamp': doc['timestamp'] ?? 0,
                })
            .toList();
            
        debugPrint('NotificationModel: Loaded ${_notifications.length} notifications from Firebase');
      }
    } catch (e) {
      debugPrint('NotificationModel: Error loading notifications from Firebase: $e');
    }
  }
}
