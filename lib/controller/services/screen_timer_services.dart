import 'dart:async';
import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/firebase_options.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/screen.dart';
import 'package:firebase_core/firebase_core.dart';
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
  List<ScreenStateEventEntry> log = [];
  void startTimer(BenefiiciaryModel benefiiciaryModel) {
    seconds = 0;
    formattedTime = "00:00:00";
    int conditionSeconds = timeStringToSeconds(benefiiciaryModel.timeToAlert);
    timer = Timer.periodic(const Duration(seconds: 1), (tier) {
      seconds++;
      formattedTime = DateFormat('HH:mm:ss')
          .format(DateTime(0).add(Duration(seconds: seconds)));
      if (conditionSeconds == tier.tick) {
        print("leodas${conditionSeconds == tier.tick}");
        NotificationServices().sendNotification(
            "somethingWentwrong",
            "please check",
            benefiiciaryModel.careToken,
            {"user": benefiiciaryModel.name});
      }
    });
  }

  /// Start listening to screen events this working on background and foreground using flutter_background_service,
  void startListening() async {
    print('object');
    try {
      if (beneficiaryLocalService.box.hasData("beneficiary")) {
        print("nujmbjnj");
        BenefiiciaryModel benefiiciaryModel =
            beneficiaryLocalService.retrieveFromGetStorage();
        _screen.screenStateStream!.listen(
          (event) {
            onData(event, benefiiciaryModel);
          },
        );
        started = true;
      } else {
        print(beneficiaryLocalService.box.hasData("beneficiary"));
      }
    } on ScreenStateException catch (exception) {
      print(exception);
    }
  }

  void onData(ScreenStateEvent event, BenefiiciaryModel benefiiciaryModel) {
    if (event == ScreenStateEvent.SCREEN_OFF) {
      print('object');
      formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
      beneficiaryDatabaseService.inactivityDetailsUpdate(
          benefiiciaryModel.memberUid,
          {"lastlockedtime": DateTime.now().toString()});
      startTimer(benefiiciaryModel);
      log.add(ScreenStateEventEntry(event));
    } else if (event == ScreenStateEvent.SCREEN_UNLOCKED) {
      print(timer!.tick);
      print('unloacked');
      formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
      beneficiaryDatabaseService
          .inactivityDetailsUpdate(benefiiciaryModel.memberUid, {
        "lastunlockedtime": DateTime.now().toString(),
        "lastInactivityhours": timer == null ? 0 : timer!.tick
      });
    

      timer?.cancel();
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
