import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService() : dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
    headers: {
      'Content-Type': 'application/json',
    },
  )) {
    dio.interceptors.add(LogInterceptor(responseBody: true));
  }
}