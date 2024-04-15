import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_local_db.dart';
import 'package:care_connect/controller/services/noise_service.dart';
import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/model/care_taker_model.dart';
import 'package:care_connect/model/inactivity_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/beneficiary_model.dart';

class MemberManagementOnCareTaker extends GetxController {
  RxList<BenefiiciaryModel> members = <BenefiiciaryModel>[].obs;
  Rx<LoginState> loginState = Rx<LoginState>(LoginState.login);
  Rx<BenefiiciaryModel?> beneficiary = Rx<BenefiiciaryModel?>(null);

  Rx<CareTakerModel?> caretaker = Rx<CareTakerModel?>(null);
  Rx<InactivityDetailsModel> inactivitydetails = Rx<InactivityDetailsModel>(
      InactivityDetailsModel(
          lastLockedTime: "", lastInactivityHours: "", lastUnlockedTime: ""));
  @override
  void onInit() {
    getAndNavigate();

    super.onInit();
  }

  CareTakerDatabaseService careTakerDatabaseService =
      CareTakerDatabaseService();
  BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();

  CareTakerLocalService careTakerLocalService = CareTakerLocalService();
  BeneficiaryLocalService beneficiaryLocalService = BeneficiaryLocalService();
  getAndNavigate() async {
    members.clear();
    if (careTakerLocalService.box.hasData("caretaker")) {
      loginState.value = LoginState.caretaker;

      CareTakerModel careTakerModel =
          careTakerLocalService.retrieveFromGetStorage();
      debugPrint("local${careTakerModel.toJson()}");
      careTakerModel =
          await careTakerDatabaseService.getcareDetails(careTakerModel.careUid);

      for (var a in careTakerModel.memberUid) {
        BenefiiciaryModel benefiiciaryModel =
            await beneficiaryDatabaseService.getBenDetails(a);

        members.add(benefiiciaryModel);
      }
      caretaker.value = careTakerModel;
      careTakerLocalService.saveToGetStorage(careTakerModel.toJson());
      debugPrint("firebase${careTakerModel.toJson()}");
    } else if (beneficiaryLocalService.box.hasData("beneficiary")) {
      loginState.value = LoginState.beneficiary;
      BenefiiciaryModel benefiiciaryModel =
          beneficiaryLocalService.retrieveFromGetStorage();
      debugPrint("local${benefiiciaryModel.toJson(true)}");
      benefiiciaryModel = await beneficiaryDatabaseService
          .getBenDetails(benefiiciaryModel.memberUid);
      beneficiary.value = benefiiciaryModel;
      CareTakerModel careTakerModel = await careTakerDatabaseService
          .getcareDetails(benefiiciaryModel.careUid);

      for (var a in careTakerModel.memberUid) {
        BenefiiciaryModel benefiiciaryModel =
            await beneficiaryDatabaseService.getBenDetails(a);

        members.add(benefiiciaryModel);
      }
      caretaker.value = careTakerModel;
      beneficiaryDatabaseService
          .getInactivityDetailsStream(benefiiciaryModel.memberUid)
          .listen((event) {
        inactivitydetails.value = InactivityDetailsModel.fromJson(event[0]);
      });
      beneficiaryLocalService.saveToGetStorage(benefiiciaryModel.toJson(true));
      debugPrint("firebase${benefiiciaryModel.toJson(true)}");
      ScreenTimerServices().startListening();

      NoiseService noiseService = NoiseService();
      noiseService.start(benefiiciaryModel);
    } else {
      loginState.value = LoginState.login;
    }
  }

  getInactivityDetails(String uid) {
    beneficiaryDatabaseService.getInactivityDetailsStream(uid).listen((event) {
      inactivitydetails.value = InactivityDetailsModel.fromJson(event[0]);
    });
  }
}

enum LoginState { login, caretaker, beneficiary }
