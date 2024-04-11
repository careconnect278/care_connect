import 'package:care_connect/model/pill_field_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextFieldController extends GetxController {
  TextEditingController caretakerEmailController = TextEditingController();
  TextEditingController caretakerPasswordController = TextEditingController();
  TextEditingController caretakerPhoneNumberController =
      TextEditingController();
  TextEditingController caretakerNameController = TextEditingController();
  TextEditingController beneficiaryEmailController = TextEditingController();
  TextEditingController beneficiaryPasswordController = TextEditingController();
  TextEditingController beneficiaryageController = TextEditingController();
  TextEditingController beneficiaryNameController = TextEditingController();
TextEditingController alertTimeController = TextEditingController();
  RxList<TextEditingController> emergencyNumberControlllers =
      [TextEditingController(), TextEditingController()].obs;
  RxList<TextEditingController> allergiesControlllers =
      [TextEditingController(), TextEditingController()].obs;
  RxList<MedicationModel> medicationControlllers = [MedicationModel()].obs;
  @override
  void onClose() {
    caretakerEmailController.dispose();
    caretakerPasswordController.dispose();
    caretakerPhoneNumberController.dispose();
    caretakerNameController.dispose();
    beneficiaryEmailController.dispose();
    beneficiaryPasswordController.dispose();
    beneficiaryageController.dispose();
    beneficiaryNameController.dispose();
    for (var emergencycontroller in emergencyNumberControlllers) {
      emergencycontroller.dispose();
    }
    for (var allergyControlller in allergiesControlllers) {
      allergyControlller.dispose();
    }
    for (var medicController in medicationControlllers) {
      medicController.nameController.dispose();
      medicController.timeController.dispose();
    }
    super.onClose();
  }
}
