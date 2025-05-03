class NotificationModel {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  void saveNotification(
      String id, String icon, String title, String message, String time) {
    _notifications.add({
      'id': id,
      'icon': icon,
      'title': title,
      'message': message,
      'time': time,
    });
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((notification) => notification['id'] == id);
  }
}
