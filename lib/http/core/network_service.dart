import 'dart:async';
import 'package:dio/dio.dart';
import '../../page_frame_work/log/log.dart';
import '../interceptors/custom_cache_Interceptor.dart';
import '../manager/custom_HttpClient_adapter.dart';
import '../manager/my_cache_newwork_manager.dart';
import '../manager/my_dio_manager.dart';
import '../interceptors/data_transform_Interceptor.dart';
import '../interceptors/error_handle_Interceptor.dart';
import '../interceptors/loading_interceptor.dart';
import '../interceptors/refresh_token_interceptors.dart';
import '../interceptors/custom_log_interceptor.dart';
import '../model/my_base_list_model.dart';
import '../model/my_base_model.dart';
import '../model/my_response_model.dart';
import 'my_request_options.dart';

class NetworkService<T> {
  late final Dio _dio = Dio();
  late MyRequestOptions _options;
  List<Interceptor>? _interceptors;
  final List<String> _cancelTokenKey = [];

  NetworkService({List<Interceptor>? interceptors})
      : _interceptors = interceptors {
    _dio.httpClientAdapter = CustomHttpClientAdapter();

    /// 配置拦截器
    configureInterceptors(_interceptors);
  }

  /// 配置options
  void configureOptions(MyRequestOptions options) {
    _options = options;
    _dio.options.baseUrl = _options.baseUrl;
    _dio.options.connectTimeout = _options.connectTimeout;
    _dio.options.receiveTimeout = _options.receiveTimeout;
    _dio.options.headers = _options.headers;
  }

  /// 配置拦截器
  void configureInterceptors(List<Interceptor>? interceptors) {
    // 移除所有拦截器
    _dio.interceptors.clear();
    // 配置拦截器
    List<Interceptor> interceptorList = _interceptors ?? [];
    if (interceptorList.isNotEmpty) {
      for (Interceptor item in interceptorList) {
        _dio.interceptors.add(item);
      }
    } else {
      _addDefaultInterceptors();
    }

    _interceptors = _dio.interceptors;
  }

  /// 添加拦截器
  void _addDefaultInterceptors() {
    // 数据转换拦截器
    _dio.interceptors.add(DataTransformInterceptor());
    // 刷新token
    _dio.interceptors.add(RefreshTokenInterceptor());
    // 缓存拦截器
    MyNetworkCacheManager cacheManager = MyNetworkCacheManager();
    cacheManager.cachePolicy = MyNetworkCachePolicy.none;
    _dio.interceptors.add(CustomCacheInterceptor(cacheManager: cacheManager));
    // 弹窗
    _dio.interceptors.add(LoadingInterceptor(isShowLoading: true));
    // 添加日志打印拦截器
    _dio.interceptors.add(CustomLogInterceptor());
    // 添加错误处理拦截器
    _dio.interceptors.add(ErrorHandleInterceptor(
        isShowHttpErrorMsg: true, isShowDataErrorMsg: true));
  }

// GET 请求方法
  Future<MyBaseModel<T>> get<T>(
      {required MyRequestOptions options,
      required T Function(Object? json) fromJsonT}) async {
    // 配置options
    configureOptions(options);
    _options.method = MyRequestMethod.get;
    // 发起请求
    MyResopnseModel response = await _request(options: options);

    if (response.isHttpSucess() == true) {
      try {
        return MyBaseModel.fromJson(
          response.data,
          fromJsonT,
        );
      } catch (e, stackTrace) {
        Log.error('json转model失败 Stack trace:'
            ' $stackTrace, e:$e');
        rethrow;
      }
    } else {
      throw _handleError(resopnse: response);
    }
  }

// GET 请求方法
  Future<MyBaseListModel<T>> getList<T>(
      {required MyRequestOptions options,
      required T Function(Object? json) fromJsonT}) async {
    // 配置options
    configureOptions(options);
    _options.method = MyRequestMethod.get;
    MyResopnseModel response = await _request(options: options);

    if (response.isHttpSucess() == true) {
      try {
        return MyBaseListModel.fromJson(
          response.data,
          fromJsonT,
        );
      } catch (e, stackTrace) {
        Log.error('json转model失败 Stack trace:'
            ' $stackTrace, e:$e');
        rethrow;
      }
    } else {
      throw _handleError(resopnse: response);
    }
  }

//  POST 请求方法
  Future<MyBaseModel<T>> post<T>(
      {required MyRequestOptions options,
      required T Function(Object? json) fromJsonT}) async {
    // 配置options
    configureOptions(options);
    _options.method = MyRequestMethod.post;
    // 发起请求
    MyResopnseModel response = await _request(options: options);

    if (response.isHttpSucess() == true) {
      try {
        return MyBaseModel.fromJson(
          response.data,
          fromJsonT,
        );
      } catch (e, stackTrace) {
        Log.error('json转model失败 Stack trace:'
            ' $stackTrace, e:$e');
        rethrow;
      }
    } else {
      throw _handleError(resopnse: response);
    }
  }

//  POST 请求方法
  Future<MyBaseListModel<T>> postList<T>(
      {required MyRequestOptions options,
      required T Function(Object? json) fromJsonT}) async {
    // 配置options
    configureOptions(options);
    _options.method = MyRequestMethod.post;
    // 发起请求
    MyResopnseModel response = await _request(options: options);

    if (response.isHttpSucess() == true) {
      try {
        return MyBaseListModel.fromJson(
          response.data,
          fromJsonT,
        );
      } catch (e, stackTrace) {
        Log.error('json转model失败 Stack trace:'
            ' $stackTrace, e:$e');
        rethrow;
      }
    } else {
      throw _handleError(resopnse: response);
    }
  }

  /// 发起请求
  Future<MyResopnseModel> _request({required MyRequestOptions options}) async {
    String tokenKey =
        MyDioManager.instance.getCancelTokenKey(options: _options);
    _cancelTokenKey.add(tokenKey);

    CancelToken cancelToken =
        MyDioManager.instance.getCancelToken(options: _options);
    try {
      Response? response;
      if (options.method == MyRequestMethod.get) {
        response = await _dio.get(
          _options.urlPath,
          queryParameters: _options.params,
          cancelToken: cancelToken,
        );
      } else if (options.method == MyRequestMethod.post) {
        response = await _dio.post(
          _options.urlPath,
          queryParameters: _options.params,
          cancelToken: cancelToken,
        );
      }
      if (response != null) {
        MyResopnseModel resopnseModel = MyResopnseModel(
            requestOptions: options,
            statusCode: response.statusCode,
            responseHeaders: response.headers.map,
            statusMessage: response.statusMessage,
            data: response.data);
        return resopnseModel;
      }
      throw Exception('没有定义的请求方式');
    } on DioException catch (e, stackTrace) {
      // 请求过程出错
      Log.error('''
      请求过程出错 
      Stack trace:$stackTrace
      e:${e.toString()}
      ''');
      throw _handleError(e: e);
    } finally {
      String cancelTokenKey =
          MyDioManager.instance.getCancelTokenKey(options: _options);
      MyDioManager.instance.cancelTokens.remove(cancelTokenKey);
    }
  }

  // 取消全部请求
  void cancelAllRequests() {
    for (String key in _cancelTokenKey) {
      MyDioManager.instance.cancelRequest(key);
    }
  }

  /// 请求过程出错
  String _handleError({MyResopnseModel? resopnse, DioException? e}) {
    return '''
    
      请求错误
      错误响应：${resopnse.toString()}  
      错误具体信息: ${e.toString()}
    ''';
  }
}
