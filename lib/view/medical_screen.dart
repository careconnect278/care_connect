import 'package:care_connect/controller/implementation/member_mangement_caretaker_phone.dart';
import 'package:care_connect/view/beneficiary_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';

import '../controller/services/show_aleergies.dart';

class MedicalScreen extends StatelessWidget {
  MedicalScreen({super.key});

  final MemberManagementOnCareTaker managementOnCareTaker = Get.find();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Alert"),
                      content: const Text(
                          "Are you sure you want to close the Medical details screen?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Close"),
                          onPressed: () {
                            ShowAllergies showAllergies = ShowAllergies();
                            showAllergies.updateInGetStorage(false);
                            // Close the app
                            Get.to(() => BeneficiaryHomeScreen());
                            // You can also use SystemNavigator to close the app
                            // SystemNavigator.pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.arrow_back)),
        ),
        body: SafeArea(
          child: Obx(
            () => managementOnCareTaker.beneficiary.value == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Text(
                        "Allergies details",
                        style: TextStyle(
                            fontSize: 17.dp, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      DataTable(
                          columns: const [
                            DataColumn(
                              label: Text("Sl NO"),
                            ),
                            DataColumn(
                              label: Text("Allergies"),
                            ),
                          ],
                          rows: List.generate(
                              managementOnCareTaker
                                  .beneficiary.value!.alergies.length,
                              (index) => DataRow(cells: [
                                    DataCell(Text("${index + 1}")),
                                    DataCell(Text(managementOnCareTaker
                                        .beneficiary.value!.alergies[index]
                                        .toString())),
                                  ]))),
                      Text(
                        "Medication details",
                        style: TextStyle(
                            fontSize: 17.dp, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Center(
                        child: DataTable(
                            columns: const [
                              DataColumn(
                                label: Text("Sl NO"),
                              ),
                              DataColumn(
                                label: Text("Medication"),
                              ),
                              DataColumn(
                                label: Text("Time"),
                              ),
                            ],
                            rows: List.generate(
                                managementOnCareTaker
                                    .beneficiary.value!.medications.length,
                                (index) => DataRow(cells: [
                                      DataCell(Text("${index + 1}")),
                                      DataCell(Text(managementOnCareTaker
                                          .beneficiary
                                          .value!
                                          .medications[index]
                                          .name
                                          .toString())),
                                      DataCell(Text(managementOnCareTaker
                                          .beneficiary
                                          .value!
                                          .medications[index]
                                          .time
                                          .toString())),
                                    ]))),
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
