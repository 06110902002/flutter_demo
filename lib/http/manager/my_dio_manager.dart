/// @author: jiangjunhui
/// @date: 2025/1/23
library;

import 'package:dio/dio.dart';
import 'package:synchronized/synchronized.dart';
import 'package:test_flutter/http/utils/extension_string.dart';
import '../core/my_request_options.dart';

class MyDioManager {
  final Map<String, CancelToken> cancelTokens = {};
  // 静态私有实例，初始值为 null
  static MyDioManager? _instance;
  // 私有构造函数
  MyDioManager._privateConstructor();

  // 静态工厂方法，用于获取单例实例
  static MyDioManager get instance {
    // 创建一个锁对象
    final Lock lock = Lock();
    lock.synchronized(() {
      _instance ??= MyDioManager._privateConstructor();
    });
    return _instance!;
  }

  // 取消某个请求
  void cancelRequest(String cancelTokenKey) {
    final cancelToken = cancelTokens[cancelTokenKey];
    if (cancelToken != null) {
      cancelToken.cancel('Request cancelled by user');
      cancelTokens.remove(cancelTokenKey);
    }
  }

  // 取消全部请求
  void cancelAllRequests() {
    cancelTokens.forEach((key, cancelToken) {
      cancelToken.cancel('All requests cancelled by user');
    });
    cancelTokens.clear();
  }

  /// 获取CancelToken
  CancelToken getCancelToken({required MyRequestOptions options}) {
    String cancelTokenKey = getCancelTokenKey(options: options);
    CancelToken? cancelToken;
    cancelToken = cancelTokens[cancelTokenKey];
    if (cancelToken == null) {
      cancelToken = CancelToken();
      cancelTokens[cancelTokenKey] = cancelToken;
    }
    return cancelToken;
  }

  /// 获取CancelTokenKey
  String getCancelTokenKey({required MyRequestOptions options}) {
    String url = options.baseUrl + options.urlPath;
    String paramString = options.params.toString();
    String cancelTokenKey = (url + paramString).md5Hash();
    return cancelTokenKey;
  }
}
