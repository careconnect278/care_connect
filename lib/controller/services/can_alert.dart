import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class Canalert {
  // Store the JSON representation in SharedPreferences

  // Retrieve from SharedPreferences
  Future<bool> retrieveFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final a = prefs.getBool('canAlert');
    prefs.reload();
    // debugPrint("canAlert$a");
    log(a.toString());
    // If medications is a list, cast it to List<Map<String, dynamic>>
    return a ?? false;
  }

  // Update in SharedPreferences
  Future<void> updateAlert(bool data) async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming you want to update
    await prefs.setBool('canAlert', data);
    log(data.toString());
  }

  // Delete from SharedPreferences
  Future<void> deleteFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('canAlert');
  }
}
