import 'package:care_connect/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.green.shade100,
        body: SizedBox(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(
              height: 4.h,
            ),
            Text(
              'WELCOME',
              style: TextStyle(fontSize: 30.dp, fontWeight: FontWeight.bold),
            ),
            Text(
              'Select user',
              style: TextStyle(fontSize: 15.dp, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 7.h,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(
                  70.w,
                  10.h,
                ),
              ),
              onPressed: () {
                Get.to(() => LoginScreen(isCaretaker: true));
              },
              child: Text(
                'Caretaker',
                style: TextStyle(
                    fontSize: 20.dp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(
                  70.w,
                  10.h,
                ),
              ),
              onPressed: () {
                Get.to(() => LoginScreen(isCaretaker: false));
              },
              child: Text(
                'Beneficiary',
                style: TextStyle(
                    fontSize: 20.dp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            )
          ]),
        ));
  }
}
