// chat_mute_state.dart

// This directive declares that this file is a part of the 'chat_mute_cubit.dart' library.
part of 'chat_mute_cubit.dart';

abstract class ChatMuteState {}

class ChatMuteInitial extends ChatMuteState {}

class ChatMuteLoading extends ChatMuteState {}

class ChatMuteSuccess extends ChatMuteState {
  final bool isMuted;

  ChatMuteSuccess(this.isMuted);
}

class ChatMuteFailure extends ChatMuteState {
  final String errorMessage;

  ChatMuteFailure(this.errorMessage);
}
