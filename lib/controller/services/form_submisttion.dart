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
import 'caretaker/notification_service.dart';

class FormSubmission {
  static NotificationServices notificationServices = NotificationServices();
  static AuthentincationServices authentincationServices =
      AuthentincationServices();
  static BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();
  static Future<void> register(TextFieldController textFieldController,
      MemberManagementOnCareTaker managementOnCareTaker) async {
    LoaderController loader = Get.find();
    loader.start();
    String token = await notificationServices.getToken();
    BenefiiciaryModel benefiiciaryModel = BenefiiciaryModel(
        benToken: "",
        careToken: token,
        name: textFieldController.beneficiaryNameController.text,
        age: int.parse(textFieldController.beneficiaryageController.text),
        email: textFieldController.beneficiaryEmailController.text,
        careUid: "",
        memberUid: "",
        timeToAlert: textFieldController.alertTimeController.text,
        medications: textFieldController.medicationControlllers
            .where((allergy) => allergy.nameController.text.isNotEmpty)
            .toList()
            .map((e) => MedicationPillModel(
                name: e.nameController.text,
                time: e.timeController.text,
                id: ""))
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
            .toList());
    LoginReturnModel loginReturnModel =
        await authentincationServices.registeruser(
            benefiiciaryModel.email,
            textFieldController.beneficiaryPasswordController.text,
            false,
            null,
            benefiiciaryModel);

    CareTakerModel careTakerModel = CareTakerModel(
        name: textFieldController.caretakerNameController.text,
        phoneNumber: textFieldController.caretakerPhoneNumberController.text,
        email: textFieldController.caretakerEmailController.text,
        careToken: token,
        careUid: "",
        memberUid: [loginReturnModel.uid]);
    authentincationServices
        .registeruser(
            careTakerModel.email,
            textFieldController.caretakerPasswordController.text,
            true,
            careTakerModel,
            null)
        .then((value) {
      if (value.responseValue) {
        loader.stop();
        Get.showSnackbar(const GetSnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          title: "Success",
          message: "Successfully edited",
        ));
        managementOnCareTaker.getAndNavigate();
        Get.to(() => AddMemberScreen());
      }
    });
  }

  static Future<void> add(TextFieldController textFieldController,
      MemberManagementOnCareTaker managementOnCareTaker) async {
    LoaderController loader = Get.find();
    loader.start();
    String token = await notificationServices.getToken();
    BenefiiciaryModel benefiiciaryModel = BenefiiciaryModel(
        benToken: "",
        careToken: token,
        name: textFieldController.beneficiaryNameController.text,
        age: int.parse(textFieldController.beneficiaryageController.text),
        email: textFieldController.beneficiaryEmailController.text,
        careUid: managementOnCareTaker.caretaker.value!.careUid,
        memberUid: "",
        timeToAlert: textFieldController.alertTimeController.text,
        medications: textFieldController.medicationControlllers
            .where((allergy) => allergy.nameController.text.isNotEmpty)
            .toList()
            .map((e) => MedicationPillModel(
                name: e.nameController.text,
                time: e.timeController.text,
                id: ""))
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
            .toList());

    await authentincationServices
        .registeruser(
            benefiiciaryModel.email,
            textFieldController.beneficiaryPasswordController.text,
            false,
            null,
            benefiiciaryModel)
        .then((value) {
      CareTakerModel careTakerModel = managementOnCareTaker.caretaker.value!;
      careTakerModel.memberUid.add(value.uid);
      CareTakerLocalService careTakerLocalService = CareTakerLocalService();
      careTakerLocalService.updateInGetStorage(careTakerModel.toJson());
      CareTakerDatabaseService careTakerDatabaseService =
          CareTakerDatabaseService();
      careTakerDatabaseService.caretakerDetailsUpdate(
          careTakerModel.careUid, {"memberUid": careTakerModel.memberUid});
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

  static Future<void> edit(TextFieldController textFieldController,
      MemberManagementOnCareTaker managementOnCareTaker, int index) async {
    LoaderController loader = Get.find();
    loader.start();
    String token = await notificationServices.getToken();
    BenefiiciaryModel benefiiciaryModel = BenefiiciaryModel(
        benToken: managementOnCareTaker.members[index].benToken,
        careToken: token,
        name: textFieldController.beneficiaryNameController.text,
        age: int.parse(textFieldController.beneficiaryageController.text),
        email: managementOnCareTaker.members[index].email,
        careUid: managementOnCareTaker.caretaker.value!.careUid,
        memberUid: managementOnCareTaker.members[index].memberUid,
        timeToAlert: textFieldController.alertTimeController.text,
        medications: textFieldController.medicationControlllers
            .where((allergy) => allergy.nameController.text.isNotEmpty)
            .toList()
            .map((e) => MedicationPillModel(
                name: e.nameController.text,
                time: e.timeController.text,
                id: e.id))
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
            .toList());

    beneficiaryDatabaseService.beneficiaryDetailsAdd(benefiiciaryModel);
    beneficiaryDatabaseService.medicalUpdate(
        benefiiciaryModel.memberUid, benefiiciaryModel);
    await beneficiaryDatabaseService.addInactivityDetails(
        benefiiciaryModel.memberUid, {
      "lastunlockedtime": "",
      "lastlockedtime": "",
      "lastInactivityhours": ""
    }).whenComplete(() {
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
