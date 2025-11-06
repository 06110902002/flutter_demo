/// @author: jiangjunhui
/// @date: 2024/12/25
library;
import 'package:flutter/material.dart';

import '../log/log.dart';

class MyRouteObserver extends NavigatorObserver {
  static final MyRouteObserver _instance = MyRouteObserver._internal();

  factory MyRouteObserver() {
    return _instance;
  }

  MyRouteObserver._internal();

  final List<Route<dynamic>> routeStack = [];
  final Map<Route<dynamic>, List<RouteAware>> _routeAwareSubscriptions = {};

  /// 订阅路由变化
  void subscribe(RouteAware routeAware, Route<dynamic> route) {
    _routeAwareSubscriptions.putIfAbsent(route, () => []).add(routeAware);
  }

  /// 取消订阅路由变化
  void unsubscribe(RouteAware routeAware) {
    for (final route in _routeAwareSubscriptions.keys) {
      _routeAwareSubscriptions[route]?.remove(routeAware);
    }
  }

  /// 当一个新的路由被推送到导航栈时，此方法会被调用。
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route);
    Log.debug(
        '新的路由被推送到导航栈: ${route.settings.name} param:${route.settings.arguments}, previousRoute= ${previousRoute?.settings.name}');
    _handleRouteVisibility(previousRoute, route);
  }

  /// 当一个路由从导航栈中弹出时，此方法会被调用。route 参数表示被弹出的路由，previousRoute 参数
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.remove(route);
    Log.debug(
        '路由被弹出，当前路由堆栈: ${route.settings.name},param:${route.settings.arguments}, previousRoute= ${previousRoute?.settings.name}');
    _handleRouteVisibility(route, previousRoute);
  }

  /// 当一个路由从导航栈中被移除时，此方法会被调用。移除路由和弹出路由不同，移除操作可以移除导航栈中任意位置的路由，而弹出操作只能移除栈顶的路由。
  /// route 参数表示被移除的路由，previousRoute 参数表示在该路由移除后，其下一个路由（如果存在的话）。
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.remove(route);

    Log.debug(
        '路由被移除，当前路由堆栈: ${route.settings.name}, previousRoute= ${previousRoute?.settings.name}');
    _handleRouteVisibility(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute != null) {
      routeStack.remove(oldRoute);
    }
    if (newRoute != null) {
      routeStack.add(newRoute);
    }
    Log.debug(
        '路由被替换，当前路由堆栈: new= ${newRoute?.settings.name}, old= ${oldRoute?.settings.name}');
    _handleRouteVisibility(oldRoute, newRoute);
  }

  /// 当用户开始进行一个导航手势（如在 iOS 上从屏幕边缘向左滑动返回上一页）时，此方法会被调用。
  /// route 参数表示当前正在操作的路由，previousRoute 参数表示在手势操作后可能会显示的前一个路由（如果存在的话）。
  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    Log.debug('手势事件 didStartUserGesture: ${route.settings.name}, '
        'previousRoute= ${previousRoute?.settings.name}');
  }

  /// 用户结束导航手势时，此方法会被调用。无论手势是否成功完成导航操作，只要手势结束，就会触发这个方法。
  @override
  void didStopUserGesture() {
    Log.debug('手势结束：didStopUserGesture');
  }

  /// 处理路由可见性变化
  void _handleRouteVisibility(
      Route<dynamic>? oldRoute, Route<dynamic>? newRoute) {
    if (oldRoute != null) {
      _notifyRouteAware(oldRoute, false);
    }
    if (newRoute != null) {
      _notifyRouteAware(newRoute, true);
    }
  }

  /// 通知订阅者路由可见性变化
  void _notifyRouteAware(Route<dynamic> route, bool isVisible) {
    final routeAwares = _routeAwareSubscriptions[route];
    if (routeAwares != null) {
      for (final routeAware in routeAwares) {
        if (isVisible) {
          routeAware.didPush();
        } else {
          routeAware.didPopNext();
        }
      }
    }
  }
}
