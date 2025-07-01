// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shifaa/core/utils/app_colors.dart';
import 'package:shifaa/core/utils/app_images.dart';
import 'package:shifaa/features/auth/presentation/widgets/auth_white_container.dart';
import 'package:shifaa/features/auth/presentation/widgets/welcome_text.dart';

class AuthTemplate extends StatelessWidget {
  const AuthTemplate({
    Key? key,
    required this.child,
    this.isWelcomeVisible = false,
    required this.margin,
    this.imageTopMargin,
    this.containerTopPadding,
    this.containerTopMargin,
  }) : super(key: key);
  final Widget child;
  final bool isWelcomeVisible;
  final double margin;
  final double? imageTopMargin;
  final double? containerTopPadding;
  final double? containerTopMargin;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: AppColors.primaryAppColor)),
        Positioned(left: 0, top: 0, child: Image.asset(Assets.imagesNotebook)),
        AuthWhiteContainer(
          margin: margin.h,
          imageTopMargin: imageTopMargin,
          containerTopPadding: containerTopPadding,
          containerTopMargin: containerTopMargin,
          child: child,
        ),
        WelcomeText(isVisible: isWelcomeVisible, top: (margin - 90).h),
      ],
    );
  }
}
