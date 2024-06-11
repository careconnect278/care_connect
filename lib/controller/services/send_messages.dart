// import 'package:firebase_admin/firebase_admin.dart';
// import 'package:firebase_admin/src/messaging/messaging.dart';
// import 'package:firebase_admin/src/messaging/message.dart';

// Future<bool> sendNotification(String title, String body, String to,
//     Map<String, dynamic> data, String para, bool isCaretaker) async {
//   debugPrint(para);
//   try {
//     final messaging = FirebaseAdmin.instance.messaging();
//     final message = Message(
//       token: to.trim(),
//       notification: Notification(
//         title: title,
//         body: body,
//       ),
//       data: data,
//     );

//     if (isCaretaker) {
//       final response = await messaging.send(message);
//       debugPrint('Notification sent: $response');
//       return true;
//     } else {
//       if (isReponded) {
//         return false;
//       } else {
//         final response = await messaging.send(message);
//         debugPrint('Notification sent: $response');
//         isReponded = true;
//         return true;
//       }
//     }
//   } catch (e) {
//     debugPrint('Error sending notification: $e');
//     return false;
//   }
// }
