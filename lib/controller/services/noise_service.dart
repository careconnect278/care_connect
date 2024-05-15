// ignore_for_file: avoid_print

import 'dart:async';

import 'package:care_connect/controller/services/can_alert.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

/// A service class for monitoring noise levels and sending notifications
/// based on certain thresholds.
class NoiseService {
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  Timer? timer;

  /// Callback function called when noise data is received.
  ///
  /// Sends notifications if noise levels exceed certain thresholds.
  void onData(NoiseReading noiseReading, BenefiiciaryModel benefiiciaryModel,
      String para) {Canalert canalert
    =Canalert();
  
        int noiseCount=int.parse(benefiiciaryModel.noiseDecibel??"100");
        bool iscanalert=canalert.retrieveFromGetStorage();
    // Check if noise levels exceed thresholds.
  debugPrint(noiseReading.maxDecibel.toString());
    if (noiseReading.maxDecibel > noiseCount&& noiseReading.meanDecibel > noiseCount) {
      debugPrint(noiseCount.toString());  
      if (iscanalert==true) {
        // canalert.updateAlert(false);
      }
      // Send notification to beneficiary.
      NotificationServices().sendNotification(
          "Are you ok?",
          "We detected a higher noise",
          benefiiciaryModel.benToken,
          {
            "IscareTaker": "no",
            "careToken": benefiiciaryModel.careToken,
            "name": benefiiciaryModel.name,
            "emergency": benefiiciaryModel.emergencynumbers
          },
          para,
          false);
            debugPrint("leodas$iscanalert");
      // Start timer for secondary notification.
      timer = Timer.periodic(const Duration(seconds: 1), (tier) async {
        if ((tier.tick == 60)) {
          debugPrint("leodas$iscanalert");
          if (iscanalert==false) {
            print("sended");
            // Send secondary notification to caretaker.
            NotificationServices().sendNotification(
                "app detected higher noise from ${benefiiciaryModel.name} phone",
                "please check",
                benefiiciaryModel.careToken,
                {
                  "isCareTaker": "yes",
                  "careToken": benefiiciaryModel.careToken,
                  "name": benefiiciaryModel.name,
                  "emergency": benefiiciaryModel.emergencynumbers
                },
                para,
                true);
            timer?.cancel();
          }
        }
      });
    }
  }

  /// Error handler for noise meter.
  void onError(Object error) {
    debugPrint(error.toString());
    stop();
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
    _noiseSubscription = noiseMeter?.noise.listen((noiseReading) {
      onData(noiseReading, benefiiciaryModel, para);
    }, onError: onError);
  }

  /// Stop noise sampling.
  void stop() {
    _noiseSubscription?.cancel();
  }
}
