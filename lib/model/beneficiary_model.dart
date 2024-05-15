import 'dart:math';

import 'package:care_connect/model/medication_model.dart';
import 'package:flutter/material.dart';

class BenefiiciaryModel {
  String name;
  int age;
  String email;
  String careUid;
  String memberUid;
  String timeToAlert;
  List<String> emergencynumbers;
  String careToken;
  String benToken;
  List<String> alergies;
  List<MedicationPillModel> medications;
  String? random;
  String? noiseDecibel;

  BenefiiciaryModel(
      {required this.name,
      required this.age,
      required this.email,
      required this.careUid,
      required this.memberUid,
      required this.timeToAlert,
      required this.alergies,required this.noiseDecibel,
      required this.benToken,
      required this.careToken,
      required this.emergencynumbers,
      required this.medications,
      this.random});

  factory BenefiiciaryModel.fromJson(
      Map<String, dynamic> json, List<MedicationPillModel> medications) {
    List<dynamic> alergies = json["alergies"];
    List<dynamic> emergency = json["emergency"];
    debugPrint(json.toString());
    return BenefiiciaryModel(
      noiseDecibel: json["noiseDecibel"]==null?"85":json["noiseDecibel"].toString(),
        random: json["random"].toString(),
        medications: medications,
        name: json['name'].toString(),
        age: json['age'],
        email: json['email'].toString(),
        careUid: json['careUid'].toString(),
        memberUid: json['memberUid'].toString(),
        timeToAlert: json['timeToAlert'].toString(),
        alergies: alergies.map((e) => e.toString()).toList(),
        emergencynumbers: emergency.map((e) => e.toString()).toList(),
        benToken: json["benToken"].toString(),
        careToken: json["careToken"].toString());
  }

  Map<String, dynamic> toJson(bool isLocal, bool isAuth) {
    var a = {
      "noiseDecibel":noiseDecibel==null?"100":noiseDecibel!.isEmpty?"100":noiseDecibel,
      'name': name,
      'age': age,
      'email': email,
      'careUid': careUid,
      'memberUid': memberUid,
      'timeToAlert': timeToAlert,
      'alergies': alergies,
      "emergency": emergencynumbers,
      "careToken": careToken,
      "benToken": benToken,
    };
    if (isAuth) {
      a.addAll({"random": randomCode()});
    } else {
      if (random != null) {
        a.addAll({"random": random!});
      }
    }
    if (isLocal) {
      a.addAll({
        "medications": medications.map((e) => e.toJson()).toList(),
      });
    }

    return a;
  }

  @override
  String toString() {
    return 'BenefiiciaryModel{name: $name, age: $age, email: $email, careUid: $careUid, memberUid: $memberUid, timeToAlert: $timeToAlert}';
  }
}

String randomCode() {
  Random random = Random();
  int randomNumber = random.nextInt(100000); //
  String dateTime = DateTime.now().toString();
  return "$randomNumber$dateTime";
}
