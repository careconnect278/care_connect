import 'dart:async';
import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/controller/services/noise_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screen_state/screen_state.dart';

// Global variable to keep track of whether an alert can be sent or not
bool iscanalert = false;

// Class responsible for managing screen timer services
class ScreenTimerServices {
  Timer? timer; // Timer instance
  int seconds = 0; // Number of seconds elapsed
  BeneficiaryLocalService beneficiaryLocalService = BeneficiaryLocalService();
  BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();
  String formattedTime = "00:00:00"; // Formatted time string
  final Screen _screen = Screen(); // Screen state instance
  StreamSubscription<ScreenStateEvent>?
      subscription; // Subscription to screen state events

  // Method to start the timer for a beneficiary
  void startTimer(BenefiiciaryModel benefiiciaryModel, String para) {
    seconds = 0; // Reset seconds
    formattedTime = "00:00:00"; // Reset formatted time string
    // Convert the alert time to seconds
    int conditionSeconds = timeStringToSeconds(benefiiciaryModel.timeToAlert);
    // Debug print the condition seconds (optional)
    debugPrint(conditionSeconds.toString());
    // Start a periodic timer with a duration of 1 second
    timer = Timer.periodic(const Duration(seconds: 1), (tier) async {
      seconds++; // Increment seconds
      // Format the elapsed time into HH:mm:ss format
      formattedTime = DateFormat('HH:mm:ss')
          .format(DateTime(0).add(Duration(seconds: seconds)));
      // If the elapsed time matches the condition time for sending an alert
      if ((tier.tick == conditionSeconds)) {
        if (iscanalert) {
          iscanalert = false;
        }
        // Send a notification to the beneficiary
        NotificationServices().sendNotification(
            "Are you ok ${benefiiciaryModel.name}",
            "you are inactive for some time",
            benefiiciaryModel.benToken,
            {
              "isCareTaker": "no",
              "careToken": benefiiciaryModel.careToken,
              "name": benefiiciaryModel.name,
              "emergency": benefiiciaryModel.emergencynumbers
            },
            para,
            false);
      }
      // If the elapsed time matches the condition time plus an extra minute
      if (tier.tick == (conditionSeconds + 60)) {
        if (!iscanalert) {
          // Send a notification to the caregiver
          NotificationServices().sendNotification(
              "${benefiiciaryModel.name} is inactive",
              "please check",
              benefiiciaryModel.careToken,
              {
                "isCareTaker": "yes",
                "careToken": benefiiciaryModel.careToken,
                "name": benefiiciaryModel.name,
                "emergency": benefiiciaryModel.emergencynumbers,
              },
              para,
              true);
        }
      }
    });
  }

  // Method to start listening to screen events
  void startListening(String para) async {
    try {
      // Check if beneficiary data is available
      if (beneficiaryLocalService.box.hasData("beneficiary")) {
        debugPrint("nujmbjnj");
        // Retrieve beneficiary data from local storage
        BenefiiciaryModel benefiiciaryModel =
            beneficiaryLocalService.retrieveFromGetStorage();
        // Start noise service for detecting beneficiary activity
        NoiseService noiseService = NoiseService();
        noiseService.start(benefiiciaryModel, para);
        // Subscribe to screen state events
        _screen.screenStateStream!.listen((event) {
          onData(event, benefiiciaryModel, para);
        });
        // Set iscanalert to true, indicating that alerts can be sent
        iscanalert = true;
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
    // If the screen is turned off
    if (event == ScreenStateEvent.SCREEN_OFF) {
      debugPrint('object');
      // Update beneficiary inactivity details in the database
      beneficiaryDatabaseService.inactivityDetailsUpdate(
          benefiiciaryModel.memberUid,
          {"lastlockedtime": DateTime.now().toString()});
      // Start the timer for the beneficiary
      startTimer(benefiiciaryModel, para);
    }
    // If the screen is unlocked
    else if (event == ScreenStateEvent.SCREEN_UNLOCKED) {
      try {
        // Cancel the timer if it's running
        timer == null
            ? () {
                debugPrint("nu");
              }
            : timer!.cancel();
      } catch (e) {
        // Handle any exceptions if occurred
        debugPrint(e.toString());
      }
      debugPrint(timer!.tick.toString());
      debugPrint('unloacked');
      // Update beneficiary inactivity details in the database
      beneficiaryDatabaseService
          .inactivityDetailsUpdate(benefiiciaryModel.memberUid, {
        "lastunlockedtime": DateTime.now().toString(),
        "lastInactivityhours": timer == null ? 0 : timer!.tick
      });
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
