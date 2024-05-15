
import 'package:alarm/alarm.dart';
import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/implementation/text_field_controller.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/firebase_options.dart';
import 'package:care_connect/view/add_member_screen.dart';
import 'package:care_connect/view/alert_screen.dart';
import 'package:care_connect/view/beneficiary_home_screen.dart';
import 'package:care_connect/view/medical_screen.dart';
import 'package:care_connect/view/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'controller/implementation/member_mangement_caretaker_phone.dart';
import 'controller/services/alarm_service.dart';

// GlobalKey to access the NavigatorState anywhere in the app
final navigatorKey = GlobalKey<NavigatorState>();

// Entry point of the application
void main() async {
  // Ensure that widgets binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Request necessary permissions for the app
  await [
    Permission.phone,
    Permission.sms,
    Permission.notification,
    Permission.microphone
  ].request();

  // Initialize Firebase with default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize GetStorage for local storage
  await GetStorage.init();

  try {
    await Alarm.init();
  } catch (e) {
    GetSnackBar(
      duration: Duration(seconds: 5),
      title: "alarm Errorr ",
      message: e.toString(),
    );
  }

  // Initialize the background service
  await initializeService();

  // Initialize notifications service
  NotificationServices().initNotifications();

  // Initialize TextFieldController for text field management
  Get.put(TextFieldController());

  // Initialize LoaderController for loader management
  final loader = Get.put(LoaderController());

  // Initialize MemberManagementOnCareTaker controller for managing members
  final managementOnCareTaker = Get.put(MemberManagementOnCareTaker());
  checkAndroidScheduleExactAlarmPermission();
  // Run the application
  runApp(MyApp(
    loaderController: loader,
    managementOnCareTaker: managementOnCareTaker,
  ));
}

// MyApp class, the root of the application
class MyApp extends StatelessWidget {
  final LoaderController loaderController;
  final MemberManagementOnCareTaker managementOnCareTaker;

  // Constructor for MyApp
  const MyApp({
    super.key,
    required this.managementOnCareTaker,
    required this.loaderController,
  });

  @override
  Widget build(BuildContext context) {
    // Use FlutterSizer for responsive UI design
    return FlutterSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          // Define routes for the app
          routes: {AlertScreen.route: (context) => AlertScreen()},
          debugShowCheckedModeBanner: false,
          home: Obx(
            () => managementOnCareTaker.loginState.value ==
                    LoginState.beneficiary
                ? loaderController.isShowAllergy.value == true
                    ? MedicalScreen()
                    : BeneficiaryHomeScreen()
                : managementOnCareTaker.loginState.value == LoginState.caretaker
                    ? AddMemberScreen()
                    : const WelcomeScreen(),
          ),
        );
      },
    );
  }
}

// Function to initialize the background service
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Configure background service for Android
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
    ),
  );

  // Start the background service
  service.startService();
}

// Entry point for the background service
@pragma('vm-entry-point')
Future onStart(ServiceInstance service) async {
  // Ensure that Dart plugin is initialized
  // DartPluginRegistrant.ensureInitialized();

  // If the service is an instance of AndroidServiceInstance
  if (service is AndroidServiceInstance) {
    // Listen for events to set the service as foreground or background
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Listen for event to stop the service
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // If the service is an instance of AndroidServiceInstance
  if (service is AndroidServiceInstance) {
    // Check if the service is running in foreground
    if (await service.isForegroundService()) {
      // Initialize Firebase and GetStorage
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      await GetStorage.init();

      // Start listening for screen events in the background
      ScreenTimerServices screenTimerServices = ScreenTimerServices();
      await screenTimerServices.startListening("background");

      debugPrint('Background service started');
    } else {
      debugPrint('Background service not in foreground');
    }
  }
}
