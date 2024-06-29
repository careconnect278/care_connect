import 'dart:async';
import 'dart:developer';
import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// Create notification channel
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "high_importance_channel", // id
  'MY FOREGROUND SERVICE', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);
// Initialize the plugin
void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@drawable/ic_launcher'); // Replace with your app icon
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

void showNotification(String title, String body) async {
  flutterLocalNotificationsPlugin.show(
    1234,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: "@drawable/ic_launcher",
        playSound: true,
      ),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();

    // Create a notification for the foreground service
    service.setForegroundNotificationInfo(
      title: "Foreground Service",
      content: "The service is running in the foreground",
    );

    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
    Get.put(LoaderController());
    // Example of subscribing to screen state changes
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await GetStorage.init();

    // Start listening for screen events in the background
    ScreenTimerServices screenTimerServices = ScreenTimerServices();
    await screenTimerServices.startListening("background");

    print('Background service started');
  }
}

@pragma('vm:entry-point')
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  //  initializeNotifications(); // Initialize notifications

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStartOnBoot: true,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      autoStart: true,
    ),
  );

  await service.startService();
}

@pragma('vm:entry-point')
restartService() async {
  final service = FlutterBackgroundService();
  var isRunning = await service.isRunning();
  if (isRunning) {
    service.invoke("stopService");
    Future.delayed(
      const Duration(seconds: 1),
      () {
        log("message");
        initializeService();
      },
    );
  } else {
        log("message1");
    initializeService();
    // service.startService();
  }
}
