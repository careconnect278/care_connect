import 'dart:async';
import 'dart:developer';
// import 'package:care_connect/controller/screen_service.dart';
import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/services/alarm_service.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/can_alert.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_detect_plugin/screen_service.dart';

// Class responsible for managing screen timer services
class ScreenTimerServices {
  Timer? timer; // Timer instance
  int seconds = 0; // Number of seconds elapsed
  BeneficiaryLocalService beneficiaryLocalService = BeneficiaryLocalService();
  BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();
  final Screen _screen = Screen(); // Screen state instance
  StreamSubscription<ScreenStateEvent>?
      subscription; // Subscription to screen state events

  LoaderController loaderController = Get.find();

  // Method to start the timer for a beneficiary
  void startTimer(BenefiiciaryModel benefiiciaryModel, String para) {
    // stopTimer(); // Ensure any existing timer is stopped before starting a new one
    loaderController.aadsleepLogs("OnStartTimer");

    Canalert canalert = Canalert();

    seconds = 0; // Reset seconds
    // Convert the alert time to seconds
    int conditionSeconds = timeStringToSeconds(benefiiciaryModel.timeToAlert);

    loaderController.aadsleepLogs("conditionSeconds $conditionSeconds");
    debugPrint(conditionSeconds.toString());

    DateTime now = DateTime.now();
    TimeOfDay fromTime = parseTimeOfDay(benefiiciaryModel.fromSleep);
    TimeOfDay toTime = parseTimeOfDay(benefiiciaryModel.toSleep);
    DateTime startRestriction =
        DateTime(now.year, now.month, now.day, fromTime.hour, fromTime.minute);
    DateTime endRestriction =
        DateTime(now.year, now.month, now.day, toTime.hour, toTime.minute);

    log(startRestriction.toString());
    log(endRestriction.toString());
    loaderController
        .aadsleepLogs("restriction from $startRestriction to $endRestriction");

    // Start a periodic timer with a duration of 1 second
    timer = Timer.periodic(const Duration(seconds: 1), (tier) async {
      seconds++; // Increment seconds
      log((DateTime.now().isBefore(startRestriction) ||
              DateTime.now().isAfter(endRestriction))
          .toString());
      if (DateTime.now().isBefore(startRestriction) ||
          DateTime.now().isAfter(endRestriction)) {
        log("Function execute $timer");
        if (tier.tick == conditionSeconds) {
          canalert.updateAlert(false);
          NotificationServices()
              .sendNotificationSleep(
                  "Are you ok ${benefiiciaryModel.name}",
                  "you are inactive for some time",
                  benefiiciaryModel.benToken,
                  {
                    "isCareTaker": "no",
                    "careToken": benefiiciaryModel.careToken,
                    "name": benefiiciaryModel.name,
                    "emergency": benefiiciaryModel.emergencynumbers.toString()
                  },
                  para,
                  false)
              .whenComplete(
            () {
              Future.delayed(
                const Duration(seconds: 60),
                () async {
                  bool alertCan =
                      await canalert.retrieveFromSharedPreferences();
                  log("alertCan is $alertCan");
                  if (!alertCan) {
                    // Send a notification to the caregiver
                    NotificationServices().sendNotificationSleep(
                        "${benefiiciaryModel.name} is inactive",
                        "please check",
                        benefiiciaryModel.careToken,
                        {
                          "isCareTaker": "yes",
                          "careToken": benefiiciaryModel.careToken,
                          "name": benefiiciaryModel.name,
                          "emergency":
                              benefiiciaryModel.emergencynumbers.toString(),
                        },
                        para,
                        true);
                  }
                },
              );
            },
          );

          // Send notification to the beneficiary
        }
      } else {
        stopTimer();
        loaderController
            .aadsleepLogs("Function not working because restriction");
        log("timer cancelling");
        startTimer(benefiiciaryModel, para);
      }
    });
  }

  // Method to start listening to screen events
  Future<void> startListening(String para) async {
    stopListening(); // Ensure any existing subscription is cancelled before starting a new one
    try {
      // Check if beneficiary data is available
      if (beneficiaryLocalService.box.hasData("beneficiary")) {
        debugPrint("Beneficiary data found");
        // Retrieve beneficiary data from local storage
        BenefiiciaryModel benefiiciaryModel =
            beneficiaryLocalService.retrieveFromGetStorage();
        benefiiciaryModel = await beneficiaryDatabaseService
            .getBenDetails(benefiiciaryModel.memberUid);
        beneficiaryLocalService
            .saveToGetStorage(benefiiciaryModel.toJson(true, false));
        // Subscribe to screen state events
        subscription = _screen.screenStateStream!.listen((event) {
          onData(event, benefiiciaryModel, para);
        });
      } else {
        debugPrint("Beneficiary data not found");
      }
    } on ScreenStateException catch (exception) {
      // Handle ScreenStateException if any
      debugPrint(exception.toString());
    }
  }

  // Method to handle screen state events
  void onData(ScreenStateEvent event, BenefiiciaryModel benefiiciaryModel,
      String para) {
    debugPrint("onData triggered");
    DateTime now = DateTime.now();
    TimeOfDay fromTime = parseTimeOfDay(benefiiciaryModel.fromSleep);
    TimeOfDay toTime = parseTimeOfDay(benefiiciaryModel.toSleep);
    DateTime startRestriction =
        DateTime(now.year, now.month, now.day, fromTime.hour, fromTime.minute);
    DateTime endRestriction =
        DateTime(now.year, now.month, now.day, toTime.hour, toTime.minute);

    if (event == ScreenStateEvent.SCREEN_OFF) {
      startTimer(benefiiciaryModel, para);
      if (DateTime.now().isBefore(startRestriction) ||
          DateTime.now().isAfter(endRestriction)) {
        beneficiaryDatabaseService.inactivityDetailsUpdate(
            benefiiciaryModel.memberUid,
            {"lastlockedtime": DateTime.now().toString()});
      }
    } else if (event == ScreenStateEvent.SCREEN_UNLOCKED) {
      if (DateTime.now().isBefore(startRestriction) ||
          DateTime.now().isAfter(endRestriction)) {
        beneficiaryDatabaseService
            .inactivityDetailsUpdate(benefiiciaryModel.memberUid, {
          "lastunlockedtime": DateTime.now().toString(),
          "lastInactivityhours": timer == null ? 0 : timer!.tick
        });
      }
      stopTimer();
      debugPrint('Unlocked');
    }
  }

  // Method to stop the timer
  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
      loaderController.aadsleepLogs("Timer stopped");
      log("Timer stopped");
    }
  }

  // Method to stop listening to screen events
  void stopListening() {
    if (subscription != null) {
      subscription!.cancel();
      subscription = null;
      loaderController.aadsleepLogs("Subscription cancelled");
      log("Subscription cancelled");
    }
  }
}

// Method to convert time string (HH:mm format) to seconds
int timeStringToSeconds(String timeString) {
  List<String> parts = timeString.split(':');
  int hours = int.parse(parts[0]);
  int minutes = int.parse(parts[1]);
  int totalSeconds = (hours * 60 * 60) + (minutes * 60);
  return totalSeconds;
}
