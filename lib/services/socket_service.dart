import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:test_chat_with_socket/model/message.dart';
import 'package:test_chat_with_socket/services/notification_service.dart';

class SocketService {
  socket_io.Socket? socket;
  final void Function(Message) onMessageReceived;

  SocketService({required this.onMessageReceived}) {
    initSocket();
  }

  void initSocket() {
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
    socket?.on('broadcastMessage', (data) => handleReceivedMessage(data));
    // socket?.on('notification', (data) => handleReceivedNotification(data));
    socket?.on('notification', (data) {
    print('========= Notification Debug =========');
    print('Raw notification event received');
    print('Event data type: ${data.runtimeType}');
    print('Event data content: $data');
    
    handleReceivedNotification(data);
    
    print('Notification handling completed');
    print('===================================');
  });
  }

  void sendMessage(String text) {
    final messageData = {
      'text': text,
      // 'date': message.date.toIso8601String(),
      // 'isSentbyMe': message.isSentbyMe,
    };
    print('Sending message data: $messageData');
    socket?.emit('sendMessage', messageData);
  }

  void handleReceivedMessage(dynamic data) {
    print('Received message data: $data');
    String messageText;
    if (data is String) {
      if (data.contains('Server received your message: ')) {
        messageText = data.replaceAll('Server received your message: ', '');
      } else if (data.contains('New message from Mobile: ')) {
        messageText = data.replaceAll('New message from Mobile: ', '');
      } else if (data.contains('New message from Website: ')) {
        messageText = data.replaceAll('New message from Website: ', '');
      } else {
        messageText = data;
      }
    } else if (data is Map) {
      messageText = data['text'] ?? '';
    } else {
      messageText = data.toString();
    }

    final receivedMessage = Message(
      text: messageText,
      date: DateTime.now(),
      isSentbyMe: false,
    );

    onMessageReceived(receivedMessage);
  }

  void handleReceivedNotification(dynamic data) {
     print('Data received in handleReceivedNotification: $data');
    // ตรวจสอบว่า data มีข้อมูลที่ต้องการหรือไม่
    String? title = data['title']; 
    String? message = data['message'];
    if (title != null && message != null) {
      // เรียกใช้ NotificationService เพื่อแสดงการแจ้งเตือน
      NotificationService().showNotification(title, message);
    } else {
      print('Data format is incorrect or missing required fields');
    }
  }
  void dispose(){
    socket?.close();
  }
}
