import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/model/medication_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BeneficiaryDatabaseService {
  final CollectionReference beneficiaryCollection =
      FirebaseFirestore.instance.collection("beneficiary");

  beneficiaryDetailsAdd(BenefiiciaryModel benefiiciaryModel) {
    try {
      beneficiaryCollection
          .doc(benefiiciaryModel.memberUid)
          .set(benefiiciaryModel.toJson(false));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  beneficiaryDetailsUpdate(String uid, Map<String, dynamic> data) async {
    try {
      await beneficiaryCollection.doc(uid).update(data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  medicalAdd(String uid, BenefiiciaryModel beneficiary) {
    final MemberManagementOnCareTaker managementOnCareTaker = Get.find();
    final CollectionReference medicationCollection =
        beneficiaryCollection.doc(uid).collection("medication");
    for (var element in beneficiary.medications) {
      final a = medicationCollection.doc();
      element.id = a.id;
      a.set(element.toJson());
    }
    managementOnCareTaker.members.add(beneficiary);
  }

  medicalUpdate(String uid, BenefiiciaryModel beneficiary) {
    final CollectionReference medicationCollection =
        beneficiaryCollection.doc(uid).collection("medication");
    for (var element in beneficiary.medications) {
      if (element.id.isEmpty) {
        final a = medicationCollection.doc();
        element.id = a.id;
        a.set(element.toJson());
      } else {
        medicationCollection.doc(element.id).set(element.toJson());
      }
    }
  }

  Future<BenefiiciaryModel> getBenDetails(String uid) async {
    final CollectionReference medicationCollection =
        beneficiaryCollection.doc(uid).collection("medication");
    var a = await beneficiaryCollection.doc(uid).get();

    var b = await medicationCollection.get();
    var docs = b.docs;
    List<MedicationPillModel> medications = docs
        .map((e) =>
            MedicationPillModel.fromJson(e.data() as Map<String, dynamic>))
        .toList();
    return BenefiiciaryModel.fromJson(
        a.data() as Map<String, dynamic>, medications);
  }

  Stream<List<Map<String, dynamic>>> getInactivityDetailsStream(String uid) {
    final CollectionReference inactivityDetails =
        beneficiaryCollection.doc(uid).collection("inactivityDetails");

    return inactivityDetails.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future addInactivityDetails(String uid, Map<String, dynamic> data) async {
    final CollectionReference inactivityDetails =
        beneficiaryCollection.doc(uid).collection("inactivityDetails");
    await inactivityDetails.doc(uid).set(data);
  }

  inactivityDetailsUpdate(String uid, Map<String, dynamic> data) async {
    try {
      final CollectionReference inactivityDetails =
          beneficiaryCollection.doc(uid).collection("inactivityDetails");
      await inactivityDetails.doc(uid).update(data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
