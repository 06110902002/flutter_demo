
import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:test_flutter/page_frame_work/router/router_observer.dart';
import 'package:test_flutter/page_frame_work/router/router_url.dart';


import '../log/log.dart';

enum MyRouterEnum { push, go }

class MyRouter {
  /// 功能描述 路由跳转
  static Future<T?> router<T extends Object?>(
      {required RouterURL routerURL,
      required BuildContext context,
      Map<String, dynamic>? param,
      MyRouterEnum routerType = MyRouterEnum.push}) {
    final name = routerURL.name;
    Map<String, dynamic> queryParameters = param ?? <String, dynamic>{};
    if (routerType == MyRouterEnum.push) {
      return context.pushNamed(name, queryParameters: queryParameters);
    } else {
      context.goNamed(name, queryParameters: queryParameters);
      return Future.value();
    }
  }

  /// pop 返回
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    if (context.canPop()) {
      context.pop(result);
    } else {
      assert(false, '不能pop');
    }
  }

  /// 返回到指定界面
  static void popUntil(
      {required BuildContext context, required RouterURL routerURL}) {
    try {
      List<Route<dynamic>> list = getAllRoutes();
      bool isCanPop = false;
      for (Route _router in list) {
        if(_router.settings.name == routerURL.name) {
          isCanPop = true;
        }
      }

      if (isCanPop) {
        final name = routerURL.name;
        Navigator.popUntil(context, ModalRoute.withName(name));
      } else {
        assert(false, '不能pop');
      }

    } catch (e) {
      Log.error("返回到指定界面错误：${e.toString()}");
    }
  }


  /// 到根
  static void backToRoot({required BuildContext context}) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  /// 是否到最底层路由
  static bool isEmptyRoute({required BuildContext context}) {
    Navigator.of(context).popUntil((route) {
      return true;
    });
    return false;
  }

  /// 获取当前路由栈里面的全部路由
  static List<Route<dynamic>> getAllRoutes() {
    final MyRouteObserver routeObserver = MyRouteObserver();
    List<Route<dynamic>> routes = routeObserver.routeStack;
    return routes;
  }
}
