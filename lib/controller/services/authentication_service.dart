import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_local_db.dart';
import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/controller/services/noise_service.dart';
import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/model/care_taker_model.dart';
import 'package:care_connect/model/login_return_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../implementation/member_mangement_caretaker_phone.dart';

class AuthentincationServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CareTakerDatabaseService careTakerDatabaseService =
      CareTakerDatabaseService();
  BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();

  BeneficiaryLocalService beneficiaryLocalService = BeneficiaryLocalService();
  CareTakerLocalService careTakerLocalService = CareTakerLocalService();
  Future<bool> loginuser(
      String email, String password, bool isCaretaker) async {
    try {
      MemberManagementOnCareTaker memberManagementOnCareTaker = Get.find();
      User? user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        final token = await NotificationServices().getToken();
        if (isCaretaker) {
          CareTakerModel careTakerModel =
              await careTakerDatabaseService.getcareDetails(user.uid);
          careTakerModel.careToken = token;
          careTakerDatabaseService
              .caretakerDetailsUpdate(user.uid, {"careToken": token});
          for (var a in careTakerModel.memberUid) {
            BenefiiciaryModel benefiiciaryModel =
                await beneficiaryDatabaseService.getBenDetails(a);
            beneficiaryDatabaseService
                .beneficiaryDetailsUpdate(a, {"careToken": token});
            benefiiciaryModel.careToken = token;
            memberManagementOnCareTaker.members.add(benefiiciaryModel);
          }
          memberManagementOnCareTaker.caretaker.value = careTakerModel;
          careTakerLocalService.saveToGetStorage(careTakerModel.toJson());
          memberManagementOnCareTaker.getAndNavigate();
        } else {
          BenefiiciaryModel benefiiciaryModel =
              await beneficiaryDatabaseService.getBenDetails(user.uid);
          benefiiciaryModel.benToken = token;
          beneficiaryDatabaseService
              .beneficiaryDetailsUpdate(user.uid, {"benToken": token});
          beneficiaryLocalService
              .saveToGetStorage(benefiiciaryModel.toJson(true));

          memberManagementOnCareTaker.beneficiary.value = benefiiciaryModel;
          beneficiaryDatabaseService.addInactivityDetails(user.uid, {
            "lastunlockedtime": "",
            "lastlockedtime": "",
            "lastInactivityhours": ""
          });
          memberManagementOnCareTaker.getAndNavigate();
          ScreenTimerServices().startListening();
          NoiseService noiseService = NoiseService();
          noiseService.start(benefiiciaryModel);
        }

        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      Get.showSnackbar(GetSnackBar(
        title: e.code,
        message: e.message,
      ));
      return false;
    }
  }

  //register
  Future<LoginReturnModel> registeruser(
      String email,
      String password,
      bool careTaker,
      CareTakerModel? careTakerModel,
      BenefiiciaryModel? benefiiciaryModel) async {
    try {
      User? user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user != null) {
        if (careTaker) {
          careTakerModel!.careUid = user.uid;
          careTakerDatabaseService.careTakerDetailsAdd(careTakerModel);

          beneficiaryDatabaseService.beneficiaryDetailsUpdate(
              careTakerModel.memberUid.first, {'careUid': user.uid});

          careTakerLocalService.saveToGetStorage(careTakerModel.toJson());
          careTakerLocalService.retrieveFromGetStorage();
        } else {
          benefiiciaryModel!.memberUid = user.uid;
          beneficiaryDatabaseService.beneficiaryDetailsAdd(benefiiciaryModel);
          beneficiaryDatabaseService.medicalAdd(
              benefiiciaryModel.memberUid, benefiiciaryModel);
          beneficiaryDatabaseService.addInactivityDetails(user.uid, {
            "lastunlockedtime": "",
            "lastlockedtime": "",
            "lastInactivityhours": ""
          });
        }

        return LoginReturnModel(uid: user.uid, responseValue: true);
      } else {
        return LoginReturnModel(uid: "", responseValue: false);
      }
    } on FirebaseAuthException catch (e) {
      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 3),
        title: e.code,
        message: e.message,
      ));
      return LoginReturnModel(uid: "", responseValue: false);
    }
  }
}
