import 'package:care_connect/view/add_member_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';

class AlertScreen extends StatelessWidget {
  AlertScreen({super.key});
  static const route = "/alert-screen";
  final message = Get.arguments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            message,
            style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 7.h,
          ),
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
                  Get.to(() => AddMemberScreen());
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
                onPressed: () {
                  Get.to(() => AddMemberScreen());
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
          SizedBox(
            height: 4.h,
          ),
        ],
      ),
    );
  }
}
