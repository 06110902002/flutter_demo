import 'package:flutter/material.dart';
import 'app_router_delegate.dart';
import 'app_route_parser.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Route 无报错 Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerDelegate: globalRouter,
      routeInformationParser: AppRouteParser(),
      debugShowCheckedModeBanner: false,
    );
  }
}