import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_images.dart';

class DoctorChatImage extends StatelessWidget {
  const DoctorChatImage({super.key, this.width = 50, this.height = 50});
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height!.h,
      width: width!.w,
      padding: const EdgeInsets.only(left: 7, right: 7, top: 7),
      decoration: const BoxDecoration(
        color: Color(0xFFf1f4ff),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(AppImages.imagesDoctor1, fit: BoxFit.contain),
      ),
    );
  }
}
