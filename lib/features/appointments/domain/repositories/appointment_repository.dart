import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/features/appointments/domain/entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, List<AppointmentEntity>>> getUpcomingAppointments();
  Future<Either<Failure, List<AppointmentEntity>>> getPreviousAppointments();
}
