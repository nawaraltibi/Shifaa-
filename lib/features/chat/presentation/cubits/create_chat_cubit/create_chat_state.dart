import 'package:shifaa/features/chat/data/models/chat.dart';

abstract class CreateChatState {
  const CreateChatState();

  @override
  List<Object?> get props => [];
}

class CreateChatInitial extends CreateChatState {}

class CreateChatLoading extends CreateChatState {}

class CreateChatSuccess extends CreateChatState {
  final Chat chat;

  const CreateChatSuccess(this.chat);

  @override
  List<Object?> get props => [chat];
}

class CreateChatFailure extends CreateChatState {
  final String error;

  const CreateChatFailure(this.error);

  @override
  List<Object?> get props => [error];
}
