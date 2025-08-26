// في ملف: lib/features/chat/presentation/widgets/doctor_chat_image.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_images.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ⭐️ لا تنس هذا الاستيراد

class DoctorChatImage extends StatelessWidget {
  // ✅ 1. أضف متغير لاستقبال رابط الصورة
  final String? imageUrl;
  final double width;
  final double height;

  const DoctorChatImage({
    super.key,
    this.imageUrl, // اجعله اختيارياً
    this.width = 50,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 2. احتفظ بالـ Container الخارجي للحفاظ على التصميم
    return Container(
      height: height.h,
      width: width.w,
      padding: const EdgeInsets.all(3), // يمكنك تعديل الـ padding حسب رغبتك
      decoration: const BoxDecoration(
        color: Color(0xFFf1f4ff), // لون الإطار
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        // ✅ 3. استخدم CachedNetworkImage بدلاً من Image.asset
        child: CachedNetworkImage(
          imageUrl: imageUrl ?? "", // مرر الرابط هنا
          fit: BoxFit.cover, // استخدم BoxFit.cover لملء الدائرة بالكامل
          // واجهة تظهر أثناء تحميل الصورة
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Colors.grey,
            ),
          ),

          // واجهة تظهر في حال حدوث خطأ أو إذا كان الرابط فارغاً
          errorWidget: (context, url, error) => Image.asset(
            AppImages.imagesDoctor1, // الصورة الافتراضية
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
