import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String phoneNumber);
  Future<Either<Failure, String>> verifyOtp(String phoneNumber, String otp);
}
