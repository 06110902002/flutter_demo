/// Author: Rambo.Liu
/// Date: 2026/1/21 19:53
/// @Copyright by JYXC Since 2023
/// Description: 通过绘图的方式 自定义TabBar 底部指示器
import 'package:flutter/material.dart';

/// 1. 自定义 Decoration：底部圆角矩形
class RoundRectIndicator extends Decoration {
  final double radius;
  final double wantedHeight;
  final Color color;

  const RoundRectIndicator({
    this.radius = 6,
    this.wantedHeight = 4,
    this.color = Colors.blue,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _RoundRectPainter(this, onChanged);
}

/// 2. 真正负责画的东西
class _RoundRectPainter extends BoxPainter {
  final RoundRectIndicator decoration;

  _RoundRectPainter(this.decoration, VoidCallback? onChanged)
    : super(onChanged);

  // @override
  // void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
  //   // 让指示条宽度 == 文字宽度
  //   final width = config.size!.width;
  //   // 贴顶放置，高度 4
  //   final rect = offset & Size(width, decoration.wantedHeight);
  //   final rRect = RRect.fromRectAndRadius(
  //     rect,
  //     Radius.circular(decoration.radius),
  //   );
  //   final paint = Paint()
  //     ..color = decoration.color
  //     ..style = PaintingStyle.fill;
  //   canvas.drawRRect(rRect, paint);
  // }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final width = config.size!.width; // 与文字同宽
    final height = decoration.wantedHeight; // 指示条高度
    final bottomOffset = offset.dy + config.size!.height - height; // 贴底
    final rect = Offset(offset.dx, bottomOffset) & Size(width, height);

    final rRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(decoration.radius),
    );
    final paint = Paint()
      ..color = decoration.color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rRect, paint);
  }
}

/// 3. 主页面
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('自定义 TabBar 指示条'),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label, // 跟随文字宽
            indicator: const RoundRectIndicator(
              radius: 6,
              wantedHeight: 4,
              color: Color(0xFF6750A4),
            ),
            tabs: const [
              Tab(text: '关注'),
              Tab(text: '推荐'),
              Tab(text: '热门'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('关注页面', style: TextStyle(fontSize: 28))),
            Center(child: Text('推荐页面', style: TextStyle(fontSize: 28))),
            Center(child: Text('热门页面', style: TextStyle(fontSize: 28))),
          ],
        ),
      ),
    );
  }
}

/// 4. 入口
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MyHomePage(),
    );
  }
}
