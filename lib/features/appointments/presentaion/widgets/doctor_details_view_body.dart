import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shifaa/core/utils/app_images.dart';
import 'package:shifaa/core/widgets/custom_button.dart';
import 'package:shifaa/features/appointments/data/models/doctor_schedule_model.dart';
import 'package:shifaa/features/appointments/presentaion/cubits/doctor_details_cubit/doctor_details_cubit.dart';
import 'package:shifaa/features/appointments/presentaion/cubits/doctor_details_cubit/doctor_details_cubit_state.dart';
import 'package:shifaa/features/appointments/presentaion/cubits/doctor_schedule_cubit/doctor_schedule_cubit.dart';
import 'package:shifaa/features/appointments/presentaion/cubits/doctor_schedule_cubit/doctor_schedule_state.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/about_doctor.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/custom_doctor_details_app_bar.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/doctor_details_title.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/doctor_important_info.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/doctor_stats.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/select_date_list.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/select_date_title.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/select_time_title.dart';
import 'package:shifaa/features/appointments/presentaion/widgets/time_slots_list.dart';
import 'package:shifaa/generated/l10n.dart';

class DoctorDetailsViewBody extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsViewBody({super.key, required this.doctorId});

  @override
  State<DoctorDetailsViewBody> createState() => _DoctorDetailsViewBodyState();
}

class _DoctorDetailsViewBodyState extends State<DoctorDetailsViewBody> {
  bool detailsLoaded = false;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    context.read<DoctorDetailsCubit>().fetchDoctorDetails(widget.doctorId);
    context.read<DoctorScheduleCubit>().fetchDoctorSchedule(widget.doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DoctorDetailsCubit, DoctorDetailsState>(
      listener: (context, state) {
        if (state is DoctorDetailsSuccess) {
          setState(() => detailsLoaded = true);
        } else if (state is DoctorDetailsError) {
          _showError(context, state.message);
        }
      },
      child: BlocBuilder<DoctorScheduleCubit, DoctorScheduleState>(
        builder: (context, scheduleState) {
          if (!detailsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (scheduleState is DoctorScheduleLoading &&
              scheduleState is! DoctorScheduleDateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (scheduleState is DoctorScheduleError) {
            return Center(child: Text('Error: ${scheduleState.message}'));
          }
          return _buildContent();
        },
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Color(0xFFFFFFFF), Color(0xFFF1F4FF)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [_buildDoctorInfo(), _buildScheduleSection()],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
        builder: (context, state) {
          if (state is DoctorDetailsSuccess) {
            final doctor = state.doctor;
            return Column(
              children: [
                SizedBox(height: 40.h),
                const CustomDoctorDetailsAppBar(),
                SizedBox(height: 22.h),
                DoctorImportantInfo(
                  image: doctor.avatar ?? Assets.imagesDoctor1,
                  name: doctor.fullName,
                  sessionPrice: doctor.consultationFee,
                  specialization: doctor.specialty,
                ),
              ],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: EdgeInsets.only(
          left: 22.w,
          right: 22.w,
          top: 35.h,
          bottom: 54.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DoctorStats(),
            SizedBox(height: 25.h),
            DoctorDetailsTitle(text: S.of(context).about_doctor),
            const SizedBox(height: 10),
            BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
              builder: (context, state) {
                if (state is DoctorDetailsSuccess) {
                  return AboutDoctor(text: state.doctor.bio);
                } else {
                  return AboutDoctor(text: S.of(context).loading_bio);
                }
              },
            ),
            SizedBox(height: 30.h),
            _buildDateSelector(),
            SizedBox(height: 25.h),
            _buildTimeSlots(),
            SizedBox(height: 25.h),
            CustomButton(
              text: S.of(context).book,
              onPressed: () {
                if (_selectedDate != null && _selectedTimeSlot != null) {
                  debugPrint(
                    "Booking for: $_selectedDate at $_selectedTimeSlot",
                  );
                  // هون لاحقًا تبعتهم للـ API
                } else {
                  debugPrint("Please select date & time first!");
                }
              },
              borderRadius: 35.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return BlocBuilder<DoctorScheduleCubit, DoctorScheduleState>(
      buildWhen: (previous, current) =>
          current is DoctorScheduleSuccess ||
          current is DoctorScheduleMonthChanged,
      builder: (context, scheduleState) {
        if (scheduleState is DoctorScheduleSuccess) {
          final availableDays = scheduleState.schedule
              .map((e) => e.dayOfWeek.toLowerCase())
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectDateTitle(
                currentMonth: scheduleState.currentMonth,
                onNext: () => context.read<DoctorScheduleCubit>().nextMonth(),
                onPrevious: () =>
                    context.read<DoctorScheduleCubit>().previousMonth(),
              ),
              SizedBox(height: 15.h),
              SelectDateList(
                currentMonth: scheduleState.currentMonth,
                availableDays: availableDays,
                selectedDate: scheduleState.selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date; // خزّن التاريخ
                  });
                  context
                      .read<DoctorScheduleCubit>()
                      .selectDateAndFetchSchedule(widget.doctorId, date);
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTimeSlots() {
    return BlocBuilder<DoctorScheduleCubit, DoctorScheduleState>(
      builder: (context, scheduleState) {
        if (scheduleState is DoctorScheduleLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (scheduleState is DoctorScheduleDateLoading) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectTimeTitle(slotsCount: 0),
              SizedBox(height: 14),
              Center(child: CircularProgressIndicator()),
            ],
          );
        }

        if (scheduleState is DoctorScheduleSuccess) {
          final currentSchedule = scheduleState.schedule;
          final selectedDate = scheduleState.selectedDate;

          final dayName = DateFormat('EEEE').format(selectedDate).toLowerCase();
          final scheduleForDay = currentSchedule.firstWhere(
            (s) => s.dayOfWeek.toLowerCase() == dayName,
            orElse: () => DoctorScheduleModel(
              id: -1,
              dayOfWeek: '',
              startTime: '',
              endTime: '',
              sessionDuration: 0,
              type: '',
              slots: [],
            ),
          );

          final slotsCount = scheduleForDay.slots.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectTimeTitle(slotsCount: slotsCount),
              const SizedBox(height: 14),
              TimeSlotsList(
                selectedDate: selectedDate,
                schedule: currentSchedule,
                onSlotSelected: (fullDateTime) {
                  debugPrint("Selected: $fullDateTime");
                  setState(() {
                    _selectedTimeSlot = fullDateTime; // خزّن الساعة
                  });
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
