import 'dart:ui';

import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/implementation/text_field_controller.dart';
import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/firebase_options.dart';
import 'package:care_connect/view/add_member_screen.dart';
import 'package:care_connect/view/alert_screen.dart';
import 'package:care_connect/view/beneficiary_home_screen.dart';
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

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [
    Permission.phone,
    Permission.sms,
    Permission.backgroundRefresh,
    Permission.notification
  ].request();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  await initializeService();
  NotificationServices().initNotifications();
  Get.put(TextFieldController());
  Get.put(LoaderController());
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
          home: Obx(
            () => managementOnCareTaker.loginState.value == LoginState.beneficiary
                ? BeneficiaryHomeScreen()
                : managementOnCareTaker.loginState.value ==
                        LoginState.caretaker
                    ? AddMemberScreen()
                    : const WelcomeScreen(),
          ),
        );
      },
    );
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: true,
          autoStartOnBoot: true));
  service.startService();
}

@pragma('vm-entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  if (service is AndroidServiceInstance) {
    if (await service.isForegroundService()) {
      await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform)
          .whenComplete(() async {
        await GetStorage.init().whenComplete(() {
          ScreenTimerServices screenTimerServices = ScreenTimerServices();
          screenTimerServices.startListening();
        });

        debugPrint('object');
      });

      debugPrint("object");
    } else {
      debugPrint('objecjdfbuufht');
    }
  }
}
