import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shifaa/core/api/end_ponits.dart';
import 'package:shifaa/features/chat/data/models/chat.dart';
import 'package:shifaa/features/chat/data/models/message.dart';

class ChatAlreadyExistsException implements Exception {
  final String message;
  ChatAlreadyExistsException([this.message = "Chat already exists"]);
}

class ChatRemoteDataSource {
  final Dio dio;
  ChatRemoteDataSource(this.dio);

  Future<Chat> createChat(int doctorId) async {
    final res = await dio.post(EndPoint.chat, data: {"doctor_id": doctorId});

    if (res.data["success"] == false) {
      final message = res.data["message"];

      if (message == "chat.already_exists") {
        // رجّع الشات الموجود من نفس الريسبونس
        return ChatModel.fromJson(res.data["data"]);
      }

      if (message == "chat.unauthorized") {
        throw UnauthorizedException("You must book an appointment first");
      }

      throw Exception("Unknown error: $message");
    }

    // المحادثة تم إنشاؤها للتو
    return ChatModel.fromJson(res.data["data"]);
  }

  Future<List<Message>> getMessages(int chatId) async {
    try {
      print("📤 Requesting messages...");
      print(
        "📤 Full URL: ${dio.options.baseUrl}${EndPoint.getMessages(chatId)}",
      );
      print("📤 Headers: ${dio.options.headers}");

      final res = await dio.get(EndPoint.getMessages(chatId));
      print('✅ getMessages response: ${res.data}');
      return (res.data["data"]["chat"]["messages"] as List)
          .map((e) => MessageModel.fromJson(e))
          .toList();
    } catch (e) {
      print('❌ getMessages ERROR: $e');
      rethrow;
    }
  }

  Future<Message> sendMessage(int chatId, {String? text, File? file}) async {
    final formData = FormData.fromMap({
      if (text != null) "text": text,
      if (file != null) "file": await MultipartFile.fromFile(file.path),
    });

    final res = await dio.post(EndPoint.sendMessage(chatId), data: formData);

    return MessageModel.fromJson(res.data["data"]);
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = "Unauthorized"]);
}
