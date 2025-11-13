import 'package:flutter/material.dart';
import 'app_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('路由管理 Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showRouteHistory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 基本路由跳转
            _buildNavigationCard(
              title: '跳转到详情页',
              subtitle: '带参数跳转示例',
              onTap: () => _router.navigateToDetails(context, 1),
            ),

            // 带复杂参数跳转
            _buildNavigationCard(
              title: '带复杂参数跳转',
              subtitle: '传递对象参数',
              onTap: () => _navigateWithComplexParams(context),
            ),

            // 带返回值的跳转
            _buildNavigationCard(
              title: '带返回值跳转',
              subtitle: '等待页面返回数据',
              onTap: () => _navigateForResult(context),
            ),

            // 全屏对话框
            _buildNavigationCard(
              title: '个人资料页',
              subtitle: '全屏对话框样式',
              onTap: () => _router.navigateToProfile(context),
            ),

            // 设置页面
            _buildNavigationCard(
              title: '设置页面',
              subtitle: '普通页面跳转',
              onTap: () => _router.navigateToSettings(context),
            ),

            // 动画页面
            _buildAnimationSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAnimationSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '动画跳转',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('选择不同的页面过渡动画'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAnimationButton(context, '滑动动画', 'slide'),
                _buildAnimationButton(context, '淡入动画', 'fade'),
                _buildAnimationButton(context, '缩放动画', 'scale'),
                _buildAnimationButton(context, '旋转动画', 'rotation'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationButton(BuildContext context, String text, String animationType) {
    return ElevatedButton(
      onPressed: () => _router.navigateWithAnimation(context, animationType),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      child: Text(text),
    );
  }

  void _navigateWithComplexParams(BuildContext context) {
    final complexData = {
      'id': 100,
      'title': '复杂参数示例',
      'description': '这是一个包含复杂数据的参数',
      'timestamp': DateTime.now().toString(),
      'user': {
        'name': '张三',
        'age': 25,
        'email': 'zhangsan@example.com',
      },
      'tags': ['Flutter', 'Dart', '路由', '导航'],
    };

    _router.navigateToDetails(context, 100, extraData: complexData);
  }

  Future<void> _navigateForResult(BuildContext context) async {
    final result = await _router.pushForResult<Map<String, dynamic>>(
      context,
      RoutePaths.settings,
    );

    if (result != null && context.mounted) {
      _showResultDialog(context, result);
    }
  }

  void _showResultDialog(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('返回结果'),
        content: Text('接收到返回数据: $result'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showRouteHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('路由历史'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _router.routeHistory.length,
            itemBuilder: (context, index) {
              final record = _router.routeHistory[index];
              return ListTile(
                title: Text(record.path),
                subtitle: Text(record.timestamp.toString()),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}