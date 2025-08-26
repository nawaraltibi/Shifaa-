// lib/features/chat/presentation/cubits/mute_chat_cubit/chat_mute_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifaa/features/chat/domain/repositories/chat_repo.dart';

part 'chat_mute_state.dart';

class ChatMuteCubit extends Cubit<ChatMuteState> {
  final ChatRepository _chatRepository;

  ChatMuteCubit(this._chatRepository) : super(ChatMuteInitial());

  /// يجلب حالة الكتم الأولية للمحادثة عند تحميل الشاشة.
  /// لا يصدر حالة تحميل لتجنب إظهار SnackBar عند الدخول.
  Future<void> loadInitialMuteStatus(int chatId) async {
    final result = await _chatRepository.getChatDetails(chatId);
    result.fold(
      (failure) {
        // إذا فشل، نفترض أن المحادثة ليست مكتومة كقيمة افتراضية آمنة
        emit(ChatMuteSuccess(false));
      },
      (chat) {
        // إذا نجح، نستخدم القيمة الحقيقية من الـ API
        emit(ChatMuteSuccess(chat.muted));
      },
    );
  }

  /// يغير حالة الكتم عند ضغط المستخدم على الأيقونة.
  /// يصدر حالة تحميل لإظهار مؤشر التقدم، ثم حالة نجاح لتشغيل الـ SnackBar.
  Future<void> toggleMute(int chatId) async {
    // 1. أظهر مؤشر التحميل
    emit(ChatMuteLoading());

    // 2. قم باستدعاء الـ API
    final result = await _chatRepository.muteChat(chatId);

    // 3. عالج النتيجة
    result.fold(
      (failure) {
        // في حالة الفشل، أرجع الحالة إلى ما كانت عليه قبل الضغط
        // (هذا الجزء يمكن تحسينه لاحقاً بإعادة جلب الحالة)
        emit(ChatMuteFailure(failure.message));
      },
      (chat) {
        // في حالة النجاح، قم بتحديث الواجهة وتشغيل الـ SnackBar
        emit(ChatMuteSuccess(chat.muted));
      },
    );
  }
}
