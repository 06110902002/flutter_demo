import 'package:flutter/material.dart';
import 'app_router.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouter _router = AppRouter();

  @override
  void initState() {
    super.initState();
    // 添加路由监听器
    _router.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    _router.removeListener(_onRouteChanged);
    _router.dispose();
    super.dispose();
  }

  void _onRouteChanged() {
    print('路由变化: ${_router.currentRoute}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter 路由管理 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: _router.routerConfig,
      debugShowCheckedModeBanner: false,
    );
  }
}