import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/features/appointments/data/datasources/appointment_remote_data_source.dart';
import 'package:shifaa/features/appointments/domain/entities/appointment_entity.dart';
import 'package:shifaa/features/appointments/domain/repositories/appointment_repository.dart';
// ... other imports

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;
  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getUpcomingAppointments() async {
    try {
      final appointments = await remoteDataSource.getAppointments('upcoming');
      return Right(appointments);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDiorError(e));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getPreviousAppointments() async {
     try {
      final appointments = await remoteDataSource.getAppointments('past');
      return Right(appointments);
    } on DioException catch (e) {
      return Left(ServerFailure.fromDiorError(e));
    }
  }
}
