import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifaa/features/appointments/presentation/manager/appointments_cubit.dart';
import 'package:shifaa/features/appointments/presentation/widgets/appointment_card.dart';
import 'package:shifaa/features/appointments/presentation/widgets/toggel_appointment_type.dart';
// ... other imports

class AppointmentViewBody extends StatelessWidget {
  const AppointmentViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentsCubit, AppointmentsLoadSuccess>(
      builder: (context, state) {
        // تم إزالة الـ Scaffold المكرر
        return Column(
          children: [
            ToggleAppointmentsType(
              selectedType: state.appointmentType,
              onTypeChanged: (type) {
                context.read<AppointmentsCubit>().changeAppointmentType(type);
              },
            ),
            const SizedBox(height: 20), // إضافة مسافة
            if (state.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.errorMessage != null)
              Expanded(child: Center(child: Text(state.errorMessage!)))
            else if (state.appointments.isEmpty)
              const Expanded(child: Center(child: Text('No appointments found')))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: state.appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = state.appointments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      // استخدام الويدجت الجديدة والموحدة
                      child: AppointmentCard(
                        appointment: appointment,
                        type: state.appointmentType,
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
