/// Author: Rambo.Liu
/// Date: 2025/12/24 15:24
/// @Copyright by JYXC Since 2023
/// Description: 手势签名
///
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignaturePage(),
    );
  }
}

class Stroke {
  final Path path;

  Stroke(this.path);
}

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  /// 已完成笔画
  final List<Stroke> _strokes = [];

  /// 被撤销的笔画
  final List<Stroke> _redoStack = [];

  /// 当前绘制中的 Path
  Path? _currentPath;
  Offset? _lastPoint;

  /// 用于触发重绘（代替 setState）
  final ValueNotifier<int> _repaintNotifier = ValueNotifier(0);

  /// 用于导出图片
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('高级手写签名'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
          IconButton(icon: const Icon(Icons.delete), onPressed: _clear),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportImage),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: RepaintBoundary(
          key: _repaintKey,
          // 这里使用notify 方式去更新路径数据，而不是使用setState 方式，
          // 手写过程中 不 setState
          // 用 ValueNotifier
          // 性能稳定、无卡顿
          child: ValueListenableBuilder<int>(
            valueListenable: _repaintNotifier,
            builder: (_, __, ___) {
              return CustomPaint(
                painter: SignaturePainter(
                  strokes: _strokes,
                  currentPath: _currentPath,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
      ),
    );
  }

  // ================= 手势 =================

  void _onPanStart(DragStartDetails details) {
    _redoStack.clear();
    _currentPath = Path()
      ..moveTo(details.localPosition.dx, details.localPosition.dy);
    _lastPoint = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final current = details.localPosition;
    final last = _lastPoint;

    if (last != null) {
      // ✨ 二阶贝塞尔曲线（关键）
      final midPoint = Offset(
        (last.dx + current.dx) / 2,
        (last.dy + current.dy) / 2,
      );
      _currentPath!.quadraticBezierTo(
        last.dx,
        last.dy,
        midPoint.dx,
        midPoint.dy,
      );
    }

    _lastPoint = current;
    _repaintNotifier.value++;
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentPath != null) {
      _strokes.add(Stroke(_currentPath!));
      _currentPath = null;
      _lastPoint = null;
      _repaintNotifier.value++;
    }
  }

  // ================= 操作 =================

  void _undo() {
    if (_strokes.isNotEmpty) {
      _redoStack.add(_strokes.removeLast());
      _repaintNotifier.value++;
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      _strokes.add(_redoStack.removeLast());
      _repaintNotifier.value++;
    }
  }

  void _clear() {
    _strokes.clear();
    _redoStack.clear();
    _repaintNotifier.value++;
  }

  // ================= 导出 =================

  Future<void> _exportImage() async {
    final boundary =
        _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 3);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final base64 = base64Encode(pngBytes);

    debugPrint('PNG bytes: ${pngBytes.length}');
    debugPrint('Base64 length: ${base64.length}');
  }
}

class SignaturePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Path? currentPath;

  SignaturePainter({required this.strokes, required this.currentPath});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      canvas.drawPath(stroke.path, paint);
    }

    if (currentPath != null) {
      canvas.drawPath(currentPath!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
