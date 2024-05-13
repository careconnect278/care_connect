// ignore_for_file: avoid_print

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> periodicAlarms(String tabName, TimeOfDay time, int paramId) async {
  const nbDays = 7; // Number of following days to potentially set alarm
  // Days of the week to set the alarm

  final now = DateTime.now();

  // Loop through the next days
  for (var i = 0; i < nbDays; i++) {
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(Duration(days: i));
    int id = int.parse("${paramId + 1}${dateTime.day}");
    if (kDebugMode) {
      print(id);
    }
    print(time);
    print(tabName);
    if (dateTime.isAfter(DateTime.now())) {
      final alarmSettings = AlarmSettings(
        loopAudio: false,
        id: id,
        dateTime: dateTime,
        assetAudioPath: 'assets/alrm.wav',
        notificationTitle: 'Its Time To take $tabName',
        notificationBody: 'Medication Time.',
      );
      await Alarm.set(
        alarmSettings: alarmSettings,
      );
    }
  }
}

Future<void> checkAndroidScheduleExactAlarmPermission() async {
  final status = await Permission.scheduleExactAlarm.status;
  print('Schedule exact alarm permission: $status.');
  if (status.isDenied) {
    print('Requesting schedule exact alarm permission...');
    final res = await Permission.scheduleExactAlarm.request();
    print(
        'Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted.');
  }
}
