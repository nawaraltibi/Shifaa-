import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifaa/features/chat/data/models/message.dart';
import 'package:shifaa/features/chat/domain/repositories/chat_repo.dart';

part 'get_messages_state.dart';

class GetMessagesCubit extends Cubit<GetMessagesState> {
  final ChatRepository repository;

  GetMessagesCubit(this.repository) : super(GetMessagesInitial());

  // الدالة الجديدة لإضافة رسالة جديدة إلى القائمة
  void addMessage(Message message) {
    if (state is GetMessagesSuccess) {
      final currentMessages = (state as GetMessagesSuccess).messages;
      final newMessages = [...currentMessages, message];
      emit(GetMessagesSuccess(newMessages));
    }
  }

  Future<void> fetchMessages(int chatId) async {
    print('fetchMessages called with chatId: $chatId');
    emit(GetMessagesLoading());
    final result = await repository.getMessages(chatId);
    result.fold(
      (failure) {
        print('GetMessagesCubit - fetchMessages failed: ${failure.message}');
        emit(GetMessagesFailure(failure.message));
      },
      (messages) {
        print(
          'GetMessagesCubit - fetchMessages succeeded with ${messages.length} messages',
        );
        emit(GetMessagesSuccess(messages));
      },
    );
  }
}
