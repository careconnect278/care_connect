import 'package:get/get.dart';

class LoaderController extends GetxController {
  RxBool loader = false.obs;
  void start() {
    loader.value = true;
  }

  void stop() {
    loader.value = false;
  }
}
