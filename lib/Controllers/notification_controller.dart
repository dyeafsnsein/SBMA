import 'package:flutter/material.dart';
import '../Models/notification_model.dart';

class NotificationController extends ChangeNotifier {
  final NotificationModel model;

  NotificationController(this.model);

  List<Map<String, dynamic>> get notifications => model.notifications;
}