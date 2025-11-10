/// @author: jiangjunhui
/// @date: 2025/1/22
library;
import 'package:dio/dio.dart';
import 'dart:convert';


/*
数据转换拦截器
* 将请求或响应的数据在发送或接收时进行转换，例如将 JSON 数据转换为自定义的数据模型，或者对数据进行加密 / 解密。
可以确保数据的格式和安全性符合应用的要求。
* */
class DataTransformInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data != null && options.data is Map<String, dynamic>) {
      options.data = jsonEncode(options.data);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      response.data = jsonDecode(response.data);
    }
    handler.next(response);
  }
}
