// /// Author: Rambo.Liu
// /// Date: 2026/2/27 17:34
// /// @Copyright by ZYQL Since 2025
// /// Description: TODO
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// // 注意：立即通知不需要 timezone，所以可以不导入（但定时需要）
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
//
// const String channelId = 'default_channel_id';
// const String channelName = 'Default Channel';
// const String channelDescription = 'General notifications';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 初始化通知插件
//   const AndroidInitializationSettings androidSettings =
//       AndroidInitializationSettings('ic_notification'); // 👈 必须用专用图标！
//
//   const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
//     requestAlertPermission: true,
//     requestBadgePermission: true,
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(
//     InitializationSettings(android: androidSettings, iOS: iosSettings),
//     onDidReceiveNotificationResponse: (payload) {
//       print('通知被点击: ${payload.payload}');
//     },
//   );
//
//   runApp(const MyApp());
// }
//
// Future<void> showSimpleNotification() async {
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     channelId,
//     channelName,
//     channelDescription: channelDescription,
//     importance: Importance.high,
//     priority: Priority.high,
//     // 不指定 sound，使用系统默认
//   );
//
//   const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
//
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     '测试通知',
//     '如果你看到这条，说明成功了！🎉',
//     NotificationDetails(android: androidDetails, iOS: iosDetails),
//     payload: 'test_payload',
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('通知测试')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   print('正在发送通知...');
//                   showSimpleNotification();
//                 },
//                 child: const Text('发送立即通知'),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 '注意：\n1. 确保手机未开启勿扰模式\n2. 检查通知权限是否开启',
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

// 必须是顶级函数 - 用于处理后台通知点击
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // 后台通知点击处理
  print('后台通知被点击: ${notificationResponse.payload}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isIOS = false;
  bool _isAndroid = false;

  // 初始化通知
  Future<void> init() async {
    // 初始化时区
    tz.initializeTimeZones();

    // 判断平台
    _isIOS = Platform.isIOS;
    _isAndroid = Platform.isAndroid;

    // Android 初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 初始化设置
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification:
              (int id, String? title, String? body, String? payload) async {
                // iOS通知收到时的回调
                print('iOS收到本地通知: id=$id, title=$title, body=$body');
              },
        );

    // 合并所有平台设置 - 注意这里使用了顶级函数作为后台处理
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // 初始化插件 - 使用正确的后台处理函数
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 前台通知点击事件
        _handleNotificationClick(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // 请求权限
    await _requestPermissions();

    // 创建Android通知渠道
    if (_isAndroid) {
      await _createNotificationChannels();
    }
  }

  // 请求权限
  Future<void> _requestPermissions() async {
    if (_isIOS) {
      // iOS 权限请求
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      print('iOS通知权限请求结果: $granted');
    } else if (_isAndroid) {
      // Android 13+ 需要动态权限
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  // 创建Android通知渠道
  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation == null) return;

    // 主通知渠道
    final AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
      'high_importance_channel',
      '重要通知',
      description: '用于显示重要的即时通知',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 0, 255, 0),
      showBadge: true,
    );

    // 进度通知渠道
    const AndroidNotificationChannel progressChannel =
        AndroidNotificationChannel(
          'progress_channel',
          '进度通知',
          description: '用于显示下载进度等通知',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
          showBadge: false,
        );

    // 创建渠道
    await androidImplementation.createNotificationChannel(mainChannel);
    await androidImplementation.createNotificationChannel(progressChannel);
  }

  // 处理通知点击（前台）
  void _handleNotificationClick(NotificationResponse response) {
    print('通知被点击 - 负载: ${response.payload}');
  }

  // 显示即时通知
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    NotificationDetails notificationDetails;

    if (_isAndroid) {
      // Android通知详情
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'high_importance_channel',
            '重要通知',
            channelDescription: '用于显示重要的即时通知',
            importance: Importance.max,
            priority: Priority.high,
            ticker: '新消息',
            enableVibration: true,
            playSound: true,
            showWhen: true,
            styleInformation: BigTextStyleInformation(''),
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
          );

      notificationDetails = const NotificationDetails(android: androidDetails);
    } else {
      // iOS通知详情
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
      );

      notificationDetails = const NotificationDetails(iOS: iosDetails);
    }

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    print('通知已发送: $title');
  }

  // 显示长文本通知
  Future<void> showBigTextNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (_isAndroid) {
      // 创建大文字风格
      final BigTextStyleInformation bigTextStyle = BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: '点击查看详情',
      );

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'high_importance_channel',
            '重要通知',
            channelDescription: '用于显示重要的即时通知',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigTextStyle,
          );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } else {
      await showInstantNotification(title: title, body: body, payload: payload);
    }
  }

  // 显示进度通知
  Future<void> showProgressNotification({
    required String title,
    required String body,
    required int currentProgress,
    required int maxProgress,
    int id = 3,
  }) async {
    if (_isIOS) {
      // iOS不支持进度通知，改为普通通知
      await showInstantNotification(
        title: title,
        body: '$body ${currentProgress}%',
        payload: 'progress_$currentProgress',
      );
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'progress_channel',
          '进度通知',
          channelDescription: '用于显示下载进度等通知',
          importance: Importance.low,
          priority: Priority.low,
          showProgress: true,
          maxProgress: maxProgress,
          progress: currentProgress,
          onlyAlertOnce: true,
          ongoing: currentProgress < maxProgress,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('所有通知已取消');
  }

  // 取消特定通知
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print('通知已取消: $id');
  }

  // 检查通知权限
  Future<Object> checkPermissions() async {
    if (_isIOS) {
      final result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return result ?? false;
    } else if (_isAndroid) {
      return await Permission.notification.isGranted;
    }
    return false;
  }

  // 获取活跃通知
  Future<List<ActiveNotification>> getActiveNotifications() async {
    return await flutterLocalNotificationsPlugin.getActiveNotifications();
  }
}
