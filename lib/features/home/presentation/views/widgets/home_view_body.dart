import 'package:flutter/material.dart';
import 'package:shifaa/features/home/presentation/views/widgets/home_app_bar.dart';
import 'package:shifaa/features/home/presentation/views/widgets/previous_appointments_section.dart';
import 'package:shifaa/features/home/presentation/views/widgets/random_tips_section.dart';
import 'package:shifaa/features/home/presentation/views/widgets/specialties_section.dart';
import 'package:shifaa/features/home/presentation/views/widgets/upcoming_appointments_section.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(height: 16),
                HomeAppBar(),
                SizedBox(height: 24),
                RandomTipsSection(),
                SizedBox(height: 24),
                UpcomingAppointmentsSection(),
                SizedBox(height: 16),
                PreviousAppointmentsSection(),
                SizedBox(height: 24),
                SpecialtiesSection(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 