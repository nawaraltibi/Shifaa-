import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shifaa/core/widgets/custom_button.dart';
import 'package:shifaa/features/auth/presentation/cubits/send_otp_cubit/send_otp_cubit.dart';
import 'package:shifaa/features/auth/presentation/views/verify_otp_view.dart';
import 'package:shifaa/features/auth/presentation/widgets/auth_title.dart';
import 'package:shifaa/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:shifaa/features/auth/presentation/widgets/text_field_title.dart';
import 'package:shifaa/generated/l10n.dart';
import 'package:shifaa/features/auth/presentation/widgets/auth_template.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  String? _nationalNumber;
  final TextEditingController _phoneController = TextEditingController();
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendOtpCubit, SendOtpState>(
      listener: (context, state) {
        if (state is SendOtpSuccess) {
          context.goNamed(VerifyOtpView.routeName);
        } else if (state is SendOtpError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: AuthTemplate(
        containerHeight: 500.h,
        isWelcomeVisible: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthTitle(text: S.of(context).login),
            SizedBox(height: 50.h),
            TextFieldTitle(text: S.of(context).phoneNumber),
            Directionality(
              textDirection: TextDirection.ltr,
              child: PhoneNumberField(
                borderColor: _showError ? Colors.red : const Color(0xFFC8C8C8),
                onChanged: (fullNumber) {
                  setState(() {
                    _nationalNumber =
                        fullNumber; // هنا الرقم كامل مع رمز الدولة
                    _showError = false;
                  });
                },
                controller: _phoneController,
              ),
            ),
            if (_showError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  S.of(context).pleaseEnterPhone,
                  style: TextStyle(color: Colors.red, fontSize: 13.sp),
                ),
              ),
            SizedBox(height: 60.h),
            BlocBuilder<SendOtpCubit, SendOtpState>(
              builder: (context, state) {
                final isLoading = state is SendOtpLoading;

                return CustomButton(
                  text: S.of(context).login,
                  isLoading: isLoading,
                  onPressed: () {
                    if (_nationalNumber == null || _nationalNumber!.isEmpty) {
                      setState(() {
                        _showError = true;
                      });
                    } else {
                      print('الرقم الكامل: $_nationalNumber');
                      context.read<SendOtpCubit>().sendOtp(_nationalNumber!);
                    }
                  },
                );
              },
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
