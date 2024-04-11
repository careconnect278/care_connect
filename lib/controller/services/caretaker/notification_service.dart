import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:care_connect/view/alert_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class NotificationServices {
  final firebaseMessging = FirebaseMessaging.instance;
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "high_importance_channel", // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance
        .defaultImportance, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initNotifications() async {
    await firebaseMessging.requestPermission(
      alert: true,
      sound: true,
    );
    initPushNotifications();
    initLocalnotification();
  }

  getToken() async {
    final token = await firebaseMessging.getToken();
    return token;
  }

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
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description,
                  icon: "@drawable/ic_launcher")),
          payload: jsonEncode(message.toMap()));
    });
  }

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
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            handleBackgroundMessage(message);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              handleBackgroundMessage(message);
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

  static const String _serverKey =
      'AAAAcTLeMSE:APA91bFnAaCmGHNYnWdEoE5KN8M3Xl8C8Ej36xxCMtXpCYDIQthpiOi1FONhBJWwVzWXnJDzEIWT8oAV9SuuPJEAAwgWT8SLmcAdXOnMrzO-xoiIPUiLHAaKYmYzeLimBkMMIKCAJWTW';

  Future<bool> sendNotification( String title, String body,String to,Map<String ,dynamic>data) async {
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
          'to':
              to,
          'data': data, // Include payload here
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to send notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
}

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(message.notification!.title);
  print(message.notification!.body);
}

Future handleMessages(RemoteMessage? remoteMessage) async {
  print(remoteMessage);
  if (remoteMessage == null) return;
  Get.toNamed(AlertScreen.route,
      arguments: remoteMessage.notification!.title.toString());
}
