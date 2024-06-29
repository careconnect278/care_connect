import 'package:alarm/alarm.dart';
import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/implementation/text_field_controller.dart';
import 'package:care_connect/controller/services/background_service.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/firebase_options.dart';
import 'package:care_connect/view/add_member_screen.dart';
import 'package:care_connect/view/alert_screen.dart';
import 'package:care_connect/view/beneficiary_home_screen.dart';
import 'package:care_connect/view/medical_screen.dart';
import 'package:care_connect/view/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
