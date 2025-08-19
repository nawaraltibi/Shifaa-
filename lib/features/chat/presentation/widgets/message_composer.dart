import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_colors.dart';

// ✅✅✅ --- تم تعديل توقيع الدالة لتقبل دالة جديدة --- ✅✅✅
Widget buildMessageComposer({
  required TextEditingController messageController,
  required VoidCallback onSendPressed,
  required VoidCallback
  onAttachmentPressed, // <-- ✅ إضافة: دالة جديدة للضغط على المرفقات
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              filled: true,
              fillColor: const Color(0xFFF0F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 10.h,
              ),
              // ✅ تعديل: استخدمنا suffixIcon بدلاً من suffix لسهولة التحكم
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: IconButton(
                  // <-- ✅ تحويلها إلى زر قابل للضغط
                  icon: Icon(Icons.attachment, color: Colors.grey, size: 24.w),
                  onPressed: onAttachmentPressed, // <-- ✅ الربط بالدالة الجديدة
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        FloatingActionButton(
          elevation: 2,
          onPressed: onSendPressed,
          backgroundColor: AppColors.primaryAppColor,
          shape: const CircleBorder(),
          child: Icon(Icons.send, color: Colors.white, size: 24.w),
        ),
      ],
    ),
  );
}
