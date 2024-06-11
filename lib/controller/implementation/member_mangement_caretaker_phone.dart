import 'dart:async';

import 'package:care_connect/controller/implementation/loader_controller.dart';
import 'package:care_connect/controller/services/alarm_service.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_local_db.dart';
import 'package:care_connect/controller/services/noise_service.dart';
// import 'package:care_connect/controller/services/noise_service.dart';
import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/model/care_taker_model.dart';
import 'package:care_connect/model/inactivity_model.dart';
import 'package:care_connect/model/medication_model.dart';
import 'package:care_connect/view/login_screen.dart';
import 'package:care_connect/view/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
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
  Stream<DocumentSnapshot<Object?>>? uidSubscription;

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
    LoaderController loaderController = Get.find();
    beneficiaryDatabaseService.checkUIDExists("lAeXDdoYvPgQLhXj56xBcXnUhmT2");
    members.clear();
    if (careTakerLocalService.box.hasData("caretaker")) {
      loginState.value = LoginState.caretaker;

      CareTakerModel careTakerModel =
          careTakerLocalService.retrieveFromGetStorage();
      debugPrint("local${careTakerModel.toJson()}");
      try {
        careTakerModel = await careTakerDatabaseService
            .getcareDetails(careTakerModel.careUid);

        for (var a in careTakerModel.memberUid) {
          BenefiiciaryModel benefiiciaryModel =
              await beneficiaryDatabaseService.getBenDetails(a);
          if (a.isNotEmpty) {
            members.add(benefiiciaryModel);
          }
        }
        caretaker.value = careTakerModel;
        careTakerLocalService.saveToGetStorage(careTakerModel.toJson());
        debugPrint("firebase${careTakerModel.toJson()}");
      } catch (e) {
        loaderController.stop();
      }
    } else if (beneficiaryLocalService.box.hasData("beneficiary")) {
      loginState.value = LoginState.beneficiary;
      BenefiiciaryModel benefiiciaryModel =
          beneficiaryLocalService.retrieveFromGetStorage();
      benLogout(benefiiciaryModel.memberUid);
      debugPrint("local${benefiiciaryModel.toJson(true, true)}");
      // beneficiaryDatabaseService.beneficiaryDetailsAdd(benefiiciaryModel);
      try {
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
        beneficiaryLocalService
            .saveToGetStorage(benefiiciaryModel.toJson(true, false));
        debugPrint("firebase${benefiiciaryModel.toJson(true, true)}");
        ScreenTimerServices().startListening("init");
        NoiseService noiseService = NoiseService();
        await noiseService.start(benefiiciaryModel, "init");
        try {
          for (int i = 0; i <= benefiiciaryModel.medications.length; i++) {
            MedicationPillModel medicationPillModel =
                benefiiciaryModel.medications[i];
            TimeOfDay timeOfDay = parseTimeOfDay(medicationPillModel.time);

            await periodicAlarms(medicationPillModel.name, timeOfDay, i);
          }
        } catch (e) {
          if (kDebugMode) {
            print(e.toString());
          }
        }
      } catch (e) {
        loaderController.stop();
      }
    } else {
      loginState.value = LoginState.login;
    }
  }

  getInactivityDetails(String uid) {
    beneficiaryDatabaseService.getInactivityDetailsStream(uid).listen((event) {
      inactivitydetails.value = InactivityDetailsModel.fromJson(event[0]);
    });
  }

  logout() async {
    careTakerLocalService.deleteFromGetStorage();
    caretaker.value = null;
    members.clear();
    await FirebaseAuth.instance.signOut();

    Get.to(() => LoginScreen(isCaretaker: true));
  }

  benLogout(String uid) {
    uidSubscription = beneficiaryDatabaseService.checkUIDExists(uid);
    uidSubscription!.listen(
      (event) {
        debugPrint("event.exists ${event.exists}");
        if (event.exists) {
        } else {
          beneficiaryLocalService.deleteFromGetStorage();
          ScreenTimerServices screenTimerServices = ScreenTimerServices();
          screenTimerServices.stopListening();
          // NoiseService noiseService = NoiseService();
          // noiseService.stop();

          beneficiary.value = null;
          FirebaseAuth.instance.currentUser!.delete();
          Get.to(() => const WelcomeScreen());
          FirebaseAuth.instance.signOut();
        }
      },
    );
  }

  deleteBen(int index) {
    beneficiaryDatabaseService.deleteDocument(members[index].memberUid);
    caretaker.value!.memberUid.removeWhere(
      (element) {
        return element.trim().contains(members[index].memberUid.trim());
      },
    );
    caretaker.value!.memberUid.removeWhere(
      (element) => element.isEmpty,
    );
    members.removeAt(index);
    careTakerLocalService.updateInGetStorage(caretaker.value!.toJson());
    careTakerDatabaseService.caretakerDetailsUpdate(
        caretaker.value!.careUid, {"memberUid": caretaker.value!.memberUid});
    update();
  }
}

enum LoginState { login, caretaker, beneficiary }
