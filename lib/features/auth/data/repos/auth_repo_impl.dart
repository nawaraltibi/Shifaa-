import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/features/auth/domain/repos/auth_repo.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    try {
      await remote.sendOtp(phoneNumber); // استعمل remote مباشرة هنا
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDiorError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      final token = await remote.verifyOtp(phoneNumber, otp);
      return Right(token);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDiorError(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
