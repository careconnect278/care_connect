import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/controller/implementation/text_field_controller.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_local_db.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/beneficiary_model.dart';
import '../../model/care_taker_model.dart';
import '../../model/login_return_model.dart';
import '../../model/medication_model.dart';
import '../../view/add_member_screen.dart';
import 'authentication_service.dart';
import 'notification_service.dart';
/// A class representing operations related to form submissions.
class FormSubmission {
  // Initializing necessary services
  static NotificationServices notificationServices = NotificationServices();
  static AuthentincationServices authenticationServices =
      AuthentincationServices();
  static BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();

  /// Registers a new member.
  ///
  /// This method registers a new member and associated caretaker in the system.
  ///
  /// Parameters:
  /// - [textFieldController]: Controller containing form data.
  /// - [managementOnCareTaker]: Object managing caretaker information.
  static Future<void> register(
    TextFieldController  textFieldController,
    MemberManagementOnCareTaker  managementOnCareTaker,
  ) async {
    // Getting loader instance
    LoaderController loader = Get.find();
    loader.start();

    // Obtaining notification token
    String token = await notificationServices.getToken();

    // Creating beneficiary model
    BenefiiciaryModel beneficiaryModel = BenefiiciaryModel(
      benToken: "",
      careToken: token,
      name: textFieldController.beneficiaryNameController.text,
      age: int.parse(textFieldController.beneficiaryageController.text),
      email: textFieldController.beneficiaryEmailController.text,
      careUid: "",
      memberUid: "",
      timeToAlert: textFieldController.alertTimeController.text,
      medications: textFieldController.medicationControlllers
          .where((medication) => medication.nameController.text.isNotEmpty)
          .toList()
          .map((e) => MedicationPillModel(
                name: e.nameController.text,
                time: e.timeController.text,
                id: "",
              ))
          .toList(),
      alergies: textFieldController.allergiesControlllers
          .where((allergy) => allergy.text.isNotEmpty)
          .toList()
          .map((e) => e.text)
          .toList(),
      emergencynumbers: textFieldController.emergencyNumberControlllers
          .where((emergency) => emergency.text.isNotEmpty)
          .toList()
          .map((e) => e.text)
          .toList(),
    );

    // Registering user
    LoginReturnModel loginReturnModel = await authenticationServices.registeruser(
      beneficiaryModel.email,
      textFieldController.beneficiaryPasswordController.text,
      false,
      null,
      beneficiaryModel,
    );

    // Creating caretaker model
    CareTakerModel careTakerModel = CareTakerModel(
      name: textFieldController.caretakerNameController.text,
      phoneNumber: textFieldController.caretakerPhoneNumberController.text,
      email: textFieldController.caretakerEmailController.text,
      careToken: token,
      careUid: "",
      memberUid: [loginReturnModel.uid],
    );

    // Registering caretaker
    authenticationServices.registeruser(
      careTakerModel.email,
      textFieldController.caretakerPasswordController.text,
      true,
      careTakerModel,
      null,
    ).then((value) {
      if (value.responseValue) {
        // Stopping loader and showing success message
        loader.stop();
        Get.showSnackbar(const GetSnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          title: "Success",
          message: "Successfully registered",
        ));
        managementOnCareTaker.getAndNavigate();
        Get.to(() => AddMemberScreen());
      }
    });
  }

  /// Adds a new member to an existing caretaker.
  ///
  /// This method adds a new member to an existing caretaker in the system.
  ///
  /// Parameters:
  /// - [textFieldController]: Controller containing form data.
  /// - [managementOnCareTaker]: Object managing caretaker information.
  static Future<void> add(
    TextFieldController textFieldController,
    MemberManagementOnCareTaker managementOnCareTaker,
  ) async {
    // Getting loader instance
    LoaderController loader = Get.find();
    loader.start();

    // Obtaining notification token
    String token = await notificationServices.getToken();

    // Creating beneficiary model
    BenefiiciaryModel beneficiaryModel = BenefiiciaryModel(
      benToken: "",
      careToken: token,
      name: textFieldController.beneficiaryNameController.text,
      age: int.parse(textFieldController.beneficiaryageController.text),
      email: textFieldController.beneficiaryEmailController.text,
      careUid: managementOnCareTaker.caretaker.value!.careUid,
      memberUid: "",
      timeToAlert: textFieldController.alertTimeController.text,
      medications: textFieldController.medicationControlllers
          .where((medication) => medication.nameController.text.isNotEmpty)
          .toList()
          .map((e) => MedicationPillModel(
                name: e.nameController.text,
                time: e.timeController.text,
                id: "",
              ))
          .toList(),
      alergies: textFieldController.allergiesControlllers
          .where((allergy) => allergy.text.isNotEmpty)
          .toList()
          .map((e) => e.text)
          .toList(),
      emergencynumbers: textFieldController.emergencyNumberControlllers
          .where((emergency) => emergency.text.isNotEmpty)
          .toList()
          .map((e) => e.text)
          .toList(),
    );

    // Registering user
    await authenticationServices.registeruser(
      beneficiaryModel.email,
      textFieldController.beneficiaryPasswordController.text,
      false,
      null,
      beneficiaryModel,
    ).then((value) {
      CareTakerModel careTakerModel = managementOnCareTaker.caretaker.value!;
      careTakerModel.memberUid.add(value.uid);

      // Updating caretaker details locally
      CareTakerLocalService careTakerLocalService = CareTakerLocalService();
      careTakerLocalService.updateInGetStorage(careTakerModel.toJson());

      // Updating caretaker details in the database
      CareTakerDatabaseService careTakerDatabaseService =
          CareTakerDatabaseService();
      careTakerDatabaseService.caretakerDetailsUpdate(
        careTakerModel.careUid,
        {"memberUid": careTakerModel.memberUid},
      );

      // Stopping loader and showing success message
      managementOnCareTaker.getAndNavigate();
      loader.stop();
      Get.showSnackbar(const GetSnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        title: "Success",
        message: "Successfully added",
      ));
    });
  }

  /// Edits details of an existing member.
  ///
  /// This method edits details of an existing member in the system.
  ///
  /// Parameters:
  /// - [textFieldController]: Controller containing form data.
  /// - [managementOnCareTaker]: Object managing caretaker information.
  /// - [index]: Index of the member to be edited.
  static Future<void> edit(
    TextFieldController textFieldController,
    MemberManagementOnCareTaker managementOnCareTaker,
    int index,
  ) async {
    // Getting loader instance
    LoaderController loader = Get.find();
    loader.start();

    // Obtaining notification token
    String token = await notificationServices.getToken();

    // Creating beneficiary model
    BenefiiciaryModel beneficiaryModel = BenefiiciaryModel(
      benToken: managementOnCareTaker.members[index].benToken,
      careToken: token,
      name: textFieldController.beneficiaryNameController.text,
      age: int.parse(textFieldController.beneficiaryageController.text),
      email: managementOnCareTaker.members[index].email,
      careUid: managementOnCareTaker.caretaker.value!.careUid,
      memberUid: managementOnCareTaker.members[index].memberUid,
      timeToAlert: textFieldController.alertTimeController.text,
      medications: textFieldController.medicationControlllers
          .where((medication) => medication.nameController.text.isNotEmpty)
          .toList()
          .map((e) => MedicationPillModel(
                name: e.nameController.text,
                time: e.timeController.text,
                id: e.id,
              ))
          .toList(),
      alergies: textFieldController.allergiesControlllers
          .where((allergy) => allergy.text.isNotEmpty)
          .toList()
          .map((e) => e.text)
          .toList(),
      emergencynumbers: textFieldController.emergencyNumberControlllers
          .where((emergency) => emergency.text.isNotEmpty)
          .toList()
          .map((e) => e.text)
          .toList(),
    );

    // Adding beneficiary details
    beneficiaryDatabaseService.beneficiaryDetailsAdd(beneficiaryModel);
    beneficiaryDatabaseService.medicalUpdate(
      beneficiaryModel.memberUid,
      beneficiaryModel,
    );

    // Adding inactivity details
    await beneficiaryDatabaseService.addInactivityDetails(
      beneficiaryModel.memberUid,
      {
        "lastunlockedtime": "",
        "lastlockedtime": "",
        "lastInactivityhours": ""
      },
    ).whenComplete(() {
      // Stopping loader and showing success message
      managementOnCareTaker.getAndNavigate();
      loader.stop();
      Get.showSnackbar(const GetSnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        title: "Success",
        message: "Successfully edited",
      ));
    });
  }
}
