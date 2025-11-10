/// @author: jiangjunhui
/// @date: 2025/1/22
library;
import 'package:dio/dio.dart';
import 'dart:async';

import '../../page_frame_work/log/log.dart';


/**
 * 用户权限鉴定、token刷新
 * 使用 QueuedInterceptorsWrapper 可以确保多个并发请求进入拦截器时，只处理一次 CSRF Token 的获取。
    当第一个请求进入拦截器时，会触发 CSRF Token 的获取，后续请求会等待第一个请求完成后再继续执行。
 */

class RefreshTokenInterceptor extends QueuedInterceptorsWrapper {
  String? _token;
  Completer<String>? _refreshTokenCompleter;

  Future<String> _fetchToken() async {
    // // 这里模拟请求 Token 的过程，实际应用中可以使用 dio 或其他方式发送请求获取
    // await Future.delayed(Duration(seconds: 1));
    Log.error(" 这里模拟请求 Token 的过程: ");
    return 'your_token_value';
  }

  Future<String> _getToken() async {
    if (_refreshTokenCompleter == null) {
      _refreshTokenCompleter = Completer<String>();
      try {
        _token = await _fetchToken();
        _refreshTokenCompleter!.complete(_token);
      } catch (e) {
        _refreshTokenCompleter!.completeError(e);
      }
    }
    return _refreshTokenCompleter!.future;
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (_token == null) {
      try {
        _token = await _getToken();
        options.headers['Token'] = _token;
        handler.next(options);
      } catch (e) {
        handler.reject(DioException(requestOptions: options, error: e));
      }
    } else {
      options.headers['Token'] = _token;
      handler.next(options);
    }

    // handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    handler.next(error);
  }
}

