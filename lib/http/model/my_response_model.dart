import 'dart:convert';
import '../core/my_request_options.dart';

/// FileName my_response.dart
///
/// @Author jiangjunhui
/// @Date 2023/6/8 14:01
///
/// @Description TODO

class MyResopnseModel<T> {
  /// 响应对应的请求配置。
  MyRequestOptions requestOptions;

  /// 响应的 HTTP 状态码。
  int? statusCode;

  /// 响应对应状态码的详情信息。
  String? statusMessage;

  /// 响应头
  Map<String, dynamic>? responseHeaders;

  /// 原始数据值
  T? data;


  MyResopnseModel(
  {required this.requestOptions,required this.data, this.statusCode, this.responseHeaders, this.statusMessage});


  String getDataString() {
    if (data is Map) {
      // Log encoded maps for better readability.
      return json.encode(data);
    }
    return data.toString();
  }
  /// 是否成功
  bool isHttpSucess() {
    bool result = this.statusCode == 200;
    return result;
  }


}





















