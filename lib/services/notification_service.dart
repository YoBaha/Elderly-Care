import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    await AwesomeNotifications().initialize(
      null, // Use default icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for motivational quotes',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.white,
        ),
      ],
    );
  }

  Future<void> showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'basic_channel',
        title: title,
        body: body,
      ),
    );
  }

  Future<void> showQuoteNotification() async {
    try {
      final apiService = ApiService('', this);
      final quote = await apiService.fetchMotivationalQuote();
      await showNotification('Daily Motivation', quote);
    } catch (e) {
      print('Error showing quote notification: $e');
    }
  }
}
