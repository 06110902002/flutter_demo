import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知服务
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '通知栏Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotificationDemoHome(),
    );
  }
}

class NotificationDemoHome extends StatefulWidget {
  const NotificationDemoHome({super.key});

  @override
  State<NotificationDemoHome> createState() => _NotificationDemoHomeState();
}

class _NotificationDemoHomeState extends State<NotificationDemoHome> {
  final NotificationService _notificationService = NotificationService();
  bool _hasPermission = false;
  int _progressValue = 0;
  bool _isProgressActive = false;
  List<ActiveNotification> _activeNotifications = [];

  @override
  void initState() {
    super.initState();
    _checkPermission();
    _refreshActiveNotifications();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await _notificationService.checkPermissions();
    setState(() => _hasPermission = hasPermission as bool);
  }

  Future<void> _requestPermission() async {
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    await _checkPermission();
  }

  Future<void> _refreshActiveNotifications() async {
    final notifications = await _notificationService.getActiveNotifications();
    setState(() {
      _activeNotifications = notifications;
    });
  }

  // 显示普通通知
  Future<void> _showNormalNotification() async {
    await _notificationService.showInstantNotification(
      title: '张三',
      body: '晚上一起吃饭吗？我订了位置，7点见！',
      payload: '{"from":"张三","type":"message"}',
    );
    _refreshActiveNotifications();
    _showSnackBar('✅ 通知已发送，下拉通知栏查看');
  }

  // 显示微信消息通知
  Future<void> _showWeChatMessage() async {
    await _notificationService.showInstantNotification(
      title: '李四',
      body: '在吗？有个事情想请教你',
      payload: '{"from":"李四","type":"wechat"}',
    );
    _refreshActiveNotifications();
    _showSnackBar('✅ 微信消息已发送');
  }

  // 显示长文本通知
  Future<void> _showLongTextNotification() async {
    await _notificationService.showBigTextNotification(
      title: '系统通知',
      body:
          '亲爱的用户，感谢您使用我们的应用。这是一条很长的通知消息，需要展开才能查看完整内容。我们希望通过这条消息向您展示长文本通知的效果，让您了解Flutter通知栏的各种功能。',
      payload: '{"type":"long_text"}',
    );
    _refreshActiveNotifications();
    _showSnackBar('✅ 长文本通知已发送');
  }

  // 显示进度通知
  Future<void> _startProgressNotification() async {
    setState(() {
      _isProgressActive = true;
      _progressValue = 0;
    });

    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 500));

      await _notificationService.showProgressNotification(
        title: '文件下载',
        body: '正在下载更新包...',
        currentProgress: i,
        maxProgress: 100,
      );

      setState(() => _progressValue = i);
    }

    // 下载完成
    await _notificationService.showInstantNotification(
      title: '下载完成',
      body: '更新包已下载完成，点击安装',
      payload: '{"type":"complete"}',
    );

    setState(() => _isProgressActive = false);
    _refreshActiveNotifications();
  }

  // 清除所有通知
  Future<void> _clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    _refreshActiveNotifications();
    _showSnackBar('🗑️ 所有通知已清除');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📱 微信风格通知栏'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshActiveNotifications,
            tooltip: '刷新',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllNotifications,
            tooltip: '清除所有',
          ),
        ],
      ),
      body: Column(
        children: [
          // 权限提示
          if (!_hasPermission)
            Container(
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '需要通知权限才能显示通知',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('授权'),
                  ),
                ],
              ),
            ),

          // 主要内容
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '📨 消息通知',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // 普通消息
                _buildMessageCard(
                  avatar: '👨',
                  name: '张三',
                  message: '晚上一起吃饭吗？我订了位置，7点见！',
                  time: '刚刚',
                  color: Colors.blue,
                  onTap: _hasPermission ? _showNormalNotification : null,
                ),

                // 微信消息
                _buildMessageCard(
                  avatar: '👩',
                  name: '李四',
                  message: '在吗？有个事情想请教你',
                  time: '5分钟前',
                  color: Colors.green,
                  onTap: _hasPermission ? _showWeChatMessage : null,
                ),

                // 系统通知
                _buildMessageCard(
                  avatar: '📢',
                  name: '系统通知',
                  message: '亲爱的用户，感谢您使用我们的应用...',
                  time: '10分钟前',
                  color: Colors.purple,
                  onTap: _hasPermission ? _showLongTextNotification : null,
                ),

                // 进度通知
                _buildMessageCard(
                  avatar: '📥',
                  name: '下载更新',
                  message: _isProgressActive
                      ? '下载中 $_progressValue%'
                      : '点击开始下载',
                  time: '进行中',
                  color: Colors.orange,
                  onTap: _hasPermission && !_isProgressActive
                      ? _startProgressNotification
                      : null,
                ),

                if (_isProgressActive) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progressValue / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                    minHeight: 8,
                  ),
                ],

                const SizedBox(height: 24),

                // 活跃通知列表
                if (_activeNotifications.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    '📋 当前活跃通知',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._activeNotifications.map((notification) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            "notification?.id.toString()",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        title: Text(
                          '无标题',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text('无内容'),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            //await _notificationService.cancelNotification(notification.id!);
                            _refreshActiveNotifications();
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ],

                const SizedBox(height: 16),

                // 使用说明
                Card(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📌 使用说明',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('• 点击任意消息发送通知'),
                        const Text('• 下拉通知栏查看完整内容'),
                        const Text('• 点击通知可查看控制台输出'),
                        const Text('• 右上角垃圾桶图标清除所有通知'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard({
    required String avatar,
    required String name,
    required String message,
    required String time,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 头像
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),

              // 消息内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 发送图标
              if (onTap != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send, color: color, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
