import 'package:dartz/dartz.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/core/usecase/usecase.dart';
import 'package:shifaa/features/appointments/domain/entities/appointment_entity.dart';
import 'package:shifaa/features/appointments/domain/repositories/appointment_repository.dart';

// import 'package:shifaa/features/appointments/domain/entities/appointment_entity.dart';
// import 'package:shifaa/features/appointments/domain/repositories/appointment_repository.dart';

class GetUpcomingAppointmentsUseCase implements UseCase<List<AppointmentEntity>, NoParams> {
  final AppointmentRepository repository;
  GetUpcomingAppointmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(NoParams params) async {
    return await repository.getUpcomingAppointments();
  }
}
