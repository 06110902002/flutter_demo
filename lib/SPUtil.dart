import 'package:shared_preferences/shared_preferences.dart';

class SPUtil {
  // 单例模式
  static SPUtil? _instance;
  static SharedPreferences? _prefs;

  static Future<SPUtil> getInstance() async {
    if (_instance == null) {
      _instance = SPUtil();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // 存储字符串
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // 获取字符串
  String? getString(String key) {
    return _prefs?.getString(key);
  }

  // 存储布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // 获取布尔值
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  // 存储整数
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  // 获取整数
  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  // 删除指定键
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // 清空所有数据
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
