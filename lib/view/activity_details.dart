import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/view/member_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';

class ActivityDetailsScreen extends StatelessWidget {
  ActivityDetailsScreen({super.key});
  final MemberManagementOnCareTaker managementOnCareTaker = Get.find();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final a = await NotificationServices().getToken();
        print(BeneficiaryLocalService().box.hasData("beneficiary"));
      },
      child: Scaffold(
        appBar: CustomAppbar(),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 4.h,
                ),
                Text(
                  'Activity Details',
                  style:
                      TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 15.w,
                      color: Colors.black,
                    ),
                    Text(
                      '${managementOnCareTaker.inactivitydetails.value.lastInactivityHours}\nof Inactivity',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20.dp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.phone_iphone_rounded,
                      size: 15.w,
                      color: Colors.black,
                    ),
                    Text(
                      'Last opened at\n${managementOnCareTaker.inactivitydetails.value.lastUnlockedTime}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20.dp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.phone_iphone_rounded,
                      size: 15.w,
                      color: Colors.black,
                    ),
                    Text(
                      'Last locked at\n${managementOnCareTaker.inactivitydetails.value.lastLockedTime}',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontSize: 20.dp, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
