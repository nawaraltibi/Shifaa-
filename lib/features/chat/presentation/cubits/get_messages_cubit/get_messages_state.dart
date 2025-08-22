part of 'get_messages_cubit.dart';

abstract class GetMessagesState {}

class GetMessagesInitial extends GetMessagesState {}

class GetMessagesLoading extends GetMessagesState {}

class GetMessagesSuccess extends GetMessagesState {
  final List<Message> messages;

  GetMessagesSuccess(this.messages);
}

class GetMessagesFailure extends GetMessagesState {
  final String error;

  GetMessagesFailure(this.error);
}
