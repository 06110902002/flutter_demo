import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// FileName my_request.dart
///
/// @Author jiangjunhui
/// @Date 2023/6/8 14:00
///
/// @Description TODO

/// 请求方式
enum MyRequestMethod { get, post }

class MyRequestOptions {
  /// 请求方式
  MyRequestMethod method = MyRequestMethod.get;

  /// 基础url
  String baseUrl =
      "https://mockapi.eolink.com/uvemJdBf6d6fe15694c6ce211778969e0cfaacf4f97f262";

  /// 请求路径
  String urlPath = "";

  /// 参数
  Map<String, dynamic> params = <String, dynamic>{};

  /// HTTP 请求头。
  Map<String, dynamic> headers = <String, dynamic>{};

  /// 连接服务器超时时间.
  Duration connectTimeout = const Duration(seconds: 10);

  /// 接收数据的超时设置。
  ///
  /// 这里的超时对应的时间是：
  ///  - 在建立连接和第一次收到响应数据事件之前的超时。
  ///  - 每个数据事件传输的间隔时间，而不是接收的总持续时间。
  ///
  /// 超时时会抛出类型为 [DioExceptionType.receiveTimeout] 的
  /// [DioException]。
  ///
  /// `null` 或 `Duration.zero` 即不设置超时。
  Duration receiveTimeout = const Duration(seconds: 10);

  MyRequestOptions({required String url, Map<String, dynamic>? paramsMap}) {
    urlPath = url;
    if (paramsMap != null) {
      params.addAll(paramsMap);
    }

    // 设置默认header
    _addDefaultHeader();
  }

  /// 设置Mockurl
  void setMockUrl({required String mockUrl}) {
    if (kDebugMode) {
      baseUrl = mockUrl;
    }
  }

  String getMethod() {
    if (method == MyRequestMethod.get) {
      return "get";
    }
    return "post";
  }

  /// 设置默认header
  void _addDefaultHeader() {
    Map<String, dynamic> defaultHeader = {
      "Content-Type": "application/json; charset=utf-8",
      "Accept": "application/json"
    };
    headers.addAll(defaultHeader);
  }

  /// 设置header
  void setHeader({required Map<String, dynamic> headerMap}) {
    headers.addAll(headerMap);
  }
}
