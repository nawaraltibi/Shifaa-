import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_images.dart';
import 'package:shifaa/features/auth/presentation/widgets/custom_text_field.dart';

class PhoneNumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PhoneNumberTextField({super.key, this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      validator: validator,
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: 10.w, right: 5.w),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Assets.imagesSyrianFlag,
                height: 27,
                width: 27,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              Container(height: 30, width: 1, color: const Color(0xFFC8C8C8)),
            ],
          ),
        ),
      ),
      hintText: '+963 981 089 458',
      keyboardType: TextInputType.number,
    );
  }
}
