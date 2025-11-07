import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/storage.dart';

/// 主题管理
class ThemeViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _followSystem = true;

  ThemeMode get themeMode => _themeMode;
  bool get followSystem => _followSystem;

  Future<void> init() async {
    _followSystem = await StorageUtil.getFollowSystemTheme();
    _updateThemeMode();
    if (_followSystem) {
      WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
        _updateThemeMode();
        notifyListeners();
      };
    }
    notifyListeners();
  }

  void toggleFollowSystem(bool follow) {
    _followSystem = follow;
    StorageUtil.saveFollowSystemTheme(follow);
    _updateThemeMode();
    notifyListeners();
  }

  void _updateThemeMode() {
    if (_followSystem) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void toggleTheme() {
    if (!_followSystem) {
      _updateThemeMode();
      notifyListeners();
    }
  }
}