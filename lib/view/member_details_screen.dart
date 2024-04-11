import 'package:care_connect/controller/implementation/text_field_controller.dart';
import 'package:care_connect/controller/services/authentication_service.dart';
import 'package:care_connect/controller/services/caretaker/notification_service.dart';
import 'package:care_connect/model/beneficiary_model.dart';
import 'package:care_connect/model/care_taker_model.dart';
import 'package:care_connect/model/login_return_model.dart';
import 'package:care_connect/model/medication_model.dart';
import 'package:care_connect/model/pill_field_model.dart';
import 'package:care_connect/view/add_member_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';

class MemberDetailsScreen extends StatelessWidget {
  final bool isRegister;

  MemberDetailsScreen({super.key, required this.isRegister});
  final TextFieldController textFieldController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4.h,
              ),
              Text(
                isRegister ? "Care taker details" : 'Member details',
                style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 4.h,
              ),
              if (isRegister) ...{
                CustomTextField(
                  label: "Email",
                  textEditingController:
                      textFieldController.caretakerEmailController,
                ),
                SizedBox(
                  height: 2.h,
                ),
                CustomTextField(
                  label: "Password",
                  textEditingController:
                      textFieldController.caretakerPasswordController,
                ),
                SizedBox(
                  height: 2.h,
                ),
                CustomTextField(
                  label: "Name",
                  textEditingController:
                      textFieldController.caretakerNameController,
                ),
                SizedBox(
                  height: 2.h,
                ),
                CustomTextField(
                  label: "Phone Number",
                  textEditingController:
                      textFieldController.caretakerPhoneNumberController,
                ),
                SizedBox(
                  height: 2.h,
                ),
                Text(
                  'member details',
                  style:
                      TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 2.h,
                ),
                CustomTextField(
                  label: "Email",
                  textEditingController:
                      textFieldController.beneficiaryEmailController,
                ),
                SizedBox(
                  height: 2.h,
                ),
                CustomTextField(
                  label: "Password",
                  textEditingController:
                      textFieldController.beneficiaryPasswordController,
                ),
              },
              CustomTextField(
                label: "Name",
                textEditingController:
                    textFieldController.beneficiaryNameController,
              ),
              SizedBox(
                height: 2.h,
              ),
              CustomTextField(
                label: "Age",
                textEditingController:
                    textFieldController.beneficiaryageController,
              ),
              SizedBox(
                height: 2.h,
              ),
              CustomTextField(
                label: "Time to Alert",
                textEditingController: textFieldController.alertTimeController,
                readOnly: true,
                onTap: () async {
                  Future<TimeOfDay?> selectedTime24Hour = showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 10, minute: 47),
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  TimeOfDay? time = await selectedTime24Hour;
                  textFieldController.alertTimeController.text =
                      "${time!.hour}:${time.minute}";
                },
              ),
              SizedBox(
                height: 2.h,
              ),
              Obx(
                () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index + 1 ==
                          textFieldController
                              .emergencyNumberControlllers.length) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100.w > 400 ? 70.w : 60.w,
                              child: CustomTextField(
                                  isList: true,
                                  label: "Emergency number ${index + 1}",
                                  textEditingController: textFieldController
                                      .emergencyNumberControlllers[index]),
                            ),
                            GestureDetector(
                              onTap: () {
                                textFieldController.emergencyNumberControlllers
                                    .add(TextEditingController());
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.green.shade200,
                                radius: 20.dp,
                                child: const Icon(
                                  Icons.add,
                                ),
                              ),
                            )
                          ],
                        );
                      } else {
                        return CustomTextField(
                            isList: true,
                            label: "Emergency number ${index + 1}",
                            textEditingController: textFieldController
                                .emergencyNumberControlllers[index]);
                      }
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 2.h,
                      );
                    },
                    itemCount:
                        textFieldController.emergencyNumberControlllers.length),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                'Allergies details',
                style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 2.h,
              ),
              Obx(
                () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index + 1 ==
                          textFieldController.allergiesControlllers.length) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 100.w > 400 ? 70.w : 60.w,
                              child: CustomTextField(
                                  isList: true,
                                  label: "Allergies ${index + 1}",
                                  textEditingController: textFieldController
                                      .allergiesControlllers[index]),
                            ),
                            GestureDetector(
                              onTap: () {
                                textFieldController.allergiesControlllers
                                    .add(TextEditingController());
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.green.shade200,
                                radius: 20.dp,
                                child: const Icon(
                                  Icons.add,
                                ),
                              ),
                            )
                          ],
                        );
                      } else {
                        return CustomTextField(
                            isList: true,
                            label: "Allergies ${index + 1}",
                            textEditingController: textFieldController
                                .allergiesControlllers[index]);
                      }
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 2.h,
                      );
                    },
                    itemCount:
                        textFieldController.allergiesControlllers.length),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                'Medication & pills details',
                style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 2.h,
              ),
              Obx(
                () => ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index + 1 ==
                          textFieldController.medicationControlllers.length) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 40.w,
                                  child: CustomTextField(
                                      isList: true,
                                      label: "Name",
                                      textEditingController: textFieldController
                                          .medicationControlllers[index]
                                          .nameController),
                                ),
                                SizedBox(
                                  width: 40.w,
                                  child: CustomTextField(
                                      isList: true,
                                      onTap: () async {
                                        TimeOfDay? selectedTime =
                                            await showTimePicker(
                                          initialTime: TimeOfDay.now(),
                                          context: context,
                                        );
                                        if (!context.mounted) return;
                                        textFieldController
                                                .medicationControlllers[index]
                                                .timeController
                                                .text =
                                            selectedTime!.format(context);
                                      },
                                      readOnly: true,
                                      label: "Time",
                                      textEditingController: textFieldController
                                          .medicationControlllers[index]
                                          .timeController),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            GestureDetector(
                              onTap: () {
                                textFieldController.medicationControlllers
                                    .add(MedicationModel());
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.green.shade200,
                                radius: 20.dp,
                                child: const Icon(
                                  Icons.add,
                                ),
                              ),
                            )
                          ],
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 40.w,
                              child: CustomTextField(
                                  isList: true,
                                  label: "Name",
                                  textEditingController: textFieldController
                                      .medicationControlllers[index]
                                      .nameController),
                            ),
                            SizedBox(
                              width: 40.w,
                              child: CustomTextField(
                                  isList: true,
                                  onTap: () async {
                                    TimeOfDay? selectedTime =
                                        await showTimePicker(
                                      initialTime: TimeOfDay.now(),
                                      context: context,
                                    );
                                    if (!context.mounted) return;
                                    textFieldController
                                        .medicationControlllers[index]
                                        .timeController
                                        .text = selectedTime!.format(context);
                                  },
                                  readOnly: true,
                                  label: "Time",
                                  textEditingController: textFieldController
                                      .medicationControlllers[index]
                                      .timeController),
                            ),
                          ],
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        height: 2.h,
                      );
                    },
                    itemCount:
                        textFieldController.medicationControlllers.length),
              ),
              SizedBox(
                height: 2.h,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen.shade300,
                    minimumSize: Size(
                      20.w,
                      6.h,
                    ),
                  ),
                  onPressed: () async {
                    NotificationServices notificationServices =
                        NotificationServices();
                    AuthentincationServices authentincationServices =
                        AuthentincationServices();
                    String token = await notificationServices.getToken();
                    BenefiiciaryModel benefiiciaryModel = BenefiiciaryModel(
                        benToken: "",
                        careToken: token,
                        name:
                            textFieldController.beneficiaryNameController.text,
                        age: int.parse(
                            textFieldController.beneficiaryageController.text),
                        email:
                            textFieldController.beneficiaryEmailController.text,
                        careUid: "",
                        memberUid: "",
                        timeToAlert:
                            textFieldController.alertTimeController.text,
                        medications: textFieldController.medicationControlllers
                            .where((allergy) =>
                                allergy.nameController.text.isNotEmpty)
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
                        emergencynumbers: textFieldController
                            .emergencyNumberControlllers
                            .where((emergency) => emergency.text.isNotEmpty)
                            .toList()
                            .map((e) => e.text)
                            .toList());
                    LoginReturnModel loginReturnModel =
                        await authentincationServices.registeruser(
                            benefiiciaryModel.email,
                            textFieldController
                                .beneficiaryPasswordController.text,
                            false,
                            null,
                            benefiiciaryModel);

                    CareTakerModel careTakerModel = CareTakerModel(
                        name: textFieldController.caretakerNameController.text,
                        phoneNumber: textFieldController
                            .caretakerPhoneNumberController.text,
                        email:
                            textFieldController.caretakerEmailController.text,
                        careToken: token,
                        careUid: "",
                        memberUid: [loginReturnModel.uid]);
                    authentincationServices
                        .registeruser(
                            careTakerModel.email,
                            textFieldController
                                .caretakerPasswordController.text,
                            true,
                            careTakerModel,
                            null)
                        .then((value) {
                      if (value.responseValue) {
                        Get.to(() => const AddMemberScreen());
                      }
                    });
                  },
                  child: const Text(
                    'Register',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w700),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String label;
  final bool? readOnly;
  final Function()? onTap;
  final bool? isList;
  const CustomTextField(
      {super.key,
      required this.label,
      required this.textEditingController,
      this.readOnly,
      this.onTap,
      this.isList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 15.dp, fontWeight: FontWeight.w800),
        ),
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: SizedBox(
            height: 6.h,
            child: TextFormField(
              onTap: onTap,
              validator: (value) {
                if (value!.isEmpty && isList == null) {
                  return "Field is Empty";
                } else {
                  return null;
                }
              },
              readOnly: readOnly ?? false,
              controller: textEditingController,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 5, left: 5),
                  filled: true,
                  fillColor: Colors.green.shade200),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
  });
  @override
  Size get preferredSize => Size.fromHeight(9.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      leadingWidth: 32.dp,
      leading: Padding(
        padding: EdgeInsets.only(left: 2.w),
        child: Icon(
          Icons.person_pin,
          size: 32.dp,
        ),
      ),
      actions: [
        Icon(
          Icons.settings,
          size: 32.dp,
        ),
        SizedBox(
          width: 2.w,
        )
      ],
    );
  }
}
