import 'dart:ui';

import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get_storage/get_storage.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
      ));
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

        print('object');
      });

      print("object");
    } else {
      print('objecjdfbuufht');
    }
  }
}
