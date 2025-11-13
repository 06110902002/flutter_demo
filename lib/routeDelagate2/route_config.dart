import 'package:flutter/material.dart';
import 'home_page.dart';
import 'detail_page.dart';
import 'setting_page.dart';

class RouteNames {
  static const String home = '/';
  static const String detail = '/detail';
  static const String setting = '/setting';
}

class RouteConfig {
  final String path;
  final Map<String, String>? params;

  RouteConfig(this.path, {this.params});
}

// 修正：页面构建器只需要 context（不需要 RouteConfig，参数通过全局路由获取）
final Map<String, WidgetBuilder> routePages = {
  RouteNames.home: (context) => const HomePage(),
  RouteNames.detail: (context) => const DetailPage(),
  RouteNames.setting: (context) => const SettingPage(),
};