import 'package:care_connect/model/care_taker_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

/// A service class for interacting with the Firestore database regarding CareTaker information.
class CareTakerDatabaseService {
  final CollectionReference careTakerCollection =
      FirebaseFirestore.instance.collection("caretaker");

  /// Adds CareTaker details to the Firestore database.
  ///
  /// Parameters:
  /// - careTakerModel: An instance of CareTakerModel containing the details of the CareTaker.
  void careTakerDetailsAdd(CareTakerModel careTakerModel) {
    try {
      careTakerCollection
          .doc(careTakerModel.careUid)
          .set(careTakerModel.toJson());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Updates CareTaker details in the Firestore database.
  ///
  /// Parameters:
  /// - uid: The unique identifier of the CareTaker whose details need to be updated.
  /// - data: A Map containing the updated data for the CareTaker.
  Future<void> caretakerDetailsUpdate(String uid, Map<String, dynamic> data) async {
    try {
      await careTakerCollection.doc(uid).update(data);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Retrieves CareTaker details from the Firestore database.
  ///
  /// Parameters:
  /// - uid: The unique identifier of the CareTaker whose details need to be retrieved.
  ///
  /// Returns:
  /// A Future containing the CareTakerModel object representing the CareTaker's details.
  Future<CareTakerModel> getcareDetails(String uid) async {
    var documentSnapshot = await careTakerCollection.doc(uid).get();
    return CareTakerModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
  }
}
