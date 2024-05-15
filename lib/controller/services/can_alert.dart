import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Canalert {
  final box = GetStorage();
  // Store the JSON representation in GetStorage

  // Retrieve from GetStorage
  bool retrieveFromGetStorage() {
    final a = box.read('canAlert') ?? false;
    debugPrint("canAlert$a");
    
    // If medications is a list, cast it to List<Map<String, dynamic>>
    return a;
  }

  // Update in GetStorage
  void updateAlert(bool data) {
    // Assuming you want to update
    box.write('canAlert', data);
  }

  // Delete from GetStorage
  void deleteFromGetStorage() {
    box.remove('beneficiary');
  }
}
