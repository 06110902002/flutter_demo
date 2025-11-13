import 'package:flutter/material.dart';
import 'app_router_delegate.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取所有深链接参数（通用方式，支持任意参数）
    final allParams = globalRouter.currentPageParams;

    // 按需获取参数（不存在则返回默认值）
    final id = allParams?['id'] ?? '未知';
    final name = allParams?['name'] ?? '未知';
    final age = allParams?['age'] ?? '未知';
    // 新增参数直接获取（无需修改解析逻辑）
    final gender = allParams?['gender'] ?? '未知';
    final address = allParams?['address'] ?? '未知';

    return Scaffold(
      appBar: AppBar(
        title: const Text('详情页（支持任意参数）'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => globalRouter.popRoute(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('深链接传递的所有参数：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // 显示已知参数
            Text('ID: $id', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('姓名: $name', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('年龄: $age', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('性别: $gender', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('地址: $address', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            // 显示所有参数（动态遍历，不管多少个都能显示）
            Text('完整参数列表：', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...allParams?.entries.map((entry) => Text('${entry.key}: ${entry.value}')) ?? [],
          ],
        ),
      ),
    );
  }
}