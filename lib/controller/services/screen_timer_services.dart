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
import 'package:screen_state/screen_state.dart';

// Global variable to keep track of whether an alert can be sent or not

// Class responsible for managing screen timer services
class ScreenTimerServices {
  Timer? timer; // Timer instance
  int seconds = 0; // Number of seconds elapsed
  BeneficiaryLocalService beneficiaryLocalService = BeneficiaryLocalService();
  BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();
  // String formattedTime = "00:00:00"; // Formatted time string
  final Screen _screen = Screen(); // Screen state instance
  StreamSubscription<ScreenStateEvent>?
      subscription; // Subscription to screen state events

  LoaderController loaderController = Get.find();
  // Method to start the timer for a beneficiary
  void startTimer(BenefiiciaryModel benefiiciaryModel, String para) {
    loaderController.aadsleepLogs("OnStartTimer");

    Canalert canalert = Canalert();

    seconds = 0; // Reset seconds
    // Convert the alert time to seconds
    int conditionSeconds = timeStringToSeconds(benefiiciaryModel.timeToAlert);

    loaderController.aadsleepLogs("conditionSeconds $conditionSeconds");
    // Debug print the condition seconds (optional)
    debugPrint(conditionSeconds.toString());

    DateTime now = DateTime.now();
    TimeOfDay fromTime = parseTimeOfDay(benefiiciaryModel.fromSleep);
    TimeOfDay toTime = parseTimeOfDay(benefiiciaryModel.toSleep);
    // Define the start and end of the restricted time period
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

      if (DateTime.now().isBefore(startRestriction) ||
          DateTime.now().isAfter(endRestriction)) {
        log("Function executed");
        if (tier.tick == conditionSeconds) {
          log('Condition true from ${tier.tick} == $conditionSeconds');
          bool iscanalert = canalert.retrieveFromGetStorage();

          loaderController.aadsleepLogs(
              "Condition true from ${tier.tick} == $conditionSeconds");
          if (iscanalert) {
            // canalert.updateAlert(false); // Uncomment if needed
          }
          loaderController.aadsleepLogs("iscanalert is $iscanalert");

          // Send notification to the beneficiary
          NotificationServices().sendNotificationSleep(
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
              false);

          Future.delayed(
            const Duration(seconds: 60),
            () {
              bool alertCan = canalert.retrieveFromGetStorage();
              loaderController.aadsleepLogs("alertCan is $alertCan");
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
        }
      } else {
        if (timer != null) {
          timer!.cancel();
          timer = null;
          loaderController
              .aadsleepLogs("Function not working because restriction");
          log("timer cancelling");
        } else {
          log("timer null");
        }
        tier.cancel();
        startTimer(benefiiciaryModel, para);
      }
    });
  }

  // Method to start listening to screen events
  Future startListening(String para) async {
    // Canalert canalert = Canalert();

    try {
      // Check if beneficiary data is available
      if (beneficiaryLocalService.box.hasData("beneficiary")) {
        debugPrint("nujmbjnj");
        // Retrieve beneficiary data from local storage
        BenefiiciaryModel benefiiciaryModel =
            beneficiaryLocalService.retrieveFromGetStorage();
        benefiiciaryModel = await beneficiaryDatabaseService
            .getBenDetails(benefiiciaryModel.memberUid);
        beneficiaryLocalService
            .saveToGetStorage(benefiiciaryModel.toJson(true, false));
        // Start noise service for detecting beneficiary activity

        // Subscribe to screen state events
        subscription = _screen.screenStateStream!.listen((event) {
          onData(event, benefiiciaryModel, para);
          // DateTime now = DateTime.now();
          // TimeOfDay fromTime = parseTimeOfDay(benefiiciaryModel.fromSleep);
          // TimeOfDay toTime = parseTimeOfDay(benefiiciaryModel.toSleep);
          // // Define the start and end of the restricted time period
          // DateTime startRestriction = DateTime(now.year, now.month, now.day,
          //     fromTime.hour, fromTime.minute); // 8:50 PM
          // DateTime endRestriction = DateTime(now.year, now.month, now.day,
          //     toTime.hour, toTime.minute); // 9:50 PM
          // log(startRestriction.toString());
          // log(endRestriction.toString());
          // // Check if the current time is outside the restricted period
          // if (now.isBefore(startRestriction) || now.isAfter(endRestriction)) {
          //   // Execute the function
          //   // Your function implementation here
          //   onData(event, benefiiciaryModel, para);
          //   log('Function executed');
          // } else {
          //   // Do not execute the function
          //   log('Function not executed due to restricted time period');
          // }
        });
        // Set iscanalert to true, indicating that alerts can't be sent
        // canalert.updateAlert(true);
      } else {
        // Debug print if beneficiary data is not available
        debugPrint(
            beneficiaryLocalService.box.hasData("beneficiary").toString());
      }
    } on ScreenStateException catch (exception) {
      // Handle ScreenStateException if any
      debugPrint(exception.toString());
    }
  }

  // Method to handle screen state events
  void onData(ScreenStateEvent event, BenefiiciaryModel benefiiciaryModel,
      String para) {
    debugPrint("ondata");
    DateTime now = DateTime.now();
    TimeOfDay fromTime = parseTimeOfDay(benefiiciaryModel.fromSleep);
    TimeOfDay toTime = parseTimeOfDay(benefiiciaryModel.toSleep);
    // Define the start and end of the restricted time period
    DateTime startRestriction =
        DateTime(now.year, now.month, now.day, fromTime.hour, fromTime.minute);
    DateTime endRestriction =
        DateTime(now.year, now.month, now.day, toTime.hour, toTime.minute);
    // If the screen is turned off
    if (event == ScreenStateEvent.SCREEN_OFF) {
      debugPrint('object');
      // Update beneficiary inactivity details in the database
      if (DateTime.now().isBefore(startRestriction) ||
          DateTime.now().isAfter(endRestriction)) {
        beneficiaryDatabaseService.inactivityDetailsUpdate(
            benefiiciaryModel.memberUid,
            {"lastlockedtime": DateTime.now().toString()});
      }
      // Start the timer for the beneficiary
      startTimer(benefiiciaryModel, para);
    }
    // If the screen is unlocked
    else if (event == ScreenStateEvent.SCREEN_UNLOCKED) {
      try {
        // Cancel the timer if it's running
        if (timer != null) {
          timer!.cancel();
          timer = null;
          loaderController
              .aadsleepLogs("timer cancelling cause of screen unloacked");
          log("timer cancelling");
        } else {
          log("timer null");
        }
      } catch (e) {
        // Handle any exceptions if occurred
        debugPrint(e.toString());
      }
      debugPrint(timer!.tick.toString());
      debugPrint('unloacked');
      // Update beneficiary inactivity details in the database
      if (DateTime.now().isBefore(startRestriction) ||
          DateTime.now().isAfter(endRestriction)) {
        beneficiaryDatabaseService
            .inactivityDetailsUpdate(benefiiciaryModel.memberUid, {
          "lastunlockedtime": DateTime.now().toString(),
          "lastInactivityhours": timer == null ? 0 : timer!.tick
        });
      }
    }
  }

  stopListening() {
    subscription == null ? () {} : subscription!.cancel();
    timer == null ? () {} : timer!.cancel();
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
