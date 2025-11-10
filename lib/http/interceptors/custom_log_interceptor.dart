/// @author: jiangjunhui
/// @date: 2025/1/22
library;
import 'package:dio/dio.dart';
import '../../page_frame_work/log/log.dart';
import '../utils/date_untils.dart';


class CustomLogInterceptor extends Interceptor {
  // 用于存储每个请求的开始时间
  Map<RequestOptions, int> requestStartTimeMap = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 记录请求开始时间
    requestStartTimeMap[options] = MyDateTimeUtil.getTimeStamp();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 记录响应日志
    _logResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    // 记录错误日志
    _logError(error);
    handler.next(error);
  }

  // 记录响应日志
  void _logResponse(Response response) {
    // 获取请求开始时间
    int startTime = requestStartTimeMap[response.requestOptions] ?? 0;
    // 当前时间戳
    int entTime = MyDateTimeUtil.getTimeStamp();
    // 从 extra 中读取耗时指标
    final timings = response.requestOptions.extra;
    final options = response.requestOptions;
    Log.error('''
 
      请求方式: ${options.method}
      请求URL: ${options.uri}
      请求Headers: ${options.headers}
      网络请求耗时：${entTime - startTime} ms
      DNS: ${timings['dns']}ms
      TCP: ${timings['tcp']}ms
      SSL: ${timings['ssl']}ms 
      首包: ${timings['first_packet']}ms
      响应状态码: ${response.statusCode}
      响应头：${response.headers}
      响应: ${response.data}
    ''');
  }

  // 记录错误日志
  void _logError(DioException error) {
    // 获取请求开始时间
    int startTime = requestStartTimeMap[error.requestOptions] ?? 0;
    // 当前时间戳
    int entTime = MyDateTimeUtil.getTimeStamp();
    // 从 extra 中读取耗时指标
    final timings =
        error.response?.requestOptions.extra as Map<String, dynamic>;
    final options = error.requestOptions;
    Log.error('''
    网络请求错误:
      请求方式: ${options.method}
      请求URL: ${options.uri}
      请求Headers: ${options.headers}
      网络请求耗时：${entTime - startTime} 毫秒
      DNS: ${timings['dns']}ms
      TCP: ${timings['tcp']}ms
      SSL: ${timings['ssl']}ms 
      首包: ${timings['first_packet']}ms
      ${error.toString()}
    ''');
  }
}
