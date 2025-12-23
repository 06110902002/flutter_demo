/// FileName main
///
/// @Author 505691285qq.com
/// @Date 2025/12/17 16:43
///
/// @Description TODO
import 'dart:math' as math;

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverLogo(
              maxExtent: 200.0,
              minExtent: 100.0,
              child: Container(
                color: Colors.blue,
                child: const Center(
                  child: Text(
                    "LOGO",
                    style: TextStyle(color: Colors.white, fontSize: 30),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(title: Text('Item $index')),
                childCount: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Widget 层 =====
class SliverLogo extends SingleChildRenderObjectWidget {
  final double maxExtent;
  final double minExtent;
  final Alignment alignment;

  const SliverLogo({
    Key? key,
    required this.maxExtent,
    required this.minExtent,
    this.alignment = Alignment.center,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderSliverLogo createRenderObject(BuildContext context) {
    return RenderSliverLogo()
      ..maxExtent = maxExtent
      ..minExtent = minExtent
      ..alignment = alignment;
  }

  @override
  void updateRenderObject(BuildContext context, RenderSliverLogo renderObject) {
    renderObject
      ..maxExtent = maxExtent
      ..minExtent = minExtent
      ..alignment = alignment;
  }
}

// ===== Render 层：必须 implements RenderObjectWithChildMixin<RenderObject> =====
class RenderSliverLogo extends RenderSliver
    implements RenderObjectWithChildMixin<RenderObject> {
  double maxExtent = 200;
  double minExtent = 50;
  Alignment alignment = Alignment.center;

  // 注意：内部存储为 RenderObject?，但逻辑上只接受 RenderBox
  RenderObject? _child;

  @override
  RenderObject? get child => _child;

  @override
  set child(RenderObject? value) {
    if (_child != null) dropChild(_child!);
    _child = value;
    if (_child != null) adoptChild(_child!);
  }

  // 提供一个安全的 RenderBox 访问器（用于 layout/paint）
  RenderBox? get childAsBox => _child as RenderBox?;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _child?.attach(owner);
  }

  @override
  void detach() {
    super.detach();
    _child?.detach();
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_child != null) visitor(_child!);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SliverPhysicalParentData) {
      child.parentData = SliverPhysicalParentData();
    }
  }

  @override
  bool debugValidateChild(RenderObject child) {
    return child is RenderBox;
  }

  @override
  void performLayout() {
    if (_child == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final constraints = this.constraints;
    final scrollOffset = constraints.scrollOffset;
    final currentExtent = math.max(minExtent, maxExtent - scrollOffset);

    final boxChild = childAsBox!;
    boxChild.layout(
      BoxConstraints.tightFor(
        width: constraints.viewportMainAxisExtent,
        height: currentExtent,
      ),
      parentUsesSize: true,
    );

    final paintExtent = math.min(
      currentExtent,
      constraints.remainingPaintExtent,
    );
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintExtent: paintExtent,
      maxPaintExtent: maxExtent,
      paintOrigin: 0.0,
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_child == null || geometry!.paintExtent <= 0) return;

    final boxChild = childAsBox!;
    final scrollOffset = constraints.scrollOffset;
    final denominator = maxExtent - minExtent;
    final progress = denominator > 0
        ? math.min(1.0, math.max(0.0, scrollOffset / denominator))
        : 0.0;
    final scale = 1.0 - progress * (1.0 - minExtent / maxExtent);

    final currentExtent = math.max(minExtent, maxExtent - scrollOffset);
    final childHeight = boxChild.size.height;
    final top = (currentExtent - childHeight) / 2;
    final adjustedOffset = Offset(offset.dx, offset.dy + top);

    context.pushTransform(
      needsCompositing,
      adjustedOffset,
      Matrix4.identity()
        ..translate(childHeight / 2, childHeight / 2)
        ..scale(scale)
        ..translate(-childHeight / 2, -childHeight / 2),
      (PaintingContext innerContext, Offset _) {
        innerContext.paintChild(boxChild, Offset.zero);
      },
    );
  }
}
