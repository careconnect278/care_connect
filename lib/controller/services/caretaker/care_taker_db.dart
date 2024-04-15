import 'package:care_connect/model/care_taker_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class CareTakerDatabaseService {
  final CollectionReference careTakerCollection =
      FirebaseFirestore.instance.collection("caretaker");

  careTakerDetailsAdd(CareTakerModel careTakerModel) {
    try {
      careTakerCollection
          .doc(careTakerModel.careUid)
          .set(careTakerModel.toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  caretakerDetailsUpdate(String uid, Map<String, dynamic> data) async {
    try {
      await careTakerCollection.doc(uid).update(data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<CareTakerModel> getcareDetails(String uid) async {
    var a = await careTakerCollection.doc(uid).get();

    return CareTakerModel.fromJson(a.data() as Map<String, dynamic>);
  }
}
