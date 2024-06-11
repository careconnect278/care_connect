import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/show_aleergies.dart';

class LoaderController extends GetxController {
  RxBool loader = false.obs;
  RxBool isShowAllergy = false.obs;
  RxList<String>sleepLogs=<String>[].obs;
  RxBool notificationSender=false.obs;
  RxList<String>noiseLogs=<String>[].obs;
  
  @override
  void onInit() {
    getShowAllergy();
    super.onInit();
  }

  void start() {
    loader.value = true;
  }

  void stop() {
    loader.value = false;
  }

  getShowAllergy() {
    ShowAllergies showAllergies = ShowAllergies();
    isShowAllergy.value = showAllergies.retrieveFromGetStorage();
    debugPrint("showAllergy${isShowAllergy.value}");
  }

aadsleepLogs(String log){
sleepLogs.add(log);
update();
}aadsNoiseLogs(String log){
noiseLogs.add(log);
update();
}
updateNotificationSender(bool value){
notificationSender.value=value;
update();
}
}
