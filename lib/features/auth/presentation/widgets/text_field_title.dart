import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_text_styles.dart';

class TextFieldTitle extends StatelessWidget {
  const TextFieldTitle({super.key, required this.text, this.bottomPadding = 7});
  final String text;
  final double? bottomPadding;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.only(bottom: bottomPadding!.h),
      child: Text(
        text,
        style: AppTextStyles.medium16.copyWith(color: const Color(0xFF575757)),
      ),
    );
  }
}
