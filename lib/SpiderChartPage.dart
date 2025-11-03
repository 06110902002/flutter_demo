import 'dart:math';

import 'package:flutter/material.dart';

//使用绘图的方式，绘制一个蜘蛛图
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蜘蛛图示例',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SpiderChartPage(),
    );
  }
}

class SpiderChartPage extends StatefulWidget {
  @override
  _SpiderChartPageState createState() => _SpiderChartPageState();
}

class _SpiderChartPageState extends State<SpiderChartPage> {
  // 数据：每个维度的值（0-1之间）
  List<double> data = [0.8, 0.6, 0.9, 0.7, 0.5, 0.8];

  // 维度标签
  List<String> labels = ['攻击', '防御', '速度', '技巧', '体力', '智力'];

  // 颜色
  Color chartColor = Colors.blue;
  Color fillColor = Colors.blue.withOpacity(0.3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('蜘蛛图/雷达图'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // 随机生成新数据
                data = List.generate(6, (index) => (0.3 + 0.7 * index / 6));
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          child: SpiderChart(
            data: data,
            labels: labels,
            chartColor: chartColor,
            fillColor: fillColor,
            maxValue: 1.0,
          ),
        ),
      ),
    );
  }
}

class SpiderChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;
  final Color chartColor;
  final Color fillColor;
  final double maxValue;
  final int levels; // 网格层数

  const SpiderChart({
    Key? key,
    required this.data,
    required this.labels,
    this.chartColor = Colors.blue,
    this.fillColor = Colors.blue,
    this.maxValue = 1.0,
    this.levels = 5,
  })  : assert(data.length == labels.length, '数据和标签数量必须相同'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SpiderChartPainter(
        data: data,
        labels: labels,
        chartColor: chartColor,
        fillColor: fillColor,
        maxValue: maxValue,
        levels: levels,
      ),
    );
  }
}

class SpiderChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color chartColor;
  final Color fillColor;
  final double maxValue;
  final int levels;

  SpiderChartPainter({
    required this.data,
    required this.labels,
    required this.chartColor,
    required this.fillColor,
    required this.maxValue,
    required this.levels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8; // 留出边距
    final angleStep = 2 * pi / data.length;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // 1. 绘制网格线和层级
    _drawGrid(canvas, center, radius, angleStep, paint);

    // 2. 绘制轴线
    _drawAxes(canvas, center, radius, angleStep, paint);

    // 3. 绘制数据区域
    _drawDataArea(canvas, center, radius, angleStep);

    // 4. 绘制数据点
    _drawDataPoints(canvas, center, radius, angleStep);

    // 5. 绘制标签
    _drawLabels(canvas, center, radius, angleStep, textPainter, textStyle);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, double angleStep, Paint paint) {
    paint.color = Colors.grey[300]!;

    for (int level = 1; level <= levels; level++) {
      final levelRadius = radius * level / levels;
      final path = Path();

      for (int i = 0; i <= data.length; i++) {
        final angle = i * angleStep - pi / 2; // 从顶部开始
        final x = center.dx + levelRadius * cos(angle);
        final y = center.dy + levelRadius * sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius, double angleStep, Paint paint) {
    paint.color = Colors.grey;
    paint.strokeWidth = 1.0;

    for (int i = 0; i < data.length; i++) {
      final angle = i * angleStep - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius, double angleStep) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    for (int i = 0; i <= data.length; i++) {
      final index = i % data.length;
      final angle = index * angleStep - pi / 2;
      final dataRadius = radius * (data[index] / maxValue);
      final x = center.dx + dataRadius * cos(angle);
      final y = center.dy + dataRadius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius, double angleStep) {
    final pointPaint = Paint()
      ..color = chartColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final angle = i * angleStep - pi / 2;
      final dataRadius = radius * (data[i] / maxValue);
      final x = center.dx + dataRadius * cos(angle);
      final y = center.dy + dataRadius * sin(angle);

      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, double angleStep,
      TextPainter textPainter, TextStyle textStyle) {
    for (int i = 0; i < labels.length; i++) {
      final angle = i * angleStep - pi / 2;
      final labelRadius = radius * 1.1; // 标签在网格外部
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);

      textPainter.text = TextSpan(
        text: '${labels[i]}\n${(data[i] * 100).toInt()}%',
        style: textStyle,
      );
      textPainter.layout();

      // 计算文本位置，使其居中
      final textOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}



