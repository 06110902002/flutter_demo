/// @author: jiangjunhui
/// @date: 2025/1/23
library;
import 'package:dio/dio.dart';
import '../utils/toast_util.dart';

class LoadingInterceptor extends Interceptor {
  /// 是否显示loading
  final bool isShowLoading;
  LoadingInterceptor({required this.isShowLoading});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 在请求发起时显示加载提示
    if (isShowLoading) {
      _showLoading();
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 在请求出错时隐藏加载提示
    if (isShowLoading) {
      _hideLoading();
    }
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 在请求成功响应后隐藏加载提示
    if (isShowLoading) {
      _hideLoading();
    }

    super.onResponse(response, handler);
  }

  /// 弹窗
  void _showLoading() {
    ToastUtil.showLoading();
  }

  /// 隐藏弹窗
  void _hideLoading() {
    ToastUtil.dismiss();
  }
}
