class Message {
  final String text;
  final DateTime date;
  final bool isSentbyMe;

  const Message({
    required this.text,
    required this.date,
    required this.isSentbyMe,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        text: json['text'] as String,
        date: DateTime.parse(json['date'] as String),
        isSentbyMe: false,
      );

  // Map<String, dynamic> toJson() => {
  //       'text': text,
  //       'date': date.toIso8601String(),
  //       'isSentbyMe': isSentbyMe,
  //     };
}
