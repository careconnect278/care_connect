import 'package:care_connect/model/medication_model.dart';

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

  BenefiiciaryModel(
      {required this.name,
      required this.age,
      required this.email,
      required this.careUid,
      required this.memberUid,
      required this.timeToAlert,
      required this.alergies,
      required this.benToken,
      required this.careToken,
      required this.emergencynumbers,
      required this.medications});

  factory BenefiiciaryModel.fromJson(
      Map<String, dynamic> json, List<MedicationPillModel> medications) {
    List<dynamic> alergies = json["alergies"];
    List<dynamic> emergency = json["emergency"];

    return BenefiiciaryModel(
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

  Map<String, dynamic> toJson(bool isLocal) {
    var a = {
      'name': name,
      'age': age,
      'email': email,
      'careUid': careUid,
      'memberUid': memberUid,
      'timeToAlert': timeToAlert,
      'alergies': alergies,
      "emergency": emergencynumbers,
      "careToken": careToken,
      "benToken": benToken
    };

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
