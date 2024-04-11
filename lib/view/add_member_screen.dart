
import 'package:care_connect/view/member_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
      
      },
      child: Scaffold(
        appBar: const CustomAppbar(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.contact_emergency,
                    size: 22.w,
                    color: Colors.green,
                  ),
                  Icon(
                    Icons.add_circle_outline_outlined,
                    size: 22.w,
                  ),
                  Icon(
                    Icons.add_circle_outline_outlined,
                    size: 22.w,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
