import 'package:flutter/material.dart';
import 'app_router_delegate.dart';
import 'route_config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // 跳转到详情页（带参数）
                globalRouter.push(
                  RouteNames.detail,
                  params: {'id': '1001', 'name': 'Flutter'},
                );
              },
              child: const Text('跳转到详情页（带参数）'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => globalRouter.push(RouteNames.setting),
              child: const Text('跳转到设置页'),
            ),
          ],
        ),
      ),
    );
  }
}