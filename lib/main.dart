import 'package:care_connect/controller/implementation/text_field_controller.dart';
import 'package:care_connect/controller/services/background_services.dart';
import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/firebase_options.dart';
import 'package:care_connect/view/activity_details.dart';
import 'package:care_connect/view/add_member_screen.dart';
import 'package:care_connect/view/alert_screen.dart';
import 'package:care_connect/view/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controller/implementation/member_mangement_caretaker_phone.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await initializeService();
  NotificationServices().initNotifications();
  Get.put(TextFieldController());

  final managementOnCareTaker = Get.put(MemberManagementOnCareTaker());
  runApp(MyApp(
    managementOnCareTaker: managementOnCareTaker,
  ));
}

class MyApp extends StatelessWidget {
  final MemberManagementOnCareTaker managementOnCareTaker;
  const MyApp({
    super.key,
    required this.managementOnCareTaker,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          routes: {AlertScreen.route: (context) => AlertScreen()},
          debugShowCheckedModeBanner: false,
          home: Obx(() => managementOnCareTaker.loginState.value ==
                  LoginState.beneficiary
              ? ActivityDetailsScreen()
              : managementOnCareTaker.loginState.value == LoginState.caretaker
                  ? AddMemberScreen()
                  : WelcomeScreen()),
        );
      },
    );
  }
}
