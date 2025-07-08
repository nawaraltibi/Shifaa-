import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';
import '../repos/auth_repo.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(String phoneNumber, String otp) {
    return repository.verifyOtp(phoneNumber, otp);
  }
}
