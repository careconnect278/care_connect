import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:care_connect/view/alert_screen.dart'; // Import your alert screen
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

// Class responsible for managing notifications
class NotificationServices {
  // Instance of FirebaseMessaging
  final firebaseMessging = FirebaseMessaging.instance;
  
  // Android notification channel for local notifications
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "high_importance_channel", // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high, // importance must be at low or higher level
  );

  // Instance of FlutterLocalNotificationsPlugin for local notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  initNotifications() async {
    await firebaseMessging.requestPermission(
      alert: true,
      sound: true,
    );
    initPushNotifications();
    initLocalnotification();
  }

  // Get Firebase Cloud Messaging token
  getToken() async {
    final token = await firebaseMessging.getToken();
    return token;
  }

  // Initialize push notifications
  initPushNotifications() async {
    await firebaseMessging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true);
    firebaseMessging.getInitialMessage().then(handleMessages);

    FirebaseMessaging.onBackgroundMessage(handleMessages);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) {
        return;
      }
      // Show local notification when message is received
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  playSound: true,
                  priority: Priority.high,
                  channelDescription: channel.description,
                  icon: "@drawable/ic_launcher")),
          payload: jsonEncode(message.toMap()));
    });
  }

  // Initialize local notifications
  initLocalnotification() async {
    const String navigationActionId = 'id_3';

    var initializationSettings = const InitializationSettings(
        android: AndroidInitializationSettings("@drawable/ic_launcher"));
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        final message =
            RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!));
        print(notificationResponse.notificationResponseType);
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            handleMessages(message);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              handleMessages(message);
            }
            break;
        }
      },
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Server key for sending notifications via FCM
  static const String _serverKey =
      'AAAAcTLeMSE:APA91bE9fDuwWXrkw7ZJb03PPn8h0W_VEf-5wiaUdPDLGIO-qKzu851ruX0-VNRk53tHamZVxZVgZfFib-jjFcq76Fq7aEdo-jhf-VjlKPa2VplS0KxQHPPoK61_yKSH4tBUL-hiXcj-';

  // Send notification via FCM
  Future<bool> sendNotification(String title, String body, String to,
      Map<String, dynamic> data, String para) async {
    debugPrint(para);
    try {
      final url = Uri.parse('https://fcm.googleapis.com/fcm/send');
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode({
          'notification': {'title': title, 'body': body},
          'to': to.trim(),
          'data': data, // Include payload here
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }
}

// Function to handle incoming messages
Future handleMessages(RemoteMessage? remoteMessage) async {
  debugPrint(remoteMessage.toString());
  if (remoteMessage == null) return;
  Get.toNamed(AlertScreen.route, arguments: remoteMessage);
}
