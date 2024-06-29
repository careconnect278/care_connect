import 'dart:async';
import 'dart:developer';

import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/services/fall_alert.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' hide log;

class FallDetection {
  static StreamSubscription<AccelerometerEvent>? accelSubscription;
  static LoaderController loaderController = Get.find();
  static FallAlert fallAlert = FallAlert();

  static startListening(BenefiiciaryModel beneficiaryModel) {
    accelSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        _detectFall(event, beneficiaryModel);
      },
      onError: (error) {
        // Handle error
        print('Error: $error');
      },
      cancelOnError: true,
    );
  }

  static void _detectFall(
      AccelerometerEvent event, BenefiiciaryModel beneficiaryModel) {
    double magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    double freeFallThreshold = 2.0;
    double impactThreshold = 33.0;

    if (magnitude < freeFallThreshold) {
      log('Free fall detected');
    } else if (magnitude > impactThreshold) {
      log('Impact detected');
      if (loaderController.notificationFallSender.value == false) {
        loaderController.updateFallSender(true);
        fallAlert.updateAlert(false);
        Future.delayed(
          const Duration(minutes: 2),
          () {
            loaderController.updateFallSender(false);
          },
        );
        NotificationServices().sendNotificationFall(
            "Are you ok ${beneficiaryModel.name}",
            "We Detected Fall From Your Phone",
            beneficiaryModel.benToken,
            {
              "isCareTaker": "no",
              "careToken": beneficiaryModel.careToken,
              "name": beneficiaryModel.name,
              "emergency": beneficiaryModel.emergencynumbers.toString()
            },
            "",
            false);

        Future.delayed(
          const Duration(seconds: 60),
          () {
            bool alertCan = fallAlert.retrieveFromGetStorage();

            if (!alertCan) {
              // Send a notification to the caregiver

              NotificationServices().sendNotificationFall(
                  "app detected fall from ${beneficiaryModel.name} phone",
                  "please check",
                  beneficiaryModel.careToken,
                  {
                    "isCareTaker": "yes",
                    "careToken": beneficiaryModel.careToken,
                    "name": beneficiaryModel.name,
                    "emergency": beneficiaryModel.emergencynumbers.toString(),
                  },
                  "",
                  true);
            }
          },
        );
      }
    }
  }

  static void dispose() {
    accelSubscription?.cancel();
  }
}
