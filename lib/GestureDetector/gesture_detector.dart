import 'package:flutter/material.dart';

/// FileName gesture_detector
///
/// @Author 505691285qq.com
/// @Date 2025/12/24 14:21
///
/// @Description 手势测试

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DragDemoPage(),
    );
  }
}

class DragDemoPage extends StatefulWidget {
  const DragDemoPage({super.key});

  @override
  State<DragDemoPage> createState() => _DragDemoPageState();
}

class _DragDemoPageState extends State<DragDemoPage> {
  /// 当前偏移量
  double offsetX = 0;
  double offsetY = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GestureDetector 拖动示例')),
      body: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // 拖动中持续回调
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              // delta：相对于上一次回调的位移
              offsetX += details.delta.dx;
              offsetY += details.delta.dy;
            });
          },

          // 拖动结束
          onPanEnd: (DragEndDetails details) {
            debugPrint('拖动结束，速度：${details.velocity}');
          },

          child: Transform.translate(
            offset: Offset(offsetX, offsetY),
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              color: Colors.red,
              child: const Text(
                '拖我',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class DragDemoPage extends StatefulWidget {
//   const DragDemoPage({super.key});
//
//   @override
//   State<DragDemoPage> createState() => _DragDemoPageState();
// }
//
// class _DragDemoPageState extends State<DragDemoPage> {
//   double left = 100;
//   double top = 200;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('可重复拖动示例')),
//       body: Stack(
//         children: [
//           Positioned(
//             left: left,
//             top: top,
//             child: GestureDetector(
//               onPanUpdate: (details) {
//                 setState(() {
//                   left += details.delta.dx;
//                   top += details.delta.dy;
//                 });
//               },
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 color: Colors.red,
//                 alignment: Alignment.center,
//                 child: const Text('拖我', style: TextStyle(color: Colors.white)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
