// ignore_for_file: deprecated_member_use, avoid_print

import 'package:care_connect/controller/services/beneficiary/beneficiary_db.dart';
import 'package:care_connect/controller/services/beneficiary/beneficiary_local_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_db.dart';
import 'package:care_connect/controller/services/caretaker/care_taker_local_db.dart';
import 'package:care_connect/controller/services/noise_service.dart';
import 'package:care_connect/controller/services/notification_service.dart';
import 'package:care_connect/controller/services/screen_timer_services.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/model/care_taker_model.dart';
import 'package:care_connect/model/login_return_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../implementation/loader_controller.dart';
import '../implementation/member_mangement_caretaker_phone.dart';

/// Class responsible for handling authentication services.
class AuthentincationServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  CareTakerDatabaseService careTakerDatabaseService =
      CareTakerDatabaseService();
  BeneficiaryDatabaseService beneficiaryDatabaseService =
      BeneficiaryDatabaseService();

  BeneficiaryLocalService beneficiaryLocalService = BeneficiaryLocalService();
  CareTakerLocalService careTakerLocalService = CareTakerLocalService();

  /// Method to login a user.
  ///
  /// Takes [email], [password], and [isCaretaker] as input.
  /// Returns a Future<bool> indicating the success or failure of the login attempt.
  Future<bool> loginuser(
      String email, String password, bool isCaretaker) async {
    LoaderController loader = Get.find();
    try {
      MemberManagementOnCareTaker memberManagementOnCareTaker = Get.find();
      User? user = (await firebaseAuth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;

      if (user != null) {
        final token = await NotificationServices().getToken();
        if (isCaretaker) {
          memberManagementOnCareTaker.members.clear();
          // If the user is a caretaker
          CareTakerModel careTakerModel =
              await careTakerDatabaseService.getcareDetails(user.uid);
          careTakerModel.careToken = token;
          careTakerDatabaseService
              .caretakerDetailsUpdate(user.uid, {"careToken": token});
          for (var a in careTakerModel.memberUid) {
            // Update beneficiary care token and add to the caretaker's member list
            BenefiiciaryModel benefiiciaryModel =
                await beneficiaryDatabaseService.getBenDetails(a);
            beneficiaryDatabaseService
                .beneficiaryDetailsUpdate(a, {"careToken": token});
            benefiiciaryModel.careToken = token;
            memberManagementOnCareTaker.members.add(benefiiciaryModel);
          }
          memberManagementOnCareTaker.members.clear();
          // Update caretaker details in local storage and navigate
          memberManagementOnCareTaker.caretaker.value = careTakerModel;
          careTakerLocalService.saveToGetStorage(careTakerModel.toJson());
          // memberManagementOnCareTaker.getAndNavigate();
        } else {
          // If the user is a beneficiary
          BenefiiciaryModel benefiiciaryModel =
              await beneficiaryDatabaseService.getBenDetails(user.uid);
          benefiiciaryModel.benToken = token;
          benefiiciaryModel.random = randomCode();
          beneficiaryDatabaseService.beneficiaryDetailsUpdate(user.uid,
              {"benToken": token, "random": benefiiciaryModel.random});
          beneficiaryLocalService
              .saveToGetStorage(benefiiciaryModel.toJson(true, true));

          // Update beneficiary details in local storage, add inactivity details, and navigate
          memberManagementOnCareTaker.beneficiary.value = benefiiciaryModel;
          beneficiaryDatabaseService.addInactivityDetails(user.uid, {
            "lastunlockedtime": "",
            "lastlockedtime": "",
            "lastInactivityhours": ""
          });
          memberManagementOnCareTaker.getAndNavigate();
          ScreenTimerServices().startListening("auth");
          NoiseService noiseService = NoiseService();
          await noiseService.start(benefiiciaryModel, "auth");
        }

        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      loader.stop();
      // Show error message if login fails
      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 2),
        title: e.code,
        message: e.message,
      ));
      return false;
    }
  }

  /// Method to register a new user.
  ///
  /// Takes [email], [password], [careTaker], [careTakerModel], and [benefiiciaryModel] as input.
  /// Returns a Future<LoginReturnModel> indicating the success or failure of the registration attempt.
  Future<LoginReturnModel> registeruser(
      String email,
      String password,
      bool careTaker,
      CareTakerModel? careTakerModel,
      BenefiiciaryModel? benefiiciaryModel) async {
    LoaderController loader = Get.find();
    try {
      User? user = (await firebaseAuth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      if (user != null) {
        if (careTaker) {
          // If registering as a caretaker
          careTakerModel!.careUid = user.uid;
          careTakerDatabaseService.careTakerDetailsAdd(careTakerModel);

          // Update beneficiary's careUid and save caretaker details to local storage
          beneficiaryDatabaseService.beneficiaryDetailsUpdate(
              careTakerModel.memberUid.first, {'careUid': user.uid});

          careTakerLocalService.saveToGetStorage(careTakerModel.toJson());
          careTakerLocalService.retrieveFromGetStorage();
        } else {
          // If registering as a beneficiary
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
      // Show error message if registration fails
      loader.stop();
      Get.showSnackbar(GetSnackBar(
        duration: const Duration(seconds: 2),
        title: e.code,
        message: e.message,
      ));
      return LoginReturnModel(uid: "", responseValue: false);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      Get.showSnackbar(
        GetSnackBar(
          duration: const Duration(seconds: 2),
          title: "Password reset email sent to:",
          message: email,
        ),
      );
    } catch (e) {
      String errorMessage =
          "An error occurred while sending password reset email.";
      // You can provide more descriptive error messages based on the error type
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = "No user found with this email.";
            break;
          case 'invalid-email':
            errorMessage = "The email address is invalid.";
            break;
          default:
            errorMessage = "An error occurred: ${e.message}";
        }
      }
      Get.showSnackbar(
        GetSnackBar(
          duration: const Duration(seconds: 2),
          title: errorMessage,
          message: "---",
        ),
      );
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      // Fetch sign-in methods for the given email
      // ignore:
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      print(signInMethods);
      // If the list is not empty, email is already registered
      return signInMethods.isNotEmpty;
    } catch (e) {
      // Error occurred, handle accordingly
      print("Error checking email registration: $e");
      return false;
    }
  }
}
