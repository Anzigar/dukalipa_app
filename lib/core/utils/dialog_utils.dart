import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../presentation/common/widgets/loading_widget.dart';

class DialogUtils {
  /// Shows a loading dialog with the Lottie animation
  static Future<void> showLoadingDialog(BuildContext context, {String? message}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingWidget(size: 80.w),
              if (message != null) ...[
                SizedBox(height: 16.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ],
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }

  /// Hides any active dialog
  static void hideDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
