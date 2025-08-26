import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_text_styles.dart';

class ReSchedAppointmentViewBody extends StatelessWidget {
  const ReSchedAppointmentViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 35.h, horizontal: 25.w),
      child: Column(
        children: [
          const AppointmentDetailsAppBar(),
          SizedBox(height: 50.h),
        ],
      ),
    );
  }
}

class AppointmentDetailsAppBar extends StatelessWidget {
  const AppointmentDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(size: 25.sp, Icons.arrow_back, color: const Color(0xFFCECECE)),
        SizedBox(width: 50.w),
        Text(
          'Appointment Details',
          style: AppTextStyles.semiBold22.copyWith(fontSize: 18.sp),
        ),
      ],
    );
  }
}
