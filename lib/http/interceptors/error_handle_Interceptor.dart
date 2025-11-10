/// @author: jiangjunhui
/// @date: 2025/1/22
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../jsonConverter/json_type_adapter.dart';
import '../utils/toast_util.dart';



Map<String, String> _errorCodeMessage = {
  "400": "状态码：400 请求参数错误",
  "401": "状态码：401 身份验证错误",
  "403": "状态码：403 服务器拒绝请求",
  "404": "状态码：404 找不到服务器地址",
  "407": "状态码：407 需要代理授权",
  "408": "状态码：408 请求超时",
  "500": "状态码：500 服务器内部错误",
  "501": "状态码：501 尚未实施",
  "502": "状态码：502 错误网关",
  "503": "状态码：503 服务不可用",
  "504": "状态码：504 网关超时",
  "505": "HTTP 版本不受支持",
  "-1000": "解析不到数据"
};

/*
 * 特殊状态code处理的拦截器，
 * 401 弹出弹窗提示用户重新登录
 */
class ErrorHandleInterceptor extends Interceptor {
  /// 是否显示http网络请求错误
  final bool isShowHttpErrorMsg;
  /// 响应code不为0异常
  final bool isShowDataErrorMsg;

  ErrorHandleInterceptor(
      {required this.isShowHttpErrorMsg, required this.isShowDataErrorMsg});

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    // 自定义错误处理逻辑
    if (isShowHttpErrorMsg) {
      _handleHttpError(error);
    }
    handler.next(error);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (isShowDataErrorMsg) {
      _handleDataError(response);
    }
    super.onResponse(response, handler);
  }

  /// 网络异常
  void _handleHttpError(DioException error) {
    String errorMsg = "网络异常";
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMsg = '连接超时';
      case DioExceptionType.sendTimeout:
        errorMsg = '发送超时';
      case DioExceptionType.receiveTimeout:
        errorMsg = '接受超时';
      case DioExceptionType.badCertificate:
        errorMsg = '无效证书';
      case DioExceptionType.badResponse:
        errorMsg = '无效响应';
      case DioExceptionType.cancel:
        errorMsg = '请求取消';
      case DioExceptionType.connectionError:
        errorMsg = '链接错误';
      case DioExceptionType.unknown:
        errorMsg = '未知错误';
    }

    int? code = error.response?.statusCode;
    if (code != null) {
      String codeString = code.toString();
      errorMsg = _errorCodeMessage[codeString] ?? "网络异常";
    }

    if (isShowHttpErrorMsg) {
      if (kDebugMode) {
        errorMsg = "网络异常";
      }
      ToastUtil.showToast(msg: errorMsg);
    }
  }

  /// 网络异常
  void _handleDataError(Response response) {
    Map<String, dynamic> data = {};
    if (response.data is Map) {
      data = response.data as Map<String, dynamic>;
    } else if (response.data is String) {
      data = response.data.toMap();
    }
    final num? code = JsonTypeAdapter.safeParseNumber(data['code']);
    // 检查 code 是否为 0
    if (code != null && code.toInt() != 0) {
      final String message = data['message'] as String? ?? '未知错误';
      ToastUtil.showToast(msg: message);
    }
  }
}
