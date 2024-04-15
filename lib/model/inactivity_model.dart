import 'package:intl/intl.dart';

class InactivityDetailsModel {
  String lastLockedTime;
  String lastInactivityHours;
  String lastUnlockedTime;

  InactivityDetailsModel({
    required this.lastLockedTime,
    required this.lastInactivityHours,
    required this.lastUnlockedTime,
  });

  factory InactivityDetailsModel.fromJson(Map<String, dynamic> json) {
    return InactivityDetailsModel(
      lastLockedTime: json['lastlockedtime'].toString().isNotEmpty
          ? formatDateTime(DateTime.parse(json['lastlockedtime']))
          : "",
      lastInactivityHours: json['lastInactivityhours'].toString().isNotEmpty
          ? formatSeconds(json['lastInactivityhours'])
          : "",
      lastUnlockedTime: json['lastunlockedtime'].toString().isNotEmpty
          ? formatDateTime(DateTime.parse(json['lastunlockedtime']))
          : "",
    );
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd-MM/yyyy hh:mm:ss').format(dateTime);
  }

  static String formatSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$hours:$minutes:$remainingSeconds';
  }
}
