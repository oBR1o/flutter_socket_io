import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:test_chat_with_socket/model/message.dart';
import 'package:test_chat_with_socket/services/socket_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late SocketService socketService;
  final TextEditingController _textController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    socketService = SocketService(onMessageReceived: _handleNewMessage);
  }

  @override
  void dispose() {
    socketService.dispose();
    super.dispose();
  }

  void _handleNewMessage(Message message) {
    setState(() {
      messages.add(message);
      messages.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    });
  }

  void sendMessage() {
  if (_textController.text.isNotEmpty) {
    final message = Message(
      text: _textController.text,
      date: DateTime.now(),
      isSentbyMe: true,
    );
    socketService.sendMessage(_textController.text);

    setState(() {
      messages.add(message);
      messages.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    });
    _textController.clear();
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
              child: GroupedListView<Message, DateTime>(
            padding: const EdgeInsets.all(12),
            // reverse: true,
            order: GroupedListOrder.DESC,
            elements: messages,
            groupBy: (message) => DateTime(
              message.date.year,
              message.date.month,
              message.date.day,
            ),
            groupHeaderBuilder: (Message message) => SizedBox(
              height: 40,
              child: Center(
                child: Card(
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        DateFormat.yMMMd().format(message.date),
                        style: const TextStyle(color: Colors.white),
                      ),
                    )),
              ),
            ),
            itemBuilder: (context, Message message) => Align(
              alignment: message.isSentbyMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: message.isSentbyMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(message.text),
                    ),
                  ),
                  Text('${message.date.hour}:${message.date.minute}'),
                ],
              ),
            ),
          )),
          Container(
            color: Colors.grey.shade300,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(12),
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
