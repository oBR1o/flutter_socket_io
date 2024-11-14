import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // ตั้งค่า Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);

    // กำหนดการจัดการข้อความเมื่ออยู่ใน Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message.notification?.title, message.notification?.body);
    });

    // กำหนดการจัดการข้อความเมื่อแอปอยู่ใน Background แล้วถูกเปิดขึ้น
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked!");
      // เพิ่มการจัดการเมื่อผู้ใช้กดที่การแจ้งเตือน
    });

    // ตั้งค่ารับ Token ของอุปกรณ์
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
    });
  }

  // ฟังก์ชันแสดงการแจ้งเตือนแบบ Local
  Future<void> showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'chat_channel_id',  // ระบุ channel ID สำหรับ Android
      'Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      0,         // Notification ID
      title,     // หัวข้อของการแจ้งเตือน
      body,      // เนื้อหาของการแจ้งเตือน
      platformChannelSpecifics,
    );
  }
}

