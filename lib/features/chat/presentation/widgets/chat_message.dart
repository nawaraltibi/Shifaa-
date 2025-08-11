import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_colors.dart';
import 'package:shifaa/core/utils/app_text_styles.dart';
import 'package:shifaa/features/chat/presentation/widgets/doctor_chat_image.dart';

class ChatMessage extends StatelessWidget {
  final bool isMe;
  final String text;
  final String? profileImage;

  const ChatMessage({
    super.key,
    required this.isMe,
    required this.text,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe) const DoctorChatImage(height: 40, width: 40),
        SizedBox(width: 10.w),
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primaryAppColor : const Color(0xFFF2F4F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMe ? 20.r : 0),
                topRight: Radius.circular(isMe ? 0 : 20.r),
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
            ),
            child: Text(
              text,
              style: AppTextStyles.regular15.copyWith(
                color: isMe ? Colors.white : const Color(0xFF303437),
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
