// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shifaa/core/utils/app_images.dart';

class AuthWhiteContainer extends StatelessWidget {
  const AuthWhiteContainer({
    Key? key,
    required this.child,
    required this.margin,
    this.imageTopMargin,
    this.containerTopPadding,
    this.containerTopMargin,
  }) : super(key: key);
  final Widget child;
  final double margin;
  final double? imageTopMargin;
  final double? containerTopPadding;
  final double? containerTopMargin;
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      left: 0,
      right: 0,
      bottom: 0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: EdgeInsets.only(top: margin.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35.r),
                topRight: Radius.circular(35.r),
              ),
            ),
            child: Container(
              padding: EdgeInsets.only(top: containerTopPadding ?? 20.h),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.only(top: containerTopMargin ?? 80.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
          Positioned(
            right: 35.w,
            top: imageTopMargin ?? margin - 105.h,
            child: Image.asset(Assets.imagesDoctorElement),
          ),
        ],
      ),
    );
  }
}
