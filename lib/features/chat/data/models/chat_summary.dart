// file: lib/features/chat/data/models/chat_summary.dart

// موديل بسيط لمعلومات الطرف الآخر في المحادثة (في حالتك، الطبيب)
import 'package:shifaa/features/book_appointments/data/models/doctor_model.dart';
import 'package:shifaa/features/chat/data/models/message.dart';

class ChatParticipant {
  final int id;
  final String firstName;
  final String lastName;
  final String avatar;

  ChatParticipant({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  // دالة مساعدة للحصول على الاسم الكامل بسهولة
  String get fullName => '$firstName $lastName';

  // Factory constructor لتحويل الـ JSON إلى هذا الموديل
  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      avatar: json['avatar'] ?? '', // رابط الصورة
    );
  }
}

// موديل بسيط لآخر رسالة في المحادثة
class LastMessage {
  final String text;
  final DateTime createdAt;

  LastMessage({required this.text, required this.createdAt});

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      // ملاحظة: النص هنا قد يكون مشفراً. حالياً سنأخذه كما هو.
      text: json['text'] ?? 'No messages yet',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// الموديل الرئيسي الذي يمثل كل عنصر في قائمة المحادثات
class ChatSummary {
  final int id;
  // ✅ 1. حدد النوع الصحيح هنا (افترضت أنه Doctor)
  final DoctorModel doctor;
  // ✅ 2. حدد النوع الصحيح هنا
  final Message? lastMessage;
  final int unreadCount;

  ChatSummary({
    required this.id,
    required this.doctor,
    this.lastMessage,
    required this.unreadCount,
  });

  // ✅ 3. تأكد من أن دالة fromJson تستخدم الأنواع الصحيحة أيضاً
  factory ChatSummary.fromJson(Map<String, dynamic> json) {
    return ChatSummary(
      id: json['id'],
      // تأكد من أنك تستدعي fromJson للكلاس الصحيح
      doctor: DoctorModel.fromJson(json['doctor']),
      // تحقق إذا كانت الرسالة موجودة قبل تحليلها
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  // ✅ 4. الآن دالة copyWith ستعمل بشكل صحيح لأن الأنواع متطابقة
  ChatSummary copyWith({
    int? id,
    DoctorModel? doctor, // <-- النوع الصحيح
    Message? lastMessage, // <-- النوع الصحيح
    int? unreadCount,
  }) {
    return ChatSummary(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
