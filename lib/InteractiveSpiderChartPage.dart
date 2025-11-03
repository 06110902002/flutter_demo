
import 'dart:math';

import 'package:flutter/material.dart';

//使用绘图的方式，带动画方式绘制一个蜘蛛图

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '交互式蜘蛛图',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: InteractiveSpiderChartPage(),
    );
  }
}

class InteractiveSpiderChartPage extends StatefulWidget {
  @override
  _InteractiveSpiderChartPageState createState() => _InteractiveSpiderChartPageState();
}

class _InteractiveSpiderChartPageState extends State<InteractiveSpiderChartPage> {
  // 多组数据示例
  final List<SpiderChartDataSet> _dataSets = [
    SpiderChartDataSet(
      name: '角色A',
      data: [0.8, 0.6, 0.9, 0.7, 0.5, 0.8],
      color: Colors.blue,
    ),
    SpiderChartDataSet(
      name: '角色B',
      data: [0.5, 0.8, 0.6, 0.9, 0.7, 0.6],
      color: Colors.red,
    ),
    SpiderChartDataSet(
      name: '角色C',
      data: [0.9, 0.5, 0.7, 0.6, 0.8, 0.9],
      color: Colors.green,
    ),
  ];

  int _currentDataSetIndex = 0;
  bool _showAllData = false;
  final List<String> _labels = ['攻击', '防御', '速度', '技巧', '体力', '智力'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('交互式蜘蛛图'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 控制面板
          _buildControlPanel(),

          // 图表区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedSpiderChart(
                dataSets: _showAllData ? _dataSets : [_dataSets[_currentDataSetIndex]],
                labels: _labels,
                animationDuration: const Duration(milliseconds: 800),
              ),
            ),
          ),

          // 图例
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '数据控制',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // 数据集选择
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ..._dataSets.asMap().entries.map((entry) {
                  final index = entry.key;
                  final dataSet = entry.value;
                  return ChoiceChip(
                    label: Text(dataSet.name),
                    selected: _currentDataSetIndex == index && !_showAllData,
                    onSelected: (selected) {
                      setState(() {
                        _currentDataSetIndex = index;
                        _showAllData = false;
                      });
                    },
                  );
                }),
              ],
            ),
            SizedBox(height: 12),

            // 显示所有数据开关
            SwitchListTile(
              title: Text('显示所有数据'),
              value: _showAllData,
              onChanged: (value) {
                setState(() {
                  _showAllData = value;
                });
              },
            ),

            // 随机数据按钮
            ElevatedButton.icon(
              icon: Icon(Icons.shuffle),
              label: Text('生成随机数据'),
              onPressed: _generateRandomData,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: _dataSets.map((dataSet) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: dataSet.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                dataSet.name,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _generateRandomData() {
    setState(() {
      for (final dataSet in _dataSets) {
        dataSet.data = List.generate(6, (index) => (0.2 + 0.8 * Random().nextDouble()));
      }
    });
  }
}

// 数据集类
class SpiderChartDataSet {
  final String name;
  List<double> data;
  final Color color;

  SpiderChartDataSet({
    required this.name,
    required this.data,
    required this.color,
  });
}

// 动画蜘蛛图组件
class AnimatedSpiderChart extends StatefulWidget {
  final List<SpiderChartDataSet> dataSets;
  final List<String> labels;
  final Duration animationDuration;
  final double size;

  const AnimatedSpiderChart({
    Key? key,
    required this.dataSets,
    required this.labels,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.size = 300,
  })  :
        super(key: key);

  @override
  _AnimatedSpiderChartState createState() => _AnimatedSpiderChartState();
}

class _AnimatedSpiderChartState extends State<AnimatedSpiderChart>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dataAnimations;
  late List<SpiderChartDataSet> _previousDataSets;
  List<SpiderChartDataSet> get _currentDataSets => widget.dataSets;

  @override
  void initState() {
    super.initState();
    _previousDataSets = _createZeroDataSets();
    _initializeAnimations();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedSpiderChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dataSets != widget.dataSets) {
      _previousDataSets = oldWidget.dataSets;
      _initializeAnimations();
      _animationController.forward(from: 0.0);
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // 为每个数据点的每个维度创建动画
    _dataAnimations = [];
    for (int dataSetIndex = 0; dataSetIndex < _currentDataSets.length; dataSetIndex++) {
      for (int dimension = 0; dimension < widget.labels.length; dimension++) {
        final previousValue = dataSetIndex < _previousDataSets.length
            ? _previousDataSets[dataSetIndex].data[dimension]
            : 0.0;
        final currentValue = _currentDataSets[dataSetIndex].data[dimension];

        final animation = Tween<double>(
          begin: previousValue,
          end: currentValue,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOutCubic,
        ));

        _dataAnimations.add(animation);
      }
    }
  }

  List<SpiderChartDataSet> _createZeroDataSets() {
    return widget.dataSets.map((dataSet) {
      return SpiderChartDataSet(
        name: dataSet.name,
        data: List.filled(dataSet.data.length, 0.0),
        color: dataSet.color,
      );
    }).toList();
  }

  List<SpiderChartDataSet> _getAnimatedDataSets() {
    final animatedDataSets = <SpiderChartDataSet>[];
    int animationIndex = 0;

    for (int dataSetIndex = 0; dataSetIndex < _currentDataSets.length; dataSetIndex++) {
      final originalDataSet = _currentDataSets[dataSetIndex];
      final animatedData = <double>[];

      for (int dimension = 0; dimension < widget.labels.length; dimension++) {
        animatedData.add(_dataAnimations[animationIndex].value);
        animationIndex++;
      }

      animatedDataSets.add(SpiderChartDataSet(
        name: originalDataSet.name,
        data: animatedData,
        color: originalDataSet.color,
      ));
    }

    return animatedDataSets;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animatedDataSets = _getAnimatedDataSets();

        return Container(
          width: widget.size,
          height: widget.size,
          child: InteractiveSpiderChartPainter(
            dataSets: animatedDataSets,
            labels: widget.labels,
            maxValue: 1.0,
            levels: 5,
            onPointHover: (dataSetIndex, dimensionIndex, value) {
              // 可以在这里添加悬停效果
              print('悬停: ${animatedDataSets[dataSetIndex].name} - ${widget.labels[dimensionIndex]}: ${(value * 100).toStringAsFixed(1)}%');
            },
          ),
        );
      },
    );
  }
}

// 交互式蜘蛛图绘制器
class InteractiveSpiderChartPainter extends StatelessWidget {
  final List<SpiderChartDataSet> dataSets;
  final List<String> labels;
  final double maxValue;
  final int levels;
  final Function(int dataSetIndex, int dimensionIndex, double value)? onPointHover;

  const InteractiveSpiderChartPainter({
    Key? key,
    required this.dataSets,
    required this.labels,
    this.maxValue = 1.0,
    this.levels = 5,
    this.onPointHover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => _handleHover(event, context),
      child: CustomPaint(
        painter: _SpiderChartPainter(
          dataSets: dataSets,
          labels: labels,
          maxValue: maxValue,
          levels: levels,
        ),
      ),
    );
  }

  void _handleHover(PointerEvent event, BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(event.position);
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final angleStep = 2 * pi / labels.length;

    // 计算悬停位置相对于中心的角度和距离
    final delta = localPosition - center;
    final distance = delta.distance;
    final angle = atan2(delta.dy, delta.dx) + pi / 2; // 调整角度从顶部开始

    if (distance <= radius) {
      // 找到最近的维度
      int closestDimension = 0;
      double minAngleDiff = double.infinity;

      for (int i = 0; i < labels.length; i++) {
        final dimensionAngle = i * angleStep;
        final angleDiff = (angle - dimensionAngle).abs();
        final normalizedAngleDiff = min(angleDiff, 2 * pi - angleDiff);

        if (normalizedAngleDiff < minAngleDiff) {
          minAngleDiff = normalizedAngleDiff;
          closestDimension = i;
        }
      }

      // 计算相对值
      final relativeDistance = distance / radius;

      // 调用悬停回调
      for (int dataSetIndex = 0; dataSetIndex < dataSets.length; dataSetIndex++) {
        final dataSet = dataSets[dataSetIndex];
        final dataRadius = radius * (dataSet.data[closestDimension] / maxValue);
        final dataDistance = (localPosition - center).distance;

        if (dataDistance <= dataRadius + 10 && dataDistance >= dataRadius - 10) {
          onPointHover?.call(dataSetIndex, closestDimension, dataSet.data[closestDimension]);
          break;
        }
      }
    }
  }
}

class _SpiderChartPainter extends CustomPainter {
  final List<SpiderChartDataSet> dataSets;
  final List<String> labels;
  final double maxValue;
  final int levels;

  _SpiderChartPainter({
    required this.dataSets,
    required this.labels,
    required this.maxValue,
    required this.levels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    print("431-------------width = ${size.width}  height = ${size.height}");
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final angleStep = 2 * pi / labels.length;

    // 绘制网格和轴线
    _drawGrid(canvas, center, radius, angleStep);
    _drawAxes(canvas, center, radius, angleStep);

    // 绘制数据区域（从后往前绘制，确保前面的数据覆盖后面的）
    for (int i = dataSets.length - 1; i >= 0; i--) {
      _drawDataArea(canvas, center, radius, angleStep, dataSets[i]);
    }

    // 绘制数据点和标签
    for (final dataSet in dataSets) {
      _drawDataPoints(canvas, center, radius, angleStep, dataSet);
    }
    _drawLabels(canvas, center, radius, angleStep);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius, double angleStep) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.grey[300]!;

    // 绘制同心圆网格
    for (int level = 1; level <= levels; level++) {
      final levelRadius = radius * level / levels;
      final path = Path();

      for (int i = 0; i <= labels.length; i++) {
        final angle = i * angleStep - pi / 2;
        final x = center.dx + levelRadius * cos(angle);
        final y = center.dy + levelRadius * sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(path, paint);

      // 绘制层级标签
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(level / levels * 100).toInt()}%',
          style: TextStyle(color: Colors.grey, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(center.dx + 5, center.dy - levelRadius - 6),
      );
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius, double angleStep) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.grey;

    for (int i = 0; i < labels.length; i++) {
      final angle = i * angleStep - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius, double angleStep, SpiderChartDataSet dataSet) {
    final fillPaint = Paint()
      ..color = dataSet.color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = dataSet.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    for (int i = 0; i <= labels.length; i++) {
      final index = i % labels.length;
      final angle = index * angleStep - pi / 2;
      final dataRadius = radius * (dataSet.data[index] / maxValue);
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

  void _drawDataPoints(Canvas canvas, Offset center, double radius, double angleStep, SpiderChartDataSet dataSet) {
    final pointPaint = Paint()
      ..color = dataSet.color
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < labels.length; i++) {
      final angle = i * angleStep - pi / 2;
      final dataRadius = radius * (dataSet.data[i] / maxValue);
      final x = center.dx + dataRadius * cos(angle);
      final y = center.dy + dataRadius * sin(angle);
      final point = Offset(x, y);

      // 绘制白色外圈
      canvas.drawCircle(point, 6, outlinePaint);
      // 绘制数据点
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, double angleStep) {
    final textStyle = TextStyle(
      color: Colors.black87,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i < labels.length; i++) {
      final angle = i * angleStep - pi / 2;
      final labelRadius = radius * 1.15;
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(text: labels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // 根据角度调整文本对齐方式
      double offsetX, offsetY;
      if (cos(angle).abs() > 0.5) {
        // 左右两侧
        offsetX = x - (cos(angle) > 0 ? 0 : textPainter.width);
        offsetY = y - textPainter.height / 2;
      } else {
        // 上下两侧
        offsetX = x - textPainter.width / 2;
        offsetY = y - (sin(angle) > 0 ? textPainter.height : 0);
      }

      textPainter.paint(canvas, Offset(offsetX, offsetY));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}