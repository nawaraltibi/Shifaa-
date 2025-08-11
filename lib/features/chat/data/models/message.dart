class Message {
  final int id;
  final String? text;
  final String? file;
  final String senderRole;
  final int senderId;
  final DateTime createdAt;

  Message({
    required this.id,
    this.text,
    this.file,
    required this.senderRole,
    required this.senderId,
    required this.createdAt,
  });
}

class MessageModel extends Message {
  MessageModel({
    required int id,
    String? text,
    String? file,
    required String senderRole,
    required int senderId,
    required DateTime createdAt,
  }) : super(
         id: id,
         text: text,
         file: file,
         senderRole: senderRole,
         senderId: senderId,
         createdAt: createdAt,
       );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json["id"],
      text: json["text"],
      file: json["file"],
      senderRole: json["sender_role"],
      senderId: json["sender_id"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
