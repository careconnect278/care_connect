import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/model/medication_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Service class for handling beneficiary-related database operations.
class BeneficiaryDatabaseService {
  final CollectionReference beneficiaryCollection =
      FirebaseFirestore.instance.collection("beneficiary");

  /// Add beneficiary details to the database.
  void beneficiaryDetailsAdd(BenefiiciaryModel beneficiaryModel) {
    try {
      beneficiaryCollection
          .doc(beneficiaryModel.memberUid)
          .set(beneficiaryModel.toJson(false, true));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Update beneficiary details in the database.
  void beneficiaryDetailsUpdate(String uid, Map<String, dynamic> data) async {
    try {
      await beneficiaryCollection.doc(uid).update(data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Add medications for a beneficiary to the database.
  void medicalAdd(String uid, BenefiiciaryModel beneficiary) {
    final MemberManagementOnCareTaker managementOnCareTaker = Get.find();
    final CollectionReference medicationCollection =
        beneficiaryCollection.doc(uid).collection("medication");
    for (var element in beneficiary.medications) {
      final a = medicationCollection.doc();
      element.id = a.id;
      a.set(element.toJson());
      element.time;
    }
    managementOnCareTaker.members.add(beneficiary);
  }

  /// Update medications for a beneficiary in the database.
  void medicalUpdate(String uid, BenefiiciaryModel beneficiary) {
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

  /// Get beneficiary details from the database.
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

  /// Stream for getting inactivity details for a beneficiary.
  Stream<List<Map<String, dynamic>>> getInactivityDetailsStream(String uid) {
    final CollectionReference inactivityDetails =
        beneficiaryCollection.doc(uid).collection("inactivityDetails");

    return inactivityDetails.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  /// Add inactivity details for a beneficiary to the database.
  Future addInactivityDetails(String uid, Map<String, dynamic> data) async {
    final CollectionReference inactivityDetails =
        beneficiaryCollection.doc(uid).collection("inactivityDetails");
    await inactivityDetails.doc(uid).set(data);
  }

  /// Update inactivity details for a beneficiary in the database.
  void inactivityDetailsUpdate(String uid, Map<String, dynamic> data) async {
    try {
      final CollectionReference inactivityDetails =
          beneficiaryCollection.doc(uid).collection("inactivityDetails");
      await inactivityDetails.doc(uid).update(data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
