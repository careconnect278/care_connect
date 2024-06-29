// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/services/can_alert.dart';
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

  LoaderController loaderController = Get.put(LoaderController());
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
      log(jsonEncode(message.toMap()));
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
  Future sendNotificationNoise(
    String title,
    String body,
    String to,
    Map<String, dynamic> data,
    String para,
    bool isCaretaker,
  ) async {
    final token = await getToken();
    debugPrint(para);

    loaderController.aadsNoiseLogs("onSend notification Fuction");

    try {
      final url = Uri.parse('https://sendnotification-regbxotyqa-uc.a.run.app');
      loaderController.aadsNoiseLogs(
          "url:https://sendnotification-regbxotyqa-uc.a.run.app");
      var jsonEncode2 = jsonEncode({
        'notification': {'title': title, 'body': body},
        'token': isCaretaker ? to : token,
        'data': data, // Include payload here
      });
      loaderController.aadsleepLogs("token:$token");
      loaderController.aadsleepLogs("token:${token == to}");
      loaderController.aadsNoiseLogs("body:$jsonEncode2");
      log("body:$jsonEncode2");
      var headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };

      loaderController.aadsNoiseLogs("headers:$headers");

      if (isCaretaker) {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode2,
        );

        loaderController.aadsNoiseLogs(
            "responseStatusCode of caretaker:${response.statusCode}");
        loaderController
            .aadsNoiseLogs("responseBody of caretaker:${response.body}");

        if (response.statusCode == 200) {
        } else {
          debugPrint('Failed to send notification: ${response.body}');
        }
      } else {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode2,
        );

        loaderController.aadsNoiseLogs(
            "responseStatusCode of beneficiary:${response.statusCode}");
        loaderController
            .aadsNoiseLogs("responseBody of beneficiary:${response.body}");

        if (response.statusCode == 200) {
        } else {
          debugPrint('Failed to send notification: ${response.body}');
        }
      }
    } catch (e) {
      loaderController.aadsNoiseLogs("error on notification:${e.toString()}");

      debugPrint('Error sending notification: $e');
    }
  } // Send notification via FCM

  Future sendNotificationFall(
    String title,
    String body,
    String to,
    Map<String, dynamic> data,
    String para,
    bool isCaretaker,
  ) async {
    log(para);

    loaderController.aadsleepLogs("onSend notification Fuction");

    try {
      final token = await getToken();
      final url = Uri.parse('https://sendnotification-regbxotyqa-uc.a.run.app');
      loaderController
          .aadsleepLogs("url:https://sendnotification-regbxotyqa-uc.a.run.app");
      var jsonEncode2 = jsonEncode({
        'notification': {'title': title, 'body': body},
        'token': isCaretaker ? to : token,
        'data': data, // Include payload here
      });

      loaderController.aadsleepLogs("token:$token");
      loaderController.aadsleepLogs("token:${token == to}");
      var headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };
      loaderController.aadsleepLogs("body:$jsonEncode2");
      log("body:$jsonEncode2");
      loaderController.aadsleepLogs("headers:$headers");

      if (isCaretaker) {
        {
          final response = await http.post(
            url,
            headers: headers,
            body: jsonEncode2,
          );

          loaderController.aadsleepLogs(
              "responseStatusCode of caretaker:${response.statusCode}");
          loaderController
              .aadsleepLogs("responseBody of caretaker:${response.body}");

          if (response.statusCode == 200) {
          } else {
            debugPrint('Failed to send notification: ${response.body}');
          }
        }
      } else {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode2,
        );

        loaderController.aadsleepLogs(
            "responseStatusCode of beneficiary:${response.statusCode}");
        loaderController
            .aadsleepLogs("responseBody of beneficiary:${response.body}");
        log("responseStatusCode of beneficiary:${response.statusCode}");
        log("responseBody of beneficiary:${response.body}");
        if (response.statusCode == 200) {
          log("message${response.body}");
        } else {
          debugPrint('Failed to send notification: ${response.body}');
        }
      }
    } catch (e) {
      loaderController.aadsleepLogs("error on notification:${e.toString()}");

      debugPrint('Error sending notification: $e');
    }
  }

  Future sendNotificationSleep(
    String title,
    String body,
    String to,
    Map<String, dynamic> data,
    String para,
    bool isCaretaker,
  ) async {
    log(para);

    loaderController.aadsleepLogs("onSend notification Fuction");

    try {
      final token = await getToken();
      final url = Uri.parse('https://sendnotification-regbxotyqa-uc.a.run.app');
      loaderController
          .aadsleepLogs("url:https://sendnotification-regbxotyqa-uc.a.run.app");
      var jsonEncode2 = jsonEncode({
        'notification': {'title': title, 'body': body},
        'token': isCaretaker ? to : token,
        'data': data, // Include payload here
      });

      loaderController.aadsleepLogs("token:$token");
      loaderController.aadsleepLogs("token:${token == to}");
      var headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$_serverKey',
      };
      loaderController.aadsleepLogs("body:$jsonEncode2");
      log("body:$jsonEncode2");
      loaderController.aadsleepLogs("headers:$headers");

      if (isCaretaker) {
        Canalert canalert = Canalert();
        bool alertCan = await canalert.retrieveFromSharedPreferences();
        log("booollllll$alertCan");
        if (alertCan == false) {
          final response = await http.post(
            url,
            headers: headers,
            body: jsonEncode2,
          );
          log('Failed to send notification: ${response.body}');
          loaderController.aadsleepLogs(
              "responseStatusCode of caretaker:${response.statusCode}");
          loaderController
              .aadsleepLogs("responseBody of caretaker:${response.body}");

          if (response.statusCode == 200) {
          } else {
            debugPrint('Failed to send notification: ${response.body}');
          }
        }
      } else {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode2,
        );

        loaderController.aadsleepLogs(
            "responseStatusCode of beneficiary:${response.statusCode}");
        loaderController
            .aadsleepLogs("responseBody of beneficiary:${response.body}");
        log("responseStatusCode of beneficiary:${response.statusCode}");
        log("responseBody of beneficiary:${response.body}");
        if (response.statusCode == 200) {
          log("message${response.body}");
        } else {
          debugPrint('Failed to send notification: ${response.body}');
        }
      }
    } catch (e) {
      loaderController.aadsleepLogs("error on notification:${e.toString()}");

      debugPrint('Error sending notification: $e');
    }
  }
}

// Function to handle incoming messages
Future handleMessages(RemoteMessage? remoteMessage) async {
  debugPrint(remoteMessage.toString());
  if (remoteMessage == null) return;
  log(remoteMessage.notification!.title!);

  Get.toNamed(AlertScreen.route, arguments: remoteMessage);
}

bool isReponded = false;
