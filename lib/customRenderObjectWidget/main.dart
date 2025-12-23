/// FileName main
///
/// @Author 505691285qq.com
/// @Date 2025/12/17 11:18
///
/// @Description TODO
import 'package:flutter/material.dart';

// 1. 自定义 RenderObject
class RenderCustomBox extends RenderBox {
  String _text;
  Color _color;

  RenderCustomBox({required String text, required Color color})
    : _text = text,
      _color = color;

  String get text => _text;

  set text(String value) {
    if (_text == value) return;
    _text = value;
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  Color get color => _color;

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsPaint();
  }

  @override
  void performLayout() {
    size = constraints.constrain(Size(200, 100));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.drawRect(offset & size, Paint()..color = _color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: _text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      offset +
          Offset(
            (size.width - textPainter.width) / 2,
            (size.height - textPainter.height) / 2,
          ),
    );
  }
}

// 2. 自定义 Element
class _CustomBoxElement extends RenderObjectElement {
  _CustomBoxElement(CustomBox widget) : super(widget);

  @override
  CustomBox get widget => super.widget as CustomBox;

  @override
  RenderCustomBox createRenderObject(BuildContext context) {
    return RenderCustomBox(text: widget.text, color: widget.color);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderCustomBox renderObject,
  ) {
    renderObject
      ..text = widget.text
      ..color = widget.color;
  }

  @override
  void insertRenderObjectChild(
    covariant RenderObject child,
    covariant Object? slot,
  ) {
    // TODO: implement insertRenderObjectChild
  }

  @override
  void moveRenderObjectChild(
    covariant RenderObject child,
    covariant Object? oldSlot,
    covariant Object? newSlot,
  ) {
    // TODO: implement moveRenderObjectChild
  }

  @override
  void removeRenderObjectChild(
    covariant RenderObject child,
    covariant Object? slot,
  ) {
    // TODO: implement removeRenderObjectChild
  }
}

// 3. 自定义 Widget：继承 RenderObjectWidget，并正确实现所有方法
class CustomBox extends RenderObjectWidget {
  final String text;
  final Color color;

  const CustomBox({Key? key, required this.text, required this.color})
    : super(key: key);

  @override
  _CustomBoxElement createElement() => _CustomBoxElement(this);

  // ✅ 关键修复：不要抛异常！提供有效实现（即使可能不被使用）
  @override
  RenderCustomBox createRenderObject(BuildContext context) {
    return RenderCustomBox(text: text, color: color);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderCustomBox renderObject,
  ) {
    renderObject
      ..text = text
      ..color = color;
  }
}

// 4. Demo App
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String currentText = 'Hello';
  Color currentColor = Colors.blue;

  void _change() {
    setState(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      currentText = ['Flutter', 'Render', 'Object', 'Demo'][now % 4];
      currentColor = [
        Colors.red,
        Colors.green,
        Colors.purple,
        Colors.orange,
      ][now % 4];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Fixed Custom RenderObjectWidget')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomBox(text: currentText, color: currentColor),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: _change, child: const Text('Change')),
            ],
          ),
        ),
      ),
    );
  }
}
