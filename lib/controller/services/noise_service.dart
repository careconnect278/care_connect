import 'dart:async';

import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

class NoiseService {
  StreamSubscription<NoiseReading>? _noiseSubscription;
  NoiseMeter? noiseMeter;
  void onData(NoiseReading noiseReading, BenefiiciaryModel benefiiciaryModel) {
    if (noiseReading.maxDecibel > 86 && noiseReading.meanDecibel > 86) {
      NotificationServices().sendNotification(
          "somethingWentwrong",
          "please check",
          benefiiciaryModel.benToken,
          {"user": benefiiciaryModel.name});
    }
  }

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
  Future<void> start(BenefiiciaryModel benefiiciaryModel) async {
    // Create a noise meter instanse.
    noiseMeter ??= NoiseMeter();

    // Check permission to use the microphone.
    //
    // Remember to update the AndroidManifest file (Android) and the
    // Info.plist and pod files (iOS).
    if (!(await checkPermission())) await requestPermission();

    // Listen to the noise stream.
    _noiseSubscription = noiseMeter?.noise.listen((noiseReading) {
      onData(noiseReading, benefiiciaryModel);
    }, onError: onError);
  }

  /// Stop sampling.
  void stop() {
    _noiseSubscription?.cancel();
  }
}
