import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart'; // <-- Add this import statement
import 'package:shifaa/features/chat/data/repositories/chat_repo_impl.dart';
import 'package:shifaa/features/chat/presentation/cubits/get_messages_cubit/get_messages_cubit.dart';
import 'package:shifaa/features/chat/presentation/widgets/chat_view_body.dart';
import 'package:shifaa/features/chat/domain/repositories/chat_repo.dart';
import 'package:shifaa/features/chat/data/data_sources/chat_remote_data_source.dart';

import '../../../../core/functions/setup_service_locator.dart';

class ChatView extends StatelessWidget {
  final int chatId;

  const ChatView({super.key, required this.chatId});
  static const routeName = '/chat-view';

  @override
  Widget build(BuildContext context) {
    // 1. قم بتوفير ChatRepository أولاً
    return Provider<ChatRepository>(
      create: (context) => ChatRepositoryImpl(getIt<ChatRemoteDataSource>()),
      child: BlocProvider(
        // 2. ثم قم بتوفير GetMessagesCubit (الذي قد يحتاج ChatRepository أيضًا عبر getIt)
        create: (context) => getIt<GetMessagesCubit>()..fetchMessages(chatId),
        child: Scaffold(body: ChatViewBody(chatId: chatId)),
      ),
    );
  }
}
