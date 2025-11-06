import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view/user_list_page.dart';
import 'utils/toast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MVVM Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:  UserListPage(),
      navigatorKey: navigatorKey,
    );
  }
}