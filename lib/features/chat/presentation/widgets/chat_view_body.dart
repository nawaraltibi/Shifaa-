// imports نفسها بدون تغيير
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_colors.dart';
import 'package:shifaa/core/utils/app_images.dart';
import 'package:shifaa/features/chat/data/models/message.dart';
import 'package:shifaa/features/chat/data/pusher/chat_pusher_service.dart';
import 'package:shifaa/features/chat/domain/repositories/chat_repo.dart';
import 'package:shifaa/features/chat/presentation/cubits/get_messages_cubit/get_messages_cubit.dart';
import 'package:shifaa/features/chat/presentation/widgets/chat_message.dart';
import 'package:shifaa/features/chat/presentation/widgets/custom_chat_app_bar.dart';

class ChatViewBody extends StatefulWidget {
  final int chatId;

  const ChatViewBody({super.key, required this.chatId});

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  final ChatPusherService _pusherService = ChatPusherService();
  late TextEditingController _messageController;
  bool _messagesFetched = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _initPusher();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_messagesFetched) {
        _fetchMessages();
        _messagesFetched = true;
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _fetchMessages() async {
    context.read<GetMessagesCubit>().fetchMessages(widget.chatId);
  }

  void _initPusher() async {
    final getMessagesCubit = context.read<GetMessagesCubit>();
    await _pusherService.initPusher(
      widget.chatId,
      onMessageReceived: (event) {
        final data = jsonDecode(event.data ?? '{}');
        final msgData = data['message'];
        final msg = MessageModel.fromJson(msgData);
        getMessagesCubit.addMessage(msg);
      },
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final repo = context.read<ChatRepository>();
    final result = await repo.sendMessage(widget.chatId, text: text);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${failure.message}")));
      },
      (_) {
        // لا داعي لإضافة الرسالة محليًا، Pusher سيقوم بتحديث UI
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomChatAppBar(),
          SizedBox(height: 20.h),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Divider(color: Color(0xFFE3E9F1), thickness: 2),
          ),
          SizedBox(height: 25.h),
          Expanded(
            child: BlocBuilder<GetMessagesCubit, GetMessagesState>(
              builder: (context, state) {
                if (state is GetMessagesSuccess) {
                  final displayMessages = state.messages;
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: displayMessages.length,
                    itemBuilder: (context, index) {
                      final msg = displayMessages[index];
                      final isMe = msg.senderRole == 'patient';
                      return ChatMessage(
                        isMe: isMe,
                        text: msg.text ?? '',
                        profileImage: isMe ? null : AppImages.imagesDoctor1,
                      );
                    },
                  );
                } else if (state is GetMessagesFailure) {
                  return Center(child: Text(state.error));
                } else if (state is GetMessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox();
              },
            ),
          ),
          buildMessageComposer(_messageController, _sendMessage),
        ],
      ),
    );
  }
}

// الكود المتبقي لـ buildMessageComposer لم يتم تعديله
Widget buildMessageComposer(
  TextEditingController messageController,
  VoidCallback onSendPressed,
) {
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
              suffix: Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attachment, color: Colors.grey, size: 24.w),
                    SizedBox(width: 10.w),
                    Icon(Icons.mic, color: Colors.grey, size: 24.w),
                  ],
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
