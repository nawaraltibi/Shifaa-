import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shifaa/core/utils/app_colors.dart';
import 'package:shifaa/core/utils/app_images.dart';
import 'package:shifaa/core/utils/app_text_styles.dart';
import 'package:shifaa/core/widgets/custom_button.dart';
import 'package:shifaa/features/appointments/data/models/doctor_schedule_model.dart';
import 'package:shifaa/features/appointments/presentaion/cubits/appointment_cubit/appointment_cubit.dart';
import 'package:shifaa/features/appointments/presentaion/cubits/appointment_cubit/appointment_state.dart';
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
    return MultiBlocListener(
      listeners: [
        BlocListener<DoctorDetailsCubit, DoctorDetailsState>(
          listener: (context, state) {
            if (state is DoctorDetailsSuccess) {
              setState(() => detailsLoaded = true);
            } else if (state is DoctorDetailsError) {
              _showError(context, state.message);
            }
          },
        ),
        BlocListener<AppointmentCubit, AppointmentState>(
          listener: (context, state) {
            if (state is AppointmentLoading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryAppColor,
                  ),
                ),
              );
            } else {
              if (Navigator.canPop(context)) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              if (state is AppointmentSuccess) {
                // ✅ تم ترجمة النص هنا
                _showSnackBar(
                  context,
                  // "تم الحجز بنجاح "
                  S
                      .of(context)
                      .bookSuccess, // يجب أن يكون هذا المفتاح موجودًا في ملف الترجمة
                  type: SnackBarType.success,
                );

                if (_selectedDate != null) {
                  context
                      .read<DoctorScheduleCubit>()
                      .selectDateAndFetchSchedule(
                        widget.doctorId,
                        _selectedDate!,
                      );
                }

                setState(() {
                  _selectedTimeSlot = null;
                });
              } else if (state is AppointmentError) {
                _showSnackBar(context, state.message, type: SnackBarType.error);
              }
            }
          },
        ),
      ],
      child: BlocBuilder<DoctorScheduleCubit, DoctorScheduleState>(
        builder: (context, scheduleState) {
          if (!detailsLoaded) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryAppColor,
              ),
            );
          }

          if (scheduleState is DoctorScheduleLoading &&
              scheduleState is! DoctorScheduleDateLoading) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: AppColors.primaryAppColor,
              ),
            );
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
                if (_selectedDate == null) {
                  // ✅ تم ترجمة هذا النص
                  _showSnackBar(
                    context,
                    S.of(context).select_date,
                    type: SnackBarType.error,
                  );
                  return;
                }

                if (_selectedTimeSlot == null) {
                  // ✅ تم ترجمة هذا النص
                  _showSnackBar(
                    context,
                    S.of(context).select_time,
                    type: SnackBarType.error,
                  );
                  return;
                }

                _showConfirmationDialog(context);
              },
              borderRadius: 35.r,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    if (_selectedDate == null || _selectedTimeSlot == null) return;

    final formattedDate = DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate!);
    final fullDateTimeString = _selectedTimeSlot!;
    final time = fullDateTimeString.contains('-')
        ? fullDateTimeString.split('-').last.trim()
        : fullDateTimeString;

    final formattedDateTime = '$formattedDate - $time';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(
                Icons.event_available,
                color: AppColors.primaryAppColor,
              ),
              const SizedBox(width: 8),
              // ✅ تم ترجمة هذا النص
              Text(
                S.of(context).confirmBooking, // مفتاح جديد
                style: AppTextStyles.semiBold18.copyWith(fontSize: 20.sp),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ تم ترجمة هذا النص
              Text(
                S.of(context).confirmBookingMessage, // مفتاح جديد
                style: AppTextStyles.regular15,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                formattedDateTime,
                style: AppTextStyles.semiBold18.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.primaryAppColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  SizedBox(
                    height: 40.h,
                    width: 110.w,
                    child: CustomButton(
                      // ✅ تم ترجمة هذا النص
                      text: S.of(context).cancel, // مفتاح جديد
                      onPressed: () => Navigator.pop(context),
                      borderRadius: 35.r,
                      color: const Color(0xFFFF6F61),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 40.h,
                    width: 110.w,
                    child: CustomButton(
                      // ✅ تم ترجمة هذا النص
                      text: S.of(context).ok, // مفتاح جديد
                      onPressed: () {
                        if (_selectedDate == null || _selectedTimeSlot == null)
                          return;

                        final datePart = DateFormat(
                          'yyyy-MM-dd',
                        ).format(_selectedDate!);

                        final rawTime = _selectedTimeSlot!.contains('-')
                            ? _selectedTimeSlot!.split('-').last.trim()
                            : _selectedTimeSlot!;

                        final parsedTime = DateFormat("h:mm a").parse(rawTime);
                        final timePart = DateFormat("HH:mm").format(parsedTime);

                        final startTime = "$datePart $timePart";

                        final scheduleState = context
                            .read<DoctorScheduleCubit>()
                            .state;

                        int? doctorScheduleId;

                        if (scheduleState is DoctorScheduleSuccess) {
                          for (final schedule in scheduleState.schedule) {
                            if ((schedule.availableSlots ?? []).contains(
                              timePart,
                            )) {
                              doctorScheduleId = schedule.id;
                              break;
                            }
                          }
                        }

                        if (doctorScheduleId == null) {
                          Navigator.pop(context); // يسكر الـ dialog
                          // ✅ تم ترجمة هذا النص
                          _showSnackBar(
                            context,
                            S.of(context).noScheduleFound, // مفتاح جديد
                            type: SnackBarType.error,
                          );
                          return;
                        }

                        context.read<AppointmentCubit>().bookAppointment(
                          startTime: startTime,
                          doctorScheduleId: doctorScheduleId,
                        );

                        Navigator.pop(context); // يسكر فقط Dialog التأكيد
                      },
                      borderRadius: 35.r,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
  }) {
    Color backgroundColor;
    IconData icon;
    Color iconColor = Colors.white;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red.shade700;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange.shade700;
        icon = Icons.warning_amber_rounded;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = Colors.blueGrey.shade700;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            Colors.transparent, // خلفية شفافة عشان نقدر نرسم الكارد
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.6),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
                    _selectedDate = date;
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAppColor),
          );
        }

        if (scheduleState is DoctorScheduleDateLoading) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectTimeTitle(slotsCount: 0),
              SizedBox(height: 14),
              Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryAppColor,
                ),
              ),
            ],
          );
        }

        if (scheduleState is DoctorScheduleSuccess) {
          final currentSchedule = scheduleState.schedule;
          final selectedDate = scheduleState.selectedDate;

          final dayName = DateFormat('EEEE').format(selectedDate).toLowerCase();
          final slotsForSelectedDay = currentSchedule
              .where((s) => s.dayOfWeek.toLowerCase() == dayName)
              .expand((s) => s.availableSlots ?? [])
              .toList();

          final slotsCount = slotsForSelectedDay.length;

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
                    _selectedTimeSlot = fullDateTime;
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

enum SnackBarType { success, error, warning, info }
