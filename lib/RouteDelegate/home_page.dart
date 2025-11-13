import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'global_router.dart';
import 'route_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    // 页面初始化时刷新路由栈，避免异常
    GlobalRouter.refreshStack();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 关键判断：如果不是首页（理论上不会触发，但防异常）
        if (!GlobalRouter.isHomePage()) {
          GlobalRouter.pop();
          return false;
        }

        // 首页二次退出逻辑
        final now = DateTime.now();
        if (_lastBackPressTime != null &&
            now.difference(_lastBackPressTime!) < const Duration(seconds: 2)) {
          // 退出应用（确保触发系统退出）
          if (Platform.isAndroid) {
            SystemNavigator.pop(animated: true);
          } else if (Platform.isIOS) {
            exit(0);
          }
          return true;
        }

        // 第一次点击：显示提示
        _lastBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('再按一次返回键退出应用'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('首页')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  GlobalRouter.push(
                    RouteNames.detail,
                    params: RouteParams(params: {'id': '1001', 'name': 'Flutter'}),
                  );
                },
                child: const Text('跳转到详情页（带参数）'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  GlobalRouter.push(RouteNames.setting);
                },
                child: const Text('跳转到设置页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}