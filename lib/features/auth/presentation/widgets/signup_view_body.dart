import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shifaa/core/utils/app_text_styles.dart';
import 'package:shifaa/core/widgets/custom_button.dart';
import 'package:shifaa/features/auth/presentation/views/login_view.dart';
import 'package:shifaa/features/auth/presentation/views/profile_setup_view.dart';
import 'package:shifaa/features/auth/presentation/widgets/auth_template.dart';
import 'package:shifaa/features/auth/presentation/widgets/auth_title.dart';
import 'package:shifaa/features/auth/presentation/widgets/on_tap_text.dart';
import 'package:shifaa/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:shifaa/features/auth/presentation/widgets/text_field_title.dart';
import 'package:shifaa/generated/l10n.dart';

class SignupViewBody extends StatefulWidget {
  const SignupViewBody({super.key});

  @override
  State<SignupViewBody> createState() => _SignupViewBodyState();
}

class _SignupViewBodyState extends State<SignupViewBody> {
  final TextEditingController _phoneController = TextEditingController();
  String? _nationalNumber;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      isWelcomeVisible: true,
      margin: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTitle(text: S.of(context).signup),
          SizedBox(height: 70.h),
          TextFieldTitle(text: S.of(context).phoneNumber),
          Directionality(
            textDirection: TextDirection.ltr,
            child: PhoneNumberField(
              controller: _phoneController,
              borderColor: _showError ? Colors.red : const Color(0xFFC8C8C8),
              onChanged: (number) {
                setState(() {
                  _nationalNumber = number;
                  _showError = false;
                });
              },
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
          CustomButton(
            text: S.of(context).signup,
            onPressed: () {
              if (_nationalNumber == null || _nationalNumber!.isEmpty) {
                setState(() {
                  _showError = true;
                });
              } else {
                context.goNamed(ProfileSetupView.routeName);
              }
            },
          ),
          SizedBox(height: 35.h),
          Align(
            alignment: Alignment.center,
            child: Text(
              S.of(context).haveAnAccount,
              style: AppTextStyles.regular12,
            ),
          ),
          OnTapBlueText(
            onTap: () => context.goNamed(LoginView.routeName),
            text: S.of(context).login,
          ),
          SizedBox(height: 35.h),
        ],
      ),
    );
  }
}
