import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
// import 'package:care_connect/controller/services/can_alert.dart';
import 'package:care_connect/controller/services/show_aleergies.dart';
// import 'package:care_connect/view/logs_list.dart';
 import 'package:care_connect/view/logs_list.dart';
import 'package:care_connect/view/medical_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:slide_to_act/slide_to_act.dart';

class BeneficiaryHomeScreen extends StatelessWidget {
  BeneficiaryHomeScreen({super.key});

  final MemberManagementOnCareTaker managementOnCareTaker = Get.find();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.dp),
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 4.h,
                    ),
                    Text(
                      'Welcome ${managementOnCareTaker.beneficiary.value == null ? "" : managementOnCareTaker.beneficiary.value!.name}',
                      style: TextStyle(
                          fontSize: 20.dp, fontWeight: FontWeight.bold),
                    ),
                    if (managementOnCareTaker.beneficiary.value != null) ...{
                      SlideAction(
                        text: "call care taker",
                        onSubmit: () async {
                          callNumber(managementOnCareTaker
                              .caretaker.value!.phoneNumber);
                          ShowAllergies showAllergies = ShowAllergies();
                          showAllergies.updateInGetStorage(true);
                          Get.to(() => MedicalScreen());
                        },
                        textStyle: TextStyle(
                            fontSize: 20.dp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: managementOnCareTaker
                            .beneficiary.value!.emergencynumbers.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              'emergency ${index + 1}',
                              style: TextStyle(
                                  fontSize: 15.dp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            subtitle: Text(
                              managementOnCareTaker
                                  .beneficiary.value!.emergencynumbers[index],
                              style: TextStyle(
                                  fontSize: 15.dp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  GestureDetector(
                                      onTap: () {
                                        callNumber(managementOnCareTaker
                                            .beneficiary
                                            .value!
                                            .emergencynumbers[index]);
                                      },
                                      child: const Icon(Icons.call)),
                                  SizedBox(
                                    width: 10.dp,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        sendSS(
                                            "message From ${managementOnCareTaker.beneficiary.value!.name}",
                                            [
                                              managementOnCareTaker
                                                  .beneficiary
                                                  .value!
                                                  .emergencynumbers[index]
                                            ]);
                                      },
                                      child: const Icon(Icons.message))
                                ]),
                          );
                        },
                      )
                    },
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.to(() => LogsList(
                                    isNoise: true,
                                  ));
                            },
                            child: Icon(
                              Icons.noise_aware,
                              size: 20.w,
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.to(() => LogsList(
                                    isNoise: false,
                                  ));
                            },
                            child: Icon(
                              Icons.timer_3_select_sharp,
                              size: 20.w,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void sendSS(String message, List<String> recipents) async {
  String result =
      await sendSMS(message: message, recipients: recipents, sendDirect: true)
          .catchError((onError) {
    debugPrint(onError.toString());
    return onError.toString();
  });
  debugPrint(result);
}

callNumber(String number) async {
  //set the number here
  bool? res = await FlutterPhoneDirectCaller.callNumber(number);
  debugPrint(res.toString());
}
