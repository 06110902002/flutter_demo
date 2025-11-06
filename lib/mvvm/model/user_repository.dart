import 'package:dio/dio.dart';
import '../utils/api.dart';
import 'user.dart';

class UserRepository {
  final ApiService _api = ApiService();

  Future<List<User>> getUsers() async {
    try {
      Response response = await _api.dio.get('/users');
      List<dynamic> data = response.data ?? [];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('获取用户列表失败：${e.toString()}');
    }
  }

  Future<User> getUserDetail(int id) async {
    try {
      Response response = await _api.dio.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('获取用户详情失败：${e.toString()}');
    }
  }
}