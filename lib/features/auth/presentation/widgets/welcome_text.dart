import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shifaa/core/utils/app_text_styles.dart';
import 'package:shifaa/generated/l10n.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({Key? key, this.isVisible = false, required this.top})
    : super(key: key);
  final bool isVisible;
  final double top;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Positioned(
        left: lang == 'ar' ? -10.w : 30.w,
        top: top,
        child: SizedBox(
          height: 200,
          width: 200,
          child: Visibility(
            visible: isVisible,
            child: Column(
              crossAxisAlignment: lang == 'ar'
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).welcome,
                  style: AppTextStyles.medium24.copyWith(color: Colors.white),
                ),
                Directionality(
                  textDirection: lang == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Text(
                    S.of(context).Shifaa,
                    style: AppTextStyles.medium34.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
