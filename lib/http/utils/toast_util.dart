/// @author: jiangjunhui
/// @date: 2025/2/8
library;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ToastUtil {
  /// 提示信息
  static void showToast(
      {required String msg, int duration = 2000, bool dismissOnTap = false}) {
    EasyLoading.showToast(msg,
        duration: Duration(milliseconds: duration),
        toastPosition: EasyLoadingToastPosition.center,
        dismissOnTap: dismissOnTap);
  }

  /// 加载框
  static void showLoading({String? msg, bool dismissOnTap = false}) {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.dark
      ..radius = 5.0
      ..maskColor = Colors.white.withOpacity(0.1);

    EasyLoading.show(
        status: msg,
        maskType: EasyLoadingMaskType.custom,
        dismissOnTap: dismissOnTap);
  }

  /// 隐藏loading
  static void dismiss() {
    if (EasyLoading.isShow) {
      EasyLoading.dismiss(animation: true);
    }
  }
}
