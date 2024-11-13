import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:grouped_list/grouped_list.dart';
import 'package:test_chat_with_socket/model/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  socket_io.Socket? socket;

  final TextEditingController _textController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();

    socket = socket_io.io(
      'http://192.168.1.177:3000',
      socket_io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    setupListteners();
  }

  @override
  void dispose() {
    socket?.close();
    super.dispose();
  }

  void setupListteners() {
    socket?.on('connect', (_) {
      Logger().i('Connected');
      print('Socket Connected'); // Additional debug print
    });

    socket?.on('disconnect', (_) {
      Logger().e('Disconnected');
      print('Socket Disconnected'); // Additional debug print
    });

    socket?.on('connect_error', (data) {
      Logger().e('Connect Error: $data');
      print('Socket Connection Error: $data'); // Additional debug print
    });

    // socket?.on(
    //   'message',
    //   (data) =>
    //       setState(() => messages = [Message.fromJson(data), ...messages]),
    // );

    socket?.on('broadcastMessage', (data) => reciveMessage(data));
  }

  void sendMessage() {
  if (_textController.text.isNotEmpty) {
    final message = Message(
      text: _textController.text,
      date: DateTime.now(),
      isSentbyMe: true,
    );

    final messageData = {
      'text': message.text,
      // 'date': message.date.toIso8601String(),
      // 'isSentbyMe': message.isSentbyMe,
    };

    print('Sending message data: $messageData');
    socket?.emit('sendMessage', messageData);

    setState(() {
      messages.add(message);
      messages.sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
    });
    _textController.clear();
  }
}

void reciveMessage(dynamic data) {
  print('Received message data: $data');

  String messageText;
  if (data is String) {
    if (data.contains('Server received your message: ')) {
      messageText = data.replaceAll('Server received your message: ', '');
    } else if (data.contains('New message from Mobile: ')) {
      messageText = data.replaceAll('New message from Mobile: ', '');
    } else if (data.contains('New message from Website: ')) {
      messageText = data.replaceAll('New message from Website: ', '');
    }else {
      messageText = data;
    }
  } else if (data is Map) {
    messageText = data['text'] ?? '';
  } else {
    messageText = data.toString();
  }

  // if (data is Map) {
  //   // Handle object format
  //   messageText = data['text'] ?? 'Empty message';
  // } else {
  //   // Handle string format
  //   messageText = data.toString();
  // }

  final receivedMessage = Message(
    text: messageText,
    date: DateTime.now(),
    isSentbyMe: false,
  );

  setState(() {
    messages = [receivedMessage, ...messages];
    messages.sort((a, b) => b.date.compareTo(a.date));
  });
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
