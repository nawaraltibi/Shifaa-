import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shifaa/core/usecase/usecase.dart';
import 'package:shifaa/features/appointments/domain/entities/appointment_entity.dart';
import 'package:shifaa/features/appointments/domain/usecases/get_previous_appointments.dart';
import 'package:shifaa/features/appointments/domain/usecases/get_upcoming_appointments.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsLoadSuccess> {
  final GetUpcomingAppointmentsUseCase getUpcomingAppointmentsUseCase;
  final GetPreviousAppointmentsUseCase getPreviousAppointmentsUseCase;

  AppointmentsCubit({
    required this.getUpcomingAppointmentsUseCase,
    required this.getPreviousAppointmentsUseCase,
  }) : super(const AppointmentsLoadSuccess()) {
    fetchAppointments();
  }

  void changeAppointmentType(AppointmentType type) {
    emit(state.copyWith(appointmentType: type));
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    emit(state.copyWith(isLoading: true, clearError: true, appointments: []));
    
    final result = state.appointmentType == AppointmentType.upcoming
        ? await getUpcomingAppointmentsUseCase(NoParams())
        : await getPreviousAppointmentsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (appointments) {
        emit(state.copyWith(isLoading: false, appointments: appointments));
      },
    );
  }
}
