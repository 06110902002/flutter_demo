/// @author: jiangjunhui
/// @date: 2025/1/23
library;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:test_flutter/http/utils/extension_string.dart';

import '../utils/file_utils.dart';


/// 缓存策略
enum MyNetworkCachePolicy {
  /// 不用缓存
  none,

  /// 先用缓存，在请求网络，得到网络数据后覆盖缓存
  firstCache,

  /// 先请求网络，失败后再返回缓存
  firstRequest,

  /// 先用缓存，在请求网络，得到网络数据后覆盖缓存，并且请求数据重新抛出去
  /// 因为不能多次抛出结果，我们可以外边写2次
  //firstCacheRequest
}

class MyNetworkCacheManager {
  final String _fileModuleName = "NetworkCacheManager";
  /// 缓存策略
  MyNetworkCachePolicy cachePolicy = MyNetworkCachePolicy.none;
  /// 缓存过期时间（单位：秒）
  int cacheExpirationTime = 24 * 60 * 60;

  /// 获取缓存
  Future<String?> getCacheData(RequestOptions options) async {
    final filePath = _getFilePath(options);
    final fileUtils = FileUtils();
    String? jsonString = await fileUtils.getFile(fileName: filePath, moduleName: _fileModuleName);

    if (jsonString != null) {
      Map<String, dynamic> jsonMap = jsonString.toMap();
      int timestamp = jsonMap['timestamp'];
      // 检查缓存是否过期
      if (DateTime.now().millisecondsSinceEpoch - timestamp < cacheExpirationTime * 1000) {
        return jsonMap['data'];
      }
      // 若缓存过期，删除缓存
      await _remove(options);
      return null;
    }
    return null;
  }

  /// 保存缓存
  Future<void> saveCache(RequestOptions options, String data) async {
    final filePath = _getFilePath(options);
    final fileUtils = FileUtils();
    Map<String, dynamic> cachedData = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': data
    };
    final jsonString = json.encode(cachedData);
    fileUtils.writeFile(fileName: filePath, content: jsonString, moduleName: _fileModuleName);

  }


  Future<void> _remove(RequestOptions options) async{
    final filePath = _getFilePath(options);
    final fileUtils = FileUtils();
    fileUtils.removeFilePath(fileName: filePath,moduleName: _fileModuleName);
  }

  /// 获取文件路径
  String _getFilePath(RequestOptions options) {
    String url = options.uri.toString();
    String paramJsonString = options.queryParameters.toString();
    String method = options.method;
    return (method + url + paramJsonString).md5Hash();
  }
}

