import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogsList extends StatelessWidget {
  final bool isNoise;
  LogsList({super.key, required this.isNoise});
  final LoaderController loaderController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (isNoise) {
          return ListView.separated(
            itemCount: loaderController.noiseLogs.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Center(
                  child: Text(loaderController.noiseLogs[index]),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          );
        } else {
          return ListView.separated(
            itemCount: loaderController.sleepLogs.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Center(
                  child: Text(loaderController.sleepLogs[index]),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
          );
        }
      }),
    );
  }
}
