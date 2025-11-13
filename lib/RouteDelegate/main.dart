import 'package:flutter/material.dart';
import 'global_router.dart';
import 'home_page.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Route Demo',
            theme: ThemeData(primarySwatch: Colors.blue),
            // 使用全局 Navigator Key
            navigatorKey: GlobalRouter.navigatorKey,
            home: const HomePage(),
        );
    }
}