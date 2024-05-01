import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ShowAllergies {
  final box = GetStorage();
  // Store the JSON representation in GetStorage

  // Retrieve from GetStorage
  bool retrieveFromGetStorage() {
    final a = box.read('ShowAllergy') ?? false;
    debugPrint("showAllergy$a");
    // If medications is a list, cast it to List<Map<String, dynamic>>
    return a;
  }

  // Update in GetStorage
  void updateInGetStorage(bool data) {
    // Assuming you want to update
    box.write('ShowAllergy', data);
  }

  // Delete from GetStorage
  void deleteFromGetStorage() {
    box.remove('beneficiary');
  }
}
