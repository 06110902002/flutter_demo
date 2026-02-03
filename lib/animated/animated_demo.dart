/// Author: Rambo.Liu
/// Date: 2026/1/26 11:16
/// @Copyright by ZYQL Since 2025
/// Description: TODO

//测试 AnimatedWidget
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: AnimatedBoxPage(), // 修正：指向管理动画的页面，而非直接调用AnimatedBox
//     );
//   }
// }
//
// // 自定义 AnimatedWidget：带动画的盒子
// class AnimatedBox extends AnimatedWidget {
//   // 1. 接收 Animation 对象，传递给父类（required 标识必填）
//   const AnimatedBox({super.key, required Animation<double> animation})
//     : super(listenable: animation);
//
//   // 2. 快捷获取 Animation 对象（简化代码）
//   Animation<double> get _animation => listenable as Animation<double>;
//
//   @override
//   Widget build(BuildContext context) {
//     // 3. 将动画值应用到 Widget 属性上
//     return Container(
//       width: _animation.value,
//       // 宽度随动画值变化
//       height: _animation.value,
//       // 高度随动画值变化
//       color: Colors.blue,
//       alignment: Alignment.center,
//       child: Text(
//         '${_animation.value.toInt()}px',
//         style: const TextStyle(color: Colors.white, fontSize: 20),
//       ),
//     );
//   }
// }
//
// // 页面级 Widget，管理 AnimationController
// class AnimatedBoxPage extends StatefulWidget {
//   const AnimatedBoxPage({super.key});
//
//   @override
//   State<AnimatedBoxPage> createState() => _AnimatedBoxPageState();
// }
//
// class _AnimatedBoxPageState extends State<AnimatedBoxPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     // 1. 创建动画控制器（控制动画时长、播放状态）
//     _controller = AnimationController(
//       vsync: this, // SingleTickerProviderStateMixin 提供帧回调
//       duration: const Duration(seconds: 2),
//     );
//
//     // 2. 创建动画值（从 100 到 300 的线性变化）
//     _animation = Tween<double>(begin: 100, end: 300).animate(_controller);
//
//     // 3. 自动播放动画（往返）
//     _controller.repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose(); // 必须释放控制器，避免内存泄漏
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         // 4. 正确使用：给 AnimatedBox 传入必填的 animation 参数
//         child: AnimatedBox(animation: _animation),
//       ),
//     );
//   }
// }

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:test_flutter/animated/scroll_to_index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll To Index Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Scroll To Index Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const maxCount = 100;
  static const double maxHeight = 1000;
  final random = math.Random();
  final scrollDirection = Axis.vertical;

  late AutoScrollController controller;
  late List<List<int>> randomList;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: scrollDirection,
    );
    randomList = List.generate(
      maxCount,
      (index) => <int>[index, (maxHeight * random.nextDouble()).toInt()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => counter = 0);
              _scrollToCounter();
            },
            icon: Text('First'),
          ),
          IconButton(
            onPressed: () {
              setState(() => counter = maxCount - 1);
              _scrollToCounter();
            },
            icon: Text('Last'),
          ),
        ],
      ),
      body: ListView(
        scrollDirection: scrollDirection,
        controller: controller,
        children: randomList.map<Widget>((data) {
          return Padding(
            padding: EdgeInsets.all(8),
            child: _getRow(data[0], math.max(data[1].toDouble(), 50.0)),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nextCounter,
        tooltip: 'Increment',
        child: Text(counter.toString()),
      ),
    );
  }

  int counter = -1;

  Future _nextCounter() {
    setState(() => counter = (counter + 1) % maxCount);
    return _scrollToCounter();
  }

  Future _scrollToCounter() async {
    await controller.scrollToIndex(
      counter,
      preferPosition: AutoScrollPosition.begin,
    );
    controller.highlight(counter);
  }

  Widget _getRow(int index, double height) {
    return _wrapScrollTag(
      index: index,
      child: Container(
        padding: EdgeInsets.all(8),
        alignment: Alignment.topCenter,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.lightBlue, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('index: $index, height: $height'),
      ),
    );
  }

  Widget _wrapScrollTag({required int index, required Widget child}) =>
      AutoScrollTag(
        key: ValueKey(index),
        controller: controller,
        index: index,
        child: child,
        highlightColor: Colors.black.withOpacity(0.1),
      );
}
