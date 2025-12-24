/// FileName range_slide
///
/// @Author 505691285qq.com
/// @Date 2025/12/23 17:31
///
/// @Description 滑动实现价格选择demo

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RangeSliderDemoPage(),
    );
  }
}

class RangeSliderDemoPage extends StatelessWidget {
  const RangeSliderDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('范围滑动选择 Demo')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: RangeSliderBar(
          min: 0,
          max: 100,
          onValueChange: (double leftValue, double rightValue) =>
              print('leftValue: $leftValue, rightValue: $rightValue'),
        ),
      ),
    );
  }
}

enum ActiveThumb { none, left, right }

typedef OnValueChange = void Function(double leftValue, double rightValue);

/// =======================
/// 范围滑动选择组件
/// =======================
class RangeSliderBar extends StatefulWidget {
  final double min;
  final double max;
  final OnValueChange? onValueChange;

  const RangeSliderBar({
    super.key,
    required this.min,
    required this.max,
    this.onValueChange,
  });

  @override
  State<RangeSliderBar> createState() => _RangeSliderBarState();
}

class _RangeSliderBarState extends State<RangeSliderBar> {
  late double _leftValue;
  late double _rightValue;

  static const double _barHeight = 6;
  static const double _tooltipOffset = 10;
  static const double _tooltipWidth = 44;
  static const double _tooltipHeight = 34;
  late ActiveThumb _activeThumb = ActiveThumb.none;

  @override
  void initState() {
    super.initState();
    _leftValue = widget.min;
    _rightValue = widget.max;
  }

  double _dxFromValue(double value, double trackWidth) {
    return (value - widget.min) / (widget.max - widget.min) * trackWidth;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        /// 最小 value 间距（等价于一个滑块宽度）
        final minGapValue =
            _tooltipWidth / trackWidth * (widget.max - widget.min);

        final leftDx = _dxFromValue(_leftValue, trackWidth);
        final rightDx = _dxFromValue(_rightValue, trackWidth);
        if (widget.onValueChange != null) {
          widget.onValueChange!(_leftValue, _rightValue);
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('最小值: ${_leftValue.toStringAsFixed(0)}'),
                Text('最大值: ${_rightValue.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 70,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  /// 进度条
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: _barHeight,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  /// 选中区域
                  // Positioned(
                  //   top: 40,
                  //   left: leftDx,
                  //   width: rightDx - leftDx,
                  //   child: Container(height: _barHeight, color: Colors.grey),
                  // ),
                  Positioned(
                    top: 40,
                    left: leftDx,
                    right: trackWidth - rightDx,
                    child: _ActiveRangeBar(activeThumb: _activeThumb),
                  ),

                  /// 左滑块
                  Positioned(
                    left: leftDx - _tooltipWidth / 2,
                    top: 40 - _tooltipOffset - _tooltipHeight,
                    child: _DraggableTooltip(
                      value: _leftValue,
                      trackWidth: trackWidth,
                      isActive: _activeThumb == ActiveThumb.left,
                      isDimmed: _activeThumb == ActiveThumb.right,
                      onActiveChange: (active) {
                        setState(() {
                          _activeThumb = active
                              ? ActiveThumb.left
                              : ActiveThumb.none;
                        });
                      },
                      onDelta: (deltaRatio) {
                        setState(() {
                          _leftValue =
                              (_leftValue +
                                      deltaRatio * (widget.max - widget.min))
                                  .clamp(widget.min, _rightValue - minGapValue);
                        });
                      },
                    ),
                  ),

                  /// 右滑块
                  Positioned(
                    left: rightDx - _tooltipWidth / 2,
                    top: 40 - _tooltipOffset - _tooltipHeight,
                    child: _DraggableTooltip(
                      value: _rightValue,
                      trackWidth: trackWidth,
                      isActive: _activeThumb == ActiveThumb.right,
                      isDimmed: _activeThumb == ActiveThumb.left,
                      onActiveChange: (active) {
                        setState(() {
                          _activeThumb = active
                              ? ActiveThumb.right
                              : ActiveThumb.none;
                        });
                      },
                      onDelta: (deltaRatio) {
                        setState(() {
                          _rightValue =
                              (_rightValue +
                                      deltaRatio * (widget.max - widget.min))
                                  .clamp(_leftValue + minGapValue, widget.max);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

///把“选中区域”封装成一个 Widget（推荐）
///好处:不污染主 build ,动画逻辑集中,后续好维护
class _ActiveRangeBar extends StatelessWidget {
  final ActiveThumb activeThumb;

  const _ActiveRangeBar({required this.activeThumb});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: _gradientFor(activeThumb),
      ),
    );
  }

  LinearGradient _gradientFor(ActiveThumb thumb) {
    const active = Color(0xFF8A8A8A);
    const inactive = Color(0xFFBDBDBD);

    switch (thumb) {
      case ActiveThumb.left:
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [active, inactive],
        );
      case ActiveThumb.right:
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [inactive, active],
        );
      case ActiveThumb.none:
      default:
        return const LinearGradient(colors: [inactive, inactive]);
    }
  }
}

/// =======================
/// 可拖动 Tooltip
/// =======================
// class _DraggableTooltip extends StatelessWidget {
//   final double value;
//   final double trackWidth;
//   final ValueChanged<double> onDelta;
//
//   const _DraggableTooltip({
//     required this.value,
//     required this.trackWidth,
//     required this.onDelta,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onPanUpdate: (details) {
//         final deltaRatio = details.delta.dx / trackWidth;
//         onDelta(deltaRatio);
//       },
//       child: TooltipThumb(value: value),
//     );
//   }
// }

/// 带动画版本
class _DraggableTooltip extends StatefulWidget {
  final double value;
  final double trackWidth;
  final ValueChanged<double> onDelta;

  final bool isActive;
  final bool isDimmed;
  final ValueChanged<bool> onActiveChange;

  const _DraggableTooltip({
    required this.value,
    required this.trackWidth,
    required this.onDelta,
    required this.isActive,
    required this.isDimmed,
    required this.onActiveChange,
  });

  @override
  State<_DraggableTooltip> createState() => _DraggableTooltipState();
}

class _DraggableTooltipState extends State<_DraggableTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDown() {
    widget.onActiveChange(true);
    _controller.forward();
  }

  void _onUp() {
    widget.onActiveChange(false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 行为控制（behavior）
      // HitTestBehavior
      // 决定点击是否能命中 Widget
      // behavior: HitTestBehavior.opaque,
      //
      // 值	              说明
      // deferToChild	    默认，子组件响应
      // opaque	          整个区域可点击
      // translucent	    透明区域也可点击
      behavior: HitTestBehavior.translucent,
      onPanDown: (_) => _onDown(),
      onPanCancel: _onUp,
      onPanEnd: (_) => _onUp(),
      onPanUpdate: (details) {
        final deltaRatio = details.delta.dx / widget.trackWidth;
        widget.onDelta(deltaRatio);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: widget.isDimmed ? 0.4 : 1.0,
        child: ScaleTransition(
          scale: _scale,
          alignment: Alignment.bottomCenter,
          child: TooltipThumb(value: widget.value),
        ),
      ),
    );
  }
}

/// =======================
/// Tooltip UI
/// =======================
class TooltipThumb extends StatelessWidget {
  final double value;

  const TooltipThumb({super.key, required this.value});

  static const double _triangleHeight = 6;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TooltipPainter(),
      child: SizedBox(
        width: 44,
        height: 34,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _triangleHeight),
          child: Center(
            child: Text(
              value.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TooltipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    const triangleHeight = 6.0;
    const radius = 6.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height - triangleHeight);

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));

    final path = Path()
      ..addRRect(rrect)
      ..moveTo(size.width / 2 - 6, size.height - triangleHeight)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + 6, size.height - triangleHeight)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
