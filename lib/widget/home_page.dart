import 'package:flutter/material.dart';
import 'package:test_chat_with_socket/widget/chat_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatPage()));
        }, child: const Text('Chat')),
      ),
    );
  }
}