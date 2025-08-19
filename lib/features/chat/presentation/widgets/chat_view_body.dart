// ⭐️ لا تنسى إضافة هذا الاستيراد في الأعلى
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart'; // ⭐️ استيراد مهم للملفات المؤقتة
// ⭐️ ---

import 'dart:convert';
import 'package:flutter/material.dart' hide Key;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_colors.dart';
import 'package:shifaa/core/utils/functions/e2ee_service.dart';
import 'package:shifaa/core/utils/shared_prefs_helper.dart';
import 'package:shifaa/features/chat/data/models/chat.dart';
import 'package:shifaa/features/chat/data/models/message.dart';
import 'package:shifaa/features/chat/data/models/message_status.dart'; // ⭐️ استيراد مهم للحالات
import 'package:shifaa/features/chat/data/pusher/chat_pusher_service.dart';
import 'package:shifaa/features/chat/data/repositories/device_cache_repo.dart';
import 'package:shifaa/features/chat/domain/repositories/chat_repo.dart';
import 'package:shifaa/features/chat/presentation/cubits/get_messages_cubit/get_messages_cubit.dart';
import 'package:shifaa/features/chat/presentation/widgets/chat_message.dart';
import 'package:shifaa/features/chat/presentation/widgets/chat_message2.dart';
import 'package:shifaa/features/chat/presentation/widgets/custom_chat_app_bar.dart';

// ---------------- ChatViewBody ----------------
class ChatViewBody extends StatefulWidget {
  final Chat chat;
  const ChatViewBody({super.key, required this.chat});

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  final ChatPusherService _pusherService = ChatPusherService();
  late TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchMessages();
      _scrollToBottom();
      _initPusher();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    await context.read<GetMessagesCubit>().fetchMessages(widget.chat.id);
  }

  void _initPusher() async {
    final getMessagesCubit = context.read<GetMessagesCubit>();
    await _pusherService.initPusher(
      widget.chat.id,
      onMessageReceived: (event) {
        final data = jsonDecode(event.data ?? '{}');
        final msgData = data['message'] ?? {};
        final msg = MessageModel.fromJson(msgData);
        getMessagesCubit.addMessage(msg);
        _scrollToBottom();
      },
    );
  }

  Future<void> _pickAndSendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      _sendMessage(file: file); // استدعاء الدالة العامة
    }
  }

  // ✅✅✅ --- دالة الإرسال الجديدة والذكية --- ✅✅✅
  void _sendMessage({String? text, File? file, Message? messageToRetry}) async {
    final messagesCubit = context.read<GetMessagesCubit>();
    final repo = context.read<ChatRepository>();

    // --- الخطوة 1: إنشاء الرسالة المؤقتة ---
    final Message tempMessage;
    final tempId =
        messageToRetry?.id ?? DateTime.now().millisecondsSinceEpoch * -1;

    if (messageToRetry != null) {
      tempMessage = messageToRetry;
      messagesCubit.updateMessageStatus(tempId, MessageStatus.sending);
    } else {
      final myUser = await SharedPrefsHelper.instance.getUserModel();
      tempMessage = Message(
        id: tempId,
        text: text,
        file: file?.path,
        localFilePath: file?.path,
        senderRole: 'patient',
        senderId: myUser.id,
        createdAt: DateTime.now(),
        status: MessageStatus.sending,
      );
      messagesCubit.addMessage(tempMessage);
      _messageController.clear();
      _scrollToBottom();
    }

    // --- الخطوة 2: تحضير البيانات للإرسال ---
    try {
      final aesKey = E2EE.generateAESKey();
      String? encryptedText;
      File? encryptedFile;

      if (tempMessage.text != null && tempMessage.text!.isNotEmpty) {
        encryptedText = E2EE.aesGcmEncryptToBase64(aesKey, tempMessage.text!);
      } else if (tempMessage.localFilePath != null) {
        // 1. اقرأ الملف كبايتات
        final fileBytes = await File(tempMessage.localFilePath!).readAsBytes();

        // ✅✅✅ --- الإصلاح هنا: استخدام الدالة الصحيحة --- ✅✅✅
        final encryptedBytes = E2EE.aesGcmEncryptToBytes(aesKey, fileBytes);

        // 3. احفظ البايتات المشفرة في ملف مؤقت لإرساله
        final tempDir = await getTemporaryDirectory();
        final fileName = tempMessage.localFilePath!.split('/').last;
        encryptedFile = await File(
          '${tempDir.path}/$fileName.enc',
        ).writeAsBytes(encryptedBytes);
      }

      final targets = await DeviceCacheRepo.getTargetsForSending(
        doctorUserId: widget.chat.doctor!.id,
        myUserId: tempMessage.senderId,
        myDeviceId: await SharedPrefsHelper.instance.getMyDeviceId(),
      );

      final encryptedKeysPayload = E2EE.buildEncryptedKeysPayload(
        targets: targets,
        aesKey: aesKey,
      );

      // --- الخطوة 3: إرسال الطلب ---
      final result = await repo.sendMessage(
        widget.chat.id,
        text: encryptedText,
        file: encryptedFile,
        encryptedKeysPayload: encryptedKeysPayload,
      );

      // --- الخطوة 4: معالجة النتيجة ---
      result.fold(
        (failure) {
          print("❌ Failed to send message: ${failure.message}");
          messagesCubit.updateMessageStatus(tempId, MessageStatus.failed);
        },
        (sentMessage) {
          print(
            "✅ Message request sent successfully. Waiting for Pusher to confirm.",
          );
          // لا نفعل شيئاً هنا، ننتظر رسالة Pusher لتأكيد التسليم
        },
      );
    } catch (e) {
      print("❌ Exception while sending message: $e");
      messagesCubit.updateMessageStatus(tempId, MessageStatus.failed);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.hasContentDimensions) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // غيرت الـ AppBar ليكون متوافقاً مع التصميم
      body: Column(
        children: [
          const CustomChatAppBar(),
          Expanded(
            child: BlocBuilder<GetMessagesCubit, GetMessagesState>(
              builder: (context, state) {
                if (state is GetMessagesSuccess) {
                  // ✅✅✅ --- تم إصلاح الخطأ هنا --- ✅✅✅
                  final displayMessages = state.messages;
                  if (displayMessages.isEmpty) {
                    return const Center(
                      child: Text("No messages yet. Start the conversation!"),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    itemCount: displayMessages.length,
                    itemBuilder: (context, index) {
                      final msg = displayMessages[index];
                      return ChatMessage(
                        message: msg,
                        onRetry: () {
                          // ✅✅✅ --- تم إصلاح الخطأ هنا --- ✅✅✅
                          _sendMessage(messageToRetry: msg);
                        },
                      );
                    },
                  );
                } else if (state is GetMessagesFailure) {
                  return Center(child: Text(state.error));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          buildMessageComposer(
            messageController: _messageController,
            onSendPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(text: _messageController.text.trim());
              }
            },
            onAttachmentPressed: _pickAndSendFile,
          ),
        ],
      ),
    );
  }
}

// هذا الوجت يبقى كما هو
Widget buildMessageComposer({
  required TextEditingController messageController,
  required VoidCallback onSendPressed,
  required VoidCallback onAttachmentPressed,
}) {
  // ... الكود هنا لا يتغير
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              filled: true,
              fillColor: const Color(0xFFF0F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  icon: Icon(Icons.attachment, color: Colors.grey, size: 24.w),
                  onPressed: onAttachmentPressed,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        FloatingActionButton(
          elevation: 2,
          onPressed: onSendPressed,
          backgroundColor: AppColors.primaryAppColor,
          shape: const CircleBorder(),
          child: Icon(Icons.send, color: Colors.white, size: 24.w),
        ),
      ],
    ),
  );
}
