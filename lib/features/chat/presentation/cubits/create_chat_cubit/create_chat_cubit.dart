import 'package:bloc/bloc.dart';
import 'package:shifaa/features/chat/domain/usecases/create_chat_use_case.dart';
import 'package:shifaa/features/chat/presentation/cubits/create_chat_cubit/create_chat_state.dart';

class CreateChatCubit extends Cubit<CreateChatState> {
  final CreateChat createChat;

  CreateChatCubit(this.createChat) : super(CreateChatInitial());

  Future<void> startChat(int doctorId) async {
    emit(CreateChatLoading());

    final result = await createChat(doctorId);

    result.fold(
      (failure) => emit(CreateChatFailure(failure.message)),
      (chat) => emit(CreateChatSuccess(chat)),
    );
  }
}
