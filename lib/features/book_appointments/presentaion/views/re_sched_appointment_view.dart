import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shifaa/features/book_appointments/presentaion/widgets/re_sched_appointment_view_body.dart';

class ReSchedAppointmentView extends StatelessWidget {
  const ReSchedAppointmentView({super.key});
  static const routeName = '/re-sched-appointment';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ReSchedAppointmentViewBody());
  }
}
