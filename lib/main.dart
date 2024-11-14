import 'package:flutter/material.dart';
import 'package:test_chat_with_socket/services/notification_service.dart';
import 'package:test_chat_with_socket/widget/home_page.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  NotificationService notificationService = NotificationService();
  await notificationService.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

