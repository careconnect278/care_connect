import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/view/activity_details.dart';
import 'package:care_connect/view/member_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';

import '../controller/implementation/text_field_controller.dart';

class AddMemberScreen extends StatelessWidget {
  final MemberManagementOnCareTaker managementOnCareTaker = Get.find();

  final TextFieldController textFieldController = Get.find();
  AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const CustomAppbar(
          isAppBar: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4.h,
              ),
              Text(
                'Add members',
                style: TextStyle(fontSize: 20.dp, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 4.h,
              ),
              Obx(
                () => ListView.builder(
                  shrinkWrap: true,
                  itemCount: managementOnCareTaker.members.length + 1,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (managementOnCareTaker.members.length >= index + 1) {
                      return GestureDetector(
                        onTap: () {
                          managementOnCareTaker.getInactivityDetails(
                              managementOnCareTaker.members[index].memberUid);

                          Get.to(() => ActivityDetailsScreen());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.contact_emergency,
                              size: 22.w,
                              color: Colors.green,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  managementOnCareTaker.members[index].name,
                                  style: TextStyle(
                                      fontSize: 13.dp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  managementOnCareTaker.members[index].age
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: 13.dp,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  managementOnCareTaker.members[index].email,
                                  style: TextStyle(
                                      fontSize: 13.dp,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                textFieldController.assignValuesForEdit(
                                    managementOnCareTaker.members[index]);
                                Get.to(() => MemberDetailsScreen(
                                    index: index,
                                    memberDetailsScreenState:
                                        MemberDetailsScreenState.editMember));
                              },
                              child: Icon(
                                Icons.edit,
                                size: 7.w,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                managementOnCareTaker.deleteBen(index);
                                // print(managementOnCareTaker.caretaker.value);
                              },
                              child: Icon(
                                Icons.delete,
                                size: 7.w,
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return GestureDetector(
                        onTap: () {
                          textFieldController.clear();
                          Get.to(() => MemberDetailsScreen(
                              memberDetailsScreenState:
                                  MemberDetailsScreenState.addMember));
                        },
                        child: Icon(
                          Icons.add_circle_outline_outlined,
                          size: 22.w,
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
