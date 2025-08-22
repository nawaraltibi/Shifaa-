// usecase
import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/features/chat/data/models/chat.dart';
import 'package:shifaa/features/chat/domain/repositories/chat_repo.dart';

class CreateChat {
  final ChatRepository repository;
  CreateChat(this.repository);

  Future<Either<Failure, Chat>> call(int doctorId) {
    return repository.createChat(doctorId);
  }
}
