import 'package:flutter/material.dart';
import 'route_config.dart';

class GlobalRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final List<String> _routeStack = [RouteNames.home]; // 初始栈：仅首页

  // 跳转页面（入栈）
  static Future<T?> push<T extends Object?>(String routeName, {RouteParams? params}) async {
    // 先添加到路由栈，再跳转
    _routeStack.add(routeName);
    final result = await navigatorKey.currentState?.push<T>(
      MaterialPageRoute(
        builder: (context) => routePages[routeName]!(context, params),
      ),
    );
    // 跳转失败/返回时，移除栈中添加的路由（确保栈同步）
    if (_routeStack.last == routeName) {
      _routeStack.removeLast();
    }
    return result;
  }

  // 替换当前页面
  static Future<T?> replace<T extends Object?>(String routeName, {RouteParams? params}) async {
    if (_routeStack.isNotEmpty) _routeStack.removeLast();
    _routeStack.add(routeName);
    return navigatorKey.currentState?.pushReplacement<T, dynamic>(
      MaterialPageRoute(
        builder: (context) => routePages[routeName]!(context, params),
      ),
    );
  }

  // 跳转并清除所有页面
  static Future<T?> pushAndRemoveAll<T extends Object?>(String routeName, {RouteParams? params}) async {
    _routeStack.clear();
    _routeStack.add(routeName);
    return navigatorKey.currentState?.pushAndRemoveUntil<T>(
      MaterialPageRoute(
        builder: (context) => routePages[routeName]!(context, params),
      ),
          (route) => false,
    );
  }

  // 返回上一页（出栈）
  static void pop<T extends Object?>([T? result]) {
    if (_routeStack.length > 1) {
      _routeStack.removeLast();
      navigatorKey.currentState?.pop(result);
    }
  }

  // 是否为首页（关键：确保判断准确）
  static bool isHomePage() {
    return _routeStack.length == 1 && _routeStack.first == RouteNames.home;
  }

  // 强制刷新路由栈（应对异常情况）
  static void refreshStack() {
    if (_routeStack.isEmpty) {
      _routeStack.add(RouteNames.home);
    }
  }
}