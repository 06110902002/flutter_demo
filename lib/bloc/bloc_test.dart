// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'counter_bloc.dart';
import 'counter_page.dart';

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Flutter Bloc Demo',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: BlocProvider(
                create: (context) => CounterBloc(), // 创建 Bloc 实例
                child: const CounterPage(),
            ),
        );
    }
}