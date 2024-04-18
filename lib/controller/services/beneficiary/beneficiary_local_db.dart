
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/model/medication_model.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class BeneficiaryLocalService {
  final box = GetStorage();
  // Store the JSON representation in GetStorage
  void saveToGetStorage(Map<String, dynamic> data) {
    debugPrint("saveBen");
    // Assuming you want to store it with medications
    box.write('beneficiary', data);
    retrieveFromGetStorage();
  }

  // Retrieve from GetStorage
  BenefiiciaryModel retrieveFromGetStorage() {
    final a = box.read('beneficiary') ?? {};
    debugPrint("get_ben$a");
    // If medications is a list, cast it to List<Map<String, dynamic>>
    List medidetails = a["medications"];
    List<MedicationPillModel> medications =
        medidetails.map((e) => MedicationPillModel.fromJson(e)).toList();
    // Do whatever you need with medications

    BenefiiciaryModel benefiiciaryModel =
        BenefiiciaryModel.fromJson(a as Map<String, dynamic>, medications);
    return benefiiciaryModel;
  }

  // Update in GetStorage
  void updateInGetStorage(Map<String, dynamic> data) {
    // Assuming you want to update with bendata
    box.write('beneficiary', data);
  }

  // Delete from GetStorage
  void deleteFromGetStorage() {
    box.remove('beneficiary');
  }
}
