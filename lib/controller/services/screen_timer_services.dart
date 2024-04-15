import 'dart:async';
import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/controller/services/noise_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screen_state/screen_state.dart';

class ScreenTimerServices {
  Timer? timer;
  int seconds = 0;
  BeneficiaryLocalService beneficiaryLocalService = BeneficiaryLocalService();
  BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();
  String formattedTime = "00:00:00";
  final Screen _screen = Screen();
  StreamSubscription<ScreenStateEvent>? subscription;
  bool started = false;
  void startTimer(BenefiiciaryModel benefiiciaryModel) {
    seconds = 0;
    formattedTime = "00:00:00";
    int conditionSeconds = timeStringToSeconds(benefiiciaryModel.timeToAlert);
    debugPrint(conditionSeconds.toString());
    timer = Timer.periodic(const Duration(seconds: 1), (tier) async {
      seconds++;
      formattedTime = DateFormat('HH:mm:ss')
          .format(DateTime(0).add(Duration(seconds: seconds)));
      if ((tier.tick == conditionSeconds)) {
        // debugPrint("leodas${1 == tier.tick}");
        NotificationServices().sendNotification(
            "somethingWentwrong",
            "please check",
            benefiiciaryModel.benToken,
            {"user": benefiiciaryModel.name});
      }
    });
  }

  // static const platform = MethodChannel('com.example.care_connect/screenState');

  // void startListening() async {
  //   try {
  //     await platform.invokeMethod('startListening');
  //     debugPrint('Screen listening started');
  //   } on PlatformException catch (e) {
  //     debugPrint('Failed to start listening: ${e.message}');
  //   }
  // }

  // void stopListening() async {
  //   try {
  //     await platform.invokeMethod('stopListening');
  //     debugPrint('Screen listening stopped');
  //   } on PlatformException catch (e) {
  //     debugPrint('Failed to stop listening: ${e.message}');
  //   }
  // }

  // Start listening to screen events this working on background and foreground using flutter_background_service,
  void startListening() async {
    debugPrint('objecaaaat');
    try {
      if (beneficiaryLocalService.box.hasData("beneficiary")) {
        debugPrint("nujmbjnj");
        BenefiiciaryModel benefiiciaryModel =
            beneficiaryLocalService.retrieveFromGetStorage();
        NoiseService noiseService = NoiseService();
        noiseService.start(benefiiciaryModel);
        _screen.screenStateStream!.listen((event) {
          onData(event, benefiiciaryModel);
        });
        started = true;
      } else {
        debugPrint(
            beneficiaryLocalService.box.hasData("beneficiary").toString());
      }
    } on ScreenStateException catch (exception) {
      debugPrint(exception.toString());
    }
  }

  void onData(ScreenStateEvent event, BenefiiciaryModel benefiiciaryModel) {
    debugPrint("ondata");
    if (event == ScreenStateEvent.SCREEN_OFF) {
      debugPrint('object');
      formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
      beneficiaryDatabaseService.inactivityDetailsUpdate(
          benefiiciaryModel.memberUid,
          {"lastlockedtime": DateTime.now().toString()});
      startTimer(benefiiciaryModel);
    } else if (event == ScreenStateEvent.SCREEN_UNLOCKED) {
      try {
        timer == null
            ? () {
                debugPrint("nu");
              }
            : timer!.cancel();
      } catch (e) {
        debugPrint(e.toString());
      }
      debugPrint(timer!.tick.toString());
      debugPrint('unloacked');
      formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
      beneficiaryDatabaseService
          .inactivityDetailsUpdate(benefiiciaryModel.memberUid, {
        "lastunlockedtime": DateTime.now().toString(),
        "lastInactivityhours": timer == null ? 0 : timer!.tick
      });
    }
  }
}

int timeStringToSeconds(String timeString) {
  List<String> parts = timeString.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int totalSeconds = (hours * 60 * 60) + (minutes * 60);
  return totalSeconds;
}
