import 'package:shifaa/features/chat/data/models/message.dart';

class Chat {
  final int id;
  final DateTime createdAt;
  final List<Message> messages;

  Chat({required this.id, required this.createdAt, required this.messages});
}

class ChatModel extends Chat {
  ChatModel({
    required int id,
    required DateTime createdAt,
    required List<Message> messages,
  }) : super(id: id, createdAt: createdAt, messages: messages);

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json["id"],
      createdAt: DateTime.parse(json["created_at"]),
      messages: (json["messages"] as List<dynamic>)
          .map((e) => MessageModel.fromJson(e))
          .toList(),
    );
  }
}
