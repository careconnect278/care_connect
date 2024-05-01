import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/controller/services/authentication_service.dart';
import 'package:care_connect/view/add_member_screen.dart';
import 'package:care_connect/view/beneficiary_home_screen.dart';
import 'package:care_connect/view/member_details_screen.dart';
import 'package:care_connect/view/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  final bool isCaretaker;
  LoginScreen({super.key, required this.isCaretaker});
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final LoaderController loader = Get.find();
  final MemberManagementOnCareTaker managementOnCareTaker = Get.find();
  final inputDecoration = InputDecoration(
      filled: true,
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    final String text = isCaretaker ? "Caretaker" : "Beneficiary";
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.to(() => const WelcomeScreen());
      },
      child: Scaffold(
        backgroundColor: Colors.green,
        body: SingleChildScrollView(
          child: Obx(
            () => Stack(
              children: [
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$text Login',
                        style: TextStyle(
                            fontSize: 20.dp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 7.h,
                      ),
                      Text(
                        'USERNAME',
                        style: TextStyle(
                            fontSize: 15.dp, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 2.h),
                        child: SizedBox(
                          height: 6.h,
                          child: TextField(
                            decoration: inputDecoration,
                            controller: emailController,
                          ),
                        ),
                      ),
                      Text(
                        'PASSWORD',
                        style: TextStyle(
                            fontSize: 15.dp, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 2.h),
                        child: SizedBox(
                            height: 6.h,
                            child: TextField(
                              decoration: inputDecoration,
                              controller: passwordController,
                            )),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (emailController.text.isNotEmpty) {
                                AuthentincationServices()
                                    .resetPassword(email: emailController.text);
                              }
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  fontSize: 15.dp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 4.h,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.lightGreen.shade300,
                            minimumSize: Size(
                              20.w,
                              20.w,
                            ),
                          ),
                          onPressed: () async {
                            loader.start();
                            await AuthentincationServices()
                                .loginuser(emailController.text,
                                    passwordController.text, isCaretaker)
                                .then((value) {
                              if (value) {
                                managementOnCareTaker.getAndNavigate();
                                if (isCaretaker) {
                                  Get.to(() => AddMemberScreen());
                                } else {
                                  Get.to(() => BeneficiaryHomeScreen());
                                }
                                loader.stop();
                              }
                            });
                          },
                          child: const Icon(
                            Icons.login,
                            color: Colors.green,
                          )),
                      SizedBox(
                        height: 2.h,
                      ),
                      if (isCaretaker)
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightGreen.shade300,
                              minimumSize: Size(
                                20.w,
                                6.h,
                              ),
                            ),
                            onPressed: () async {
                              Get.to(() => MemberDetailsScreen(
                                  memberDetailsScreenState:
                                      MemberDetailsScreenState.register));
                            },
                            child: const Text(
                              'Register\nif you havent account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            )),
                    ],
                  ),
                ),
                if (loader.loader.value) ...{
                  SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.black,
                                ),
                                Text(
                                  'Loading',
                                  style: TextStyle(
                                      fontSize: 20.dp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                      ))
                }
              ],
            ),
          ),
        ),
      ),
    );
  }
}
