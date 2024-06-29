// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:developer';

import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/services/noise_alert.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

/// A service class for monitoring noise levels and sending notifications
/// based on certain thresholds.
class NoiseService {
  // StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  Timer? timer;
  LoaderController loaderController = Get.find();

  /// Callback function called when noise data is received.
  ///
  /// Sends notifications if noise levels exceed certain thresholds.
  void onData(NoiseReading noiseReading, BenefiiciaryModel benefiiciaryModel,
      String para) {
    int noiseCount = int.parse(benefiiciaryModel.noiseDecibel ?? "100");

    // Check if noise levels exceed thresholds.
    // log("${noiseReading.meanDecibel}");
    if (noiseReading.maxDecibel > noiseCount &&
        noiseReading.meanDecibel > noiseCount) {
      log("message");
      loaderController
          .aadsNoiseLogs("${noiseReading.maxDecibel} == $noiseCount");
      // debugPrint(noiseCount.toString());
      // if (iscanalert == true) {
      //   // canalert.updateAlert(false);
      // }
      // // Send notification to beneficiary.
      if (loaderController.notificationSender.value == false) {
        loaderController.updateNotificationSender(true);
        NoiseAlert noiseAlert = NoiseAlert();
        noiseAlert.updateAlert(false);
        Future.delayed(
          const Duration(minutes: 2),
          () {
            loaderController.updateNotificationSender(false);
          },
        );
        NotificationServices().sendNotificationNoise(
          "Are you ok?",
          "We detected a higher noise",
          benefiiciaryModel.benToken,
          {
            "IscareTaker": "no",
            "careToken": benefiiciaryModel.careToken,
            "name": benefiiciaryModel.name,
            "emergency": benefiiciaryModel.emergencynumbers.toString()
          },
          para,
          false,
        );

        // Start timer for secondary notification.

        timer = Timer.periodic(const Duration(seconds: 1), (tier) async {
          if ((tier.tick == 60)) {
            bool isanalert = noiseAlert.retrieveFromGetStorage();
            loaderController.aadsNoiseLogs("$isanalert");
            print("object is true");
            log("leodas$isanalert");
            if (isanalert == false) {
              loaderController.aadsNoiseLogs("CareTaker is going");
              print("sended");
              // Send secondary notification to caretaker.
              NotificationServices().sendNotificationNoise(
                "app detected higher noise from ${benefiiciaryModel.name} phone",
                "please check",
                benefiiciaryModel.careToken,
                {
                  "isCareTaker": "yes",
                  "careToken": benefiiciaryModel.careToken,
                  "name": benefiiciaryModel.name,
                  "emergency": benefiiciaryModel.emergencynumbers.toString()
                },
                para,
                true,
              );
              timer?.cancel();
            }
          }
        });
      }
    }
  }

  /// Error handler for noise meter.
  void onError(Object error) {
    debugPrint(error.toString());
    // stop();
  }

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Start noise sampling.
  ///
  /// Parameters:
  /// - [benefiiciaryModel]: The beneficiary model object.
  /// - [para]: Additional parameters for notification.
  Future<void> start(BenefiiciaryModel benefiiciaryModel, String para) async {
    // Create a noise meter instance.
    noiseMeter ??= NoiseMeter();

    // Check permission to use the microphone.
    if (!(await checkPermission())) await requestPermission();

    // Listen to the noise stream.
    noiseMeter?.noise.listen((noiseReading) {
      // print(noiseReading);
      onData(noiseReading, benefiiciaryModel, para);
    }, onError: onError);
  }

  /// Stop noise sampling.
  // void stop() {
  //   _noiseSubscription?.cancel();
  // }
}
