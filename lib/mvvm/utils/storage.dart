import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static Future<void> saveFollowSystemTheme(bool follow) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('follow_system_theme', follow);
  }

  static Future<bool> getFollowSystemTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('follow_system_theme') ?? true;
  }
}