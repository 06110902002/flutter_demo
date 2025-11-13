import 'package:flutter/material.dart';
import 'global_router.dart';
import 'route_config.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        GlobalRouter.pop();
        return false; // 拦截系统默认行为，避免黑屏
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('设置页')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => GlobalRouter.pop(),
                child: const Text('返回'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  GlobalRouter.pushAndRemoveAll(RouteNames.home);
                },
                child: const Text('返回首页（清除栈）'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}