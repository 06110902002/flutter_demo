import 'package:flutter/material.dart';
import 'global_router.dart';
import 'route_config.dart';

class DetailPage extends StatelessWidget {
  final RouteParams? params;

  const DetailPage({super.key, this.params});

  @override
  Widget build(BuildContext context) {
    final id = params?.params?['id'] ?? '未知';
    final name = params?.params?['name'] ?? '未知';

    // 子页面添加 WillPopScope，确保返回时正确出栈
    return WillPopScope(
      onWillPop: () async {
        GlobalRouter.pop();
        return false; // 拦截系统默认行为，避免黑屏
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('详情页')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ID: $id', style: const TextStyle(fontSize: 18)),
              Text('名称: $name', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => GlobalRouter.pop(),
                child: const Text('返回首页'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  GlobalRouter.replace(RouteNames.setting);
                },
                child: const Text('替换为设置页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}