import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/core/use_cases/use_case.dart';
import '../repos/auth_repo.dart';

class SendOtpUseCase extends UseCase<void, String> {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String phoneNumber) {
    return repository.sendOtp(phoneNumber);
  }
}
