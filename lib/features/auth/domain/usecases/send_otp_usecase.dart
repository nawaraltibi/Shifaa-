import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';
import '../repos/auth_repo.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, void>> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}
