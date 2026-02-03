/// Author: Rambo.Liu
/// Date: 2026/1/22 09:56
/// @Copyright by ZYQL Since 2025
/// Description: TabBar 底部动画的demo
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/* =========================================================
 * 1. 带动画的自定义指示器
 *    – 入场：x 方向滑入 + 缩放
 *    – 切换：小幅弹跳
 * =========================================================*/
class AnimatedIndicator extends Decoration {
  final double height;
  final Color color;
  final BorderRadius radius;
  final AnimationController? controller; // 外部传入，控制弹跳

  const AnimatedIndicator({
    this.height = 4,
    this.color = Colors.blue,
    this.radius = const BorderRadius.all(Radius.circular(4)),
    this.controller,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _AnimatedPainter(this, onChanged, controller);
  }
}

class _AnimatedPainter extends BoxPainter {
  final AnimatedIndicator decoration;
  final AnimationController? _ctrl;

  _AnimatedPainter(this.decoration, VoidCallback? onChanged, this._ctrl)
    : super(onChanged) {
    // 让 DecoratedBox 在动画过程中不断重绘
    _ctrl?.addListener(() => onChanged?.call());
  }

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final width = config.size!.width;
    final rect = offset & Size(width, decoration.height);

    // 入场动画：x 滑入 + 缩放
    final slide = (config.size!.width - rect.width) / 2;
    final progress = _ctrl?.value ?? 1.0;
    final scale = 0.8 + 0.2 * Curves.elasticOut.transform(progress);
    final animOffset = Offset(slide * (1 - progress), 0);

    canvas.save();
    canvas.translate(animOffset.dx, 0);
    canvas.scale(scale, 1);

    final rRect = RRect.fromRectAndRadius(rect, decoration.radius.topLeft);
    final paint = Paint()
      ..color = decoration.color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rRect, paint);

    canvas.restore();
  }
}

/* =========================================================
 * 2. 主页面：TabBar + TabBarView + 动画控制器
 * =========================================================*/
class AnimatedTabDemo extends StatefulWidget {
  const AnimatedTabDemo({super.key});

  @override
  State<AnimatedTabDemo> createState() => _AnimatedTabDemoState();
}

class _AnimatedTabDemoState extends State<AnimatedTabDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // 入场动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /* 每次切换 Tab 都触发一次小弹跳 */
  void _onTabChange(int index) {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('带动画的指示条'),
          bottom: TabBar(
            indicator: AnimatedIndicator(
              height: 6,
              color: Colors.deepPurpleAccent,
              radius: const BorderRadius.all(Radius.circular(6)),
              controller: _controller,
            ),
            indicatorSize: TabBarIndicatorSize.label,
            onTap: _onTabChange,
            tabs: const [
              Tab(text: '关注'),
              Tab(text: '推荐'),
              Tab(text: '热门'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('关注', style: TextStyle(fontSize: 40))),
            Center(child: Text('推荐', style: TextStyle(fontSize: 40))),
            Center(child: Text('热门', style: TextStyle(fontSize: 40))),
          ],
        ),
      ),
    );
  }
}

/* =========================================================
 * 3. 入口
 * =========================================================*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const AnimatedTabDemo(),
    );
  }
}
