/// FileName animated_widget
///
/// @Author 505691285qq.com
/// @Date 2025/12/23 15:44
///
/// @Description 使用动画控制控件的宽度
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: WidthAnimationDemo());
  }
}

class WidthAnimationDemo extends StatefulWidget {
  const WidthAnimationDemo({super.key});

  @override
  State<WidthAnimationDemo> createState() => _WidthAnimationDemoState();
}

class _WidthAnimationDemoState extends State<WidthAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _widthAnimation = Tween<double>(
      begin: 50,
      end: 300,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('左锚点宽度动画')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.centerLeft,
          // ⭐ 左边锚点实现：Flutter 里最简单、最标准的做法是：给 Container 一个左对齐约束
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: _widthAnimation.value,
                height: 60,
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text('左锚点', style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.reset();
          _controller.forward();
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
