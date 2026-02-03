/// Author: Rambo.Liu
/// Date: 2026/1/26 15:09
/// @Copyright by ZYQL Since 2025
/// Description: 拖动排序的列表
import 'package:flutter/material.dart';

/// 拖动排序的demo
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reorderable List Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ReorderableListPage(),
    );
  }
}

class ReorderableListPage extends StatefulWidget {
  const ReorderableListPage({super.key});

  @override
  State<ReorderableListPage> createState() => _ReorderableListPageState();
}

class _ReorderableListPageState extends State<ReorderableListPage> {
  // 列表数据源
  final List<String> items = List.generate(20, (index) => 'Item $index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('可拖动排序列表')),
      body: ReorderableListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              // 调整 newIndex，因为移除后列表变短了
              newIndex -= 1;
            }
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
          });
        },
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return ListTile(
            key: ValueKey(item), // 必须为每个子项提供唯一的 Key
            title: Text(item),
            tileColor: index.isEven ? Colors.grey[200] : Colors.white,
          );
        }).toList(),
      ),
    );
  }
}
