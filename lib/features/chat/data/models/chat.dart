import 'package:shifaa/features/chat/data/models/doctor_patient_chat_model.dart';
import 'package:shifaa/features/chat/data/models/message.dart';

// الكلاس الأب يبقى كما هو، لا حاجة لتعديله
// في ملف chat.dart
class Chat {
  final int id;
  final bool muted; // <--- ✅ أضف هذا السطر
  final DateTime createdAt;
  final List<Message> messages;
  final DoctorModel? doctor;
  final PatientModel? patient;

  Chat({
    required this.id,
    required this.muted, // <--- ✅ أضف هذا السطر
    required this.createdAt,
    this.messages = const [],
    this.doctor,
    this.patient,
  });
}

// ✅✅✅ --- التعديلات تمت هنا --- ✅✅✅
// في ملف chat.dart، داخل كلاس ChatModel
class ChatModel extends Chat {
  ChatModel({
    required int id,
    required bool muted, // <--- ✅ أضف هذا السطر
    required DateTime createdAt,
    List<Message> messages = const [],
    DoctorModel? doctor,
    PatientModel? patient,
  }) : super(
         id: id,
         muted: muted, // <--- ✅ أضف هذا السطر
         createdAt: createdAt,
         messages: messages,
         doctor: doctor,
         patient: patient,
       );

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    final chatData = json['chat'] ?? json;

    return ChatModel(
      id: chatData["id"] ?? 0,
      muted:
          chatData["muted"] ??
          false, // <--- ✅ أضف هذا السطر (مع قيمة افتراضية false)
      createdAt: chatData["created_at"] != null
          ? DateTime.parse(chatData["created_at"])
          : DateTime.now(),
      messages: (chatData["messages"] != null && chatData["messages"] is List)
          ? (chatData["messages"] as List)
                .map((e) => MessageModel.fromJson(e))
                .toList()
          : [],
      doctor: chatData["doctor"] != null
          ? DoctorModel.fromJson(chatData["doctor"])
          : null,
      patient: chatData["patient"] != null
          ? PatientModel.fromJson(chatData["patient"])
          : null,
    );
  }
}
