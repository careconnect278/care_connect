
import 'dart:convert';
import 'dart:developer';

import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/controller/services/can_alert.dart';
import 'package:care_connect/controller/services/fall_alert.dart';
import 'package:care_connect/controller/services/noise_alert.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/controller/services/show_aleergies.dart';
import 'package:care_connect/view/add_member_screen.dart';
import 'package:care_connect/view/beneficiary_home_screen.dart';
import 'package:care_connect/view/medical_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';

class AlertScreen extends StatelessWidget {
  AlertScreen({super.key});
  static const route = "/alert-screen";
  final RemoteMessage? message = Get.arguments;

  final managementOnCareTaker = Get.put(MemberManagementOnCareTaker());

  @override
  Widget build(BuildContext context) {
    // log(message!.data.toString());
    bool isCaretaker = message!.data["isCareTaker"].toString().contains("yes");
    return PopScope(
      canPop: false,
      onPopInvoked: (a) {
        if (isCaretaker) {
          Get.to(() => AddMemberScreen());
        }
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 4.h,
            ),
            Text(
              'Welcome',
              style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 4.h,
            ),
            Icon(
              Icons.report_problem,
              size: 22.w,
              color: Colors.black,
            ),
            Text(
              message!.notification!.title!,
              style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
            ),
            Text(
              message!.notification!.body!,
              style: TextStyle(fontSize: 15.dp, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 7.h,
            ),
            if (!isCaretaker) ...{
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(
                        30.w,
                        10.h,
                      ),
                    ),
                    onPressed: () {
                      if (message!.notification!.body!
                          .toLowerCase()
                          .contains("noise")) {
                        log("noise");

                        NoiseAlert noiseAlert = NoiseAlert();
                        noiseAlert.updateAlert(true);
                      } else if (message!.notification!.body!
                          .toLowerCase()
                          .contains("fall")) {
                        FallAlert fallAlert = FallAlert();
                        fallAlert.updateAlert(true);
                      } else {
                        log(DateTime.now().toString());
                        Canalert canalert = Canalert();
                        canalert.updateAlert(true);
                       
                      }
                      isReponded = false;
                      Get.to(() => BeneficiaryHomeScreen());
                    },
                    child: Text(
                      'YES',
                      style: TextStyle(
                          fontSize: 20.dp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(
                        30.w,
                        10.h,
                      ),
                    ),
                    onPressed: () async {
                      if (message!.notification!.body!
                          .toLowerCase()
                          .contains("noise")) {
                        log("noise");

                        NoiseAlert noiseAlert = NoiseAlert();
                        noiseAlert.updateAlert(true);
                      } else if (message!.notification!.body!
                          .toLowerCase()
                          .contains("fall")) {
                        FallAlert fallAlert = FallAlert();
                        fallAlert.updateAlert(true);
                      } else {
                        Canalert canalert = Canalert();
                        canalert.updateAlert(true);
                      }
                      String token = message!.data["careToken"];
                      String name = message!.data["name"];
                      List emergency = jsonDecode(message!.data["emergency"]);
                      List<String> emergencyNum =
                          emergency.map((e) => e.toString()).toList();
                      // final tokena = await NotificationServices().getToken();

                      // print(token == tokena);
                      // print(emergencyNum.runtimeType);
                      NotificationServices().sendNotificationNoise(
                        "$name is Not okay",
                        "please check",
                        token,
                        {
                          "isCareTaker": "yes",
                          "careToken": token,
                          "name": name,
                          "emergency": emergencyNum.toString()
                        },
                        "",
                        true,
                      );
                      ShowAllergies showAllergies = ShowAllergies();
                      showAllergies.updateInGetStorage(true);
                      Get.to(() => MedicalScreen());
                    },
                    child: Text(
                      'NO',
                      style: TextStyle(
                          fontSize: 20.dp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
            } else ...{
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SlideAction(
                  text: "Send messages \nTo Emergency",
                  onSubmit: () async {
                    String name = message!.data["name"];
                    List emergency = jsonDecode(message!.data["emergency"]);
                    List<String> emergencyNum =
                        emergency.map((e) => e.toString()).toList();

                    sendSS("Something wrong for $name,pls check", emergencyNum);

                    // print(message!.data["isCareTaker"]);
                  },
                  textStyle: TextStyle(
                      fontSize: 15.dp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )
            },
            SizedBox(
              height: 4.h,
            ),
          ],
        ),
      ),
    );
  }
}
