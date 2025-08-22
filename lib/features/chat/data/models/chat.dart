import 'package:shifaa/features/chat/data/models/doctor_patient_chat_model.dart';
import 'package:shifaa/features/chat/data/models/message.dart';

// الكلاس الأب يبقى كما هو، لا حاجة لتعديله
class Chat {
  final int id;
  final DateTime createdAt;
  final List<Message> messages;
  final DoctorModel? doctor;
  final PatientModel? patient;

  Chat({
    required this.id,
    required this.createdAt,
    this.messages = const [],
    this.doctor,
    this.patient,
  });
}

// ✅✅✅ --- التعديلات تمت هنا --- ✅✅✅
class ChatModel extends Chat {
  ChatModel({
    required int id,
    required DateTime createdAt,
    List<Message> messages = const [],
    DoctorModel? doctor,
    PatientModel? patient,
  }) : super(
         id: id,
         createdAt: createdAt,
         messages: messages,
         doctor: doctor,
         patient: patient,
       );

  // تم تبسيط هذه الدالة لتكون أكثر مباشرة
  // في ملف chat.dart، داخل كلاس ChatModel

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // تحقق مما إذا كان الـ JSON يحتوي على مفتاح "chat"
    final chatData = json['chat'] ?? json;

    return ChatModel(
      id: chatData["id"] ?? 0,
      createdAt: chatData["created_at"] != null
          ? DateTime.parse(chatData["created_at"])
          : DateTime.now(),

      // ✅✅✅ --- هذا هو الإصلاح الحاسم --- ✅✅✅
      // 1. تحقق إذا كان مفتاح "messages" موجوداً وهو من نوع List
      messages: (chatData["messages"] != null && chatData["messages"] is List)
          // 2. إذا كان موجوداً، قم بتحليله
          ? (chatData["messages"] as List)
                .map((e) => MessageModel.fromJson(e))
                .toList()
          // 3. إذا لم يكن موجوداً، استخدم قائمة فارغة
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
