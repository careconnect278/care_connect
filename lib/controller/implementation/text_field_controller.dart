import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/model/pill_field_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class TextFieldController extends GetxController {
  TextEditingController caretakerEmailController = TextEditingController();
  TextEditingController caretakerPasswordController = TextEditingController();
  TextEditingController caretakerPhoneNumberController =
      TextEditingController();
      TextEditingController noiseDecibelController=TextEditingController();
      TextEditingController toSleepTimeController=TextEditingController();
      TextEditingController fromSleeptimeController=TextEditingController();
      
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
  assignValuesForEdit(BenefiiciaryModel benefiiciaryModel) {
   noiseDecibelController.text=benefiiciaryModel.noiseDecibel??"100";
    emergencyNumberControlllers.clear();
    allergiesControlllers.clear();
    medicationControlllers.clear();
    beneficiaryageController.text = benefiiciaryModel.age.toString();
    beneficiaryNameController.text = benefiiciaryModel.name;
    alertTimeController.text = benefiiciaryModel.timeToAlert;
   if(benefiiciaryModel.emergencynumbers.isNotEmpty){
     for (var emergency in benefiiciaryModel.emergencynumbers) {
      emergencyNumberControlllers.add(TextEditingController(text: emergency));
    }
   }else{
    emergencyNumberControlllers.addAll([TextEditingController(), TextEditingController()]);
   }
    if(benefiiciaryModel.alergies.isNotEmpty){
      for (var allergy in benefiiciaryModel.alergies) {
      allergiesControlllers.add(TextEditingController(text: allergy));
    }
    }else{
      allergiesControlllers.addAll([TextEditingController(), TextEditingController()]);
    }
    if(benefiiciaryModel.medications.isNotEmpty){for (var medicals in benefiiciaryModel.medications) {
      MedicationModel medicationModel = MedicationModel();
      medicationModel.nameController.text = medicals.name;
      medicationModel.timeController.text = medicals.time;
      medicationModel.id = medicals.id;
      medicationControlllers.add(medicationModel);
    }}
    else{
     medicationControlllers.add(MedicationModel()); 
    }
  }

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
  clear(){
    caretakerEmailController.clear();
caretakerPasswordController.clear();
caretakerPhoneNumberController.clear();
caretakerNameController.clear();
beneficiaryEmailController.clear();
beneficiaryPasswordController.clear();
beneficiaryageController.clear();
beneficiaryNameController.clear();
alertTimeController.clear();

// Clear emergency number controllers
for (var controller in emergencyNumberControlllers) {
  controller.clear();
}

// Clear allergies controllers
for (var controller in allergiesControlllers) {
  controller.clear();
}

// Clear medication controllers
for (var medication in medicationControlllers) {
  medication.nameController.clear();
  medication.timeController.clear();
}

  }
}
