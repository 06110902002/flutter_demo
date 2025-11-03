import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('CustomPaint Example')),
        body: Center(
          child: Container(
            width: 300,
            height: 300,
            color: Colors.yellow, // 这是"画布的背景"
            child: ClipRect(
              child: CustomPaint(  // 这是"画布"
                size: Size(200, 200),
                painter: MyPainter(),// // 这是"画家"，可以在画布上任意绘制 ← 但 painter 可以绘制到父容器区域
              ),

            )

          )

        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

    // 先绘制背景，了解实际绘制区域
    final backgroundPaint = Paint()..color = Colors.red.withOpacity(0.3);
    canvas.drawRect(Offset.zero & size, backgroundPaint);



    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 150, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
