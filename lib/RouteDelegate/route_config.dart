import 'package:flutter/material.dart';
import 'home_page.dart';
import 'detail_page.dart';
import 'setting_page.dart';

// 路由名称
class RouteNames {
  static const String home = '/';
  static const String detail = '/detail';
  static const String setting = '/setting';
}

// 路由参数模型
class RouteParams {
  final Map<String, String>? params;

  RouteParams({this.params});
}

// 页面映射
final Map<String, Widget Function(BuildContext, RouteParams?)> routePages = {
  RouteNames.home: (context, params) => const HomePage(),
  RouteNames.detail: (context, params) => DetailPage(params: params),
  RouteNames.setting: (context, params) => const SettingPage(),
};