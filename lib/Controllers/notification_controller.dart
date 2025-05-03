import 'package:flutter/foundation.dart';
import '../Models/notification_model.dart';

class NotificationController extends ChangeNotifier {
  final NotificationModel model;

  NotificationController(this.model);

  List<Map<String, dynamic>> get notifications => model.notifications;

  void addNotification(String icon, String title, String message, String time) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    model.saveNotification(id, icon, title, message, time);
    debugPrint('NotificationController: Added notification: $title - $message');
    notifyListeners();
  }

  void clearNotifications() {
    model.notifications.clear();
    debugPrint('NotificationController: Cleared notifications');
    notifyListeners();
  }

  void removeNotification(String id) {
    model.deleteNotification(id);
    debugPrint('NotificationController: Removed notification with id: $id');
    notifyListeners();
  }
}
