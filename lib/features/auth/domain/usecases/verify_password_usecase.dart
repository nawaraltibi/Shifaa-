import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/features/auth/data/models/user_auth_model.dart';
import 'package:shifaa/features/auth/domain/repos/auth_repo.dart';

class VerifyPasswordUseCase {
  final AuthRepository repository;

  VerifyPasswordUseCase(this.repository);

  Future<Either<Failure, UserAuthModel>> call({
    required String phone,
    required int otp,
    required String password,
  }) {
    return repository.verifyPassword(
      phone: phone,
      otp: otp,
      password: password,
    );
  }
}
