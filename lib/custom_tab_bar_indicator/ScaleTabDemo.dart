/// Author: Rambo.Liu
/// Date: 2026/1/22 10:16
/// @Copyright by ZYQL Since 2025
/// Description: TabBar 滑动时绽放的demo
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/* =========================================================
 * 1. 带动态放大 Tab 的页面
 * =========================================================*/
class ScaleTabDemo extends StatefulWidget {
  const ScaleTabDemo({super.key});

  @override
  State<ScaleTabDemo> createState() => _ScaleTabDemoState();
}

class _ScaleTabDemoState extends State<ScaleTabDemo>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  /* 根据滑动进度算缩放 */
  double _scale(int index) {
    final double page = _tabCtrl.animation!.value;
    final double diff = (page - index).abs();
    if (diff >= 1) return 0.95; // 远离当前页
    return 0.95 + 0.30 * (1 - diff); // 当前页 1.25，左右递减
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('滑动放大 Tab'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: List.generate(4, (index) {
            /* 每个 Tab 都监听 animation */
            return AnimatedBuilder(
              animation: _tabCtrl.animation!,
              builder: (_, __) {
                final scale = _scale(index);
                return Transform.scale(
                  scale: scale,
                  child: Tab(
                    icon: const Icon(Icons.home, size: 26),
                    text: 'Tab$index',
                  ),
                );
              },
            );
          }),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: List.generate(
          4,
          (i) => Center(
            child: Text('Page $i', style: const TextStyle(fontSize: 40)),
          ),
        ),
      ),
    );
  }
}

/* =========================================================
 * 2. 入口
 * =========================================================*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.purple),
      home: const ScaleTabDemo(),
    );
  }
}
