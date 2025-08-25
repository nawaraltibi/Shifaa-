// file: lib/features/chat/presentation/cubits/get_chats_cubit/get_chats_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shifaa/core/utils/functions/crypto_helper.dart'; // ⭐️ 1. أضف هذا الاستيراد
import 'package:shifaa/features/chat/data/models/chat_summary.dart';
import 'package:shifaa/features/chat/data/models/message.dart'; // ⭐️ 2. أضف هذا الاستيراد
import 'package:shifaa/features/chat/domain/repositories/chat_repo.dart';

part 'get_chats_state.dart';

class GetChatsCubit extends Cubit<GetChatsState> {
  final ChatRepository _chatRepository;

  GetChatsCubit(this._chatRepository) : super(GetChatsInitial());

  Future<void> fetchChats() async {
    emit(GetChatsLoading());

    final result = await _chatRepository.getChats();

    result.fold(
      (failure) {
        emit(GetChatsFailure(failure.message));
      },
      (chats) async {
        // ⭐️ 3. حول الدالة إلى async

        // قائمة جديدة للاحتفاظ بالنتائج المعالجة
        final List<ChatSummary> decryptedChats = [];

        // قم بالمرور على كل محادثة لفك تشفير آخر رسالة فيها
        for (final chat in chats) {
          // تحقق إذا كانت هناك رسالة أخيرة وهل هي من نوع MessageModel
          if (chat.lastMessage != null && chat.lastMessage is MessageModel) {
            final messageToDecrypt = chat.lastMessage as MessageModel;

            // ⭐️ 4. احصل على مفتاح AES الخاص بالرسالة (نفس منطق الشات)
            final aesKey = await getAesKey(messageToDecrypt);

            // ⭐️ 5. فك تشفير نص الرسالة إذا كان المفتاح موجوداً
            if (aesKey.isNotEmpty) {
              final decryptedMessage = await decryptText(
                messageToDecrypt,
                aesKey,
              );

              // ⭐️ 6. أنشئ نسخة من المحادثة مع الرسالة الأخيرة المحدثة
              final decryptedChat = chat.copyWith(
                lastMessage: decryptedMessage,
              );

              decryptedChats.add(decryptedChat);
            } else {
              // إذا لم يتم العثور على مفتاح، أضف المحادثة كما هي (بنص مشفر)
              decryptedChats.add(chat);
            }
          } else {
            // إذا لم تكن هناك رسالة أو لم تكن قابلة لفك التشفير، أضف المحادثة كما هي
            decryptedChats.add(chat);
          }
        }

        // ⭐️ 7. أصدر حالة النجاح مع قائمة المحادثات بعد فك تشفيرها
        emit(GetChatsSuccess(decryptedChats));
      },
    );
  }
}
