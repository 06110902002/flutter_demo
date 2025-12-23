/// FileName waterfall_flow
///
/// @Author 505691285qq.com
/// @Date 2025/12/17 11:35
///
/// @Description TODO

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ============================================================================
// 1. 自定义 ParentData：用于存储每个子节点在父容器中的布局信息（如偏移）
// ============================================================================
class WaterfallFlowParentData extends ContainerBoxParentData<RenderBox> {
  // 继承 ContainerBoxParentData，自动获得 nextSibling / previousSibling 链表能力
  // 并可通过 offset 设置子节点位置
}

// ============================================================================
// 2. 自定义 RenderObject：负责实际的布局（layout）、绘制（paint）和点击检测（hit easy_sample）
// ============================================================================
class RenderWaterfallFlow extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, WaterfallFlowParentData> {
  // 布局参数
  int _columnCount;
  double _crossAxisSpacing; // 列间距（水平）
  double _mainAxisSpacing; // 行间距（垂直）

  RenderWaterfallFlow({
    required int columnCount,
    required double crossAxisSpacing,
    required double mainAxisSpacing,
  }) : _columnCount = columnCount,
       _crossAxisSpacing = crossAxisSpacing,
       _mainAxisSpacing = mainAxisSpacing;

  // 提供 setter，支持动态更新并触发重布局
  set columnCount(int value) {
    if (_columnCount == value) return;
    _columnCount = value;
    markNeedsLayout();
  }

  set crossAxisSpacing(double value) {
    if (_crossAxisSpacing == value) return;
    _crossAxisSpacing = value;
    markNeedsLayout();
  }

  set mainAxisSpacing(double value) {
    if (_mainAxisSpacing == value) return;
    _mainAxisSpacing = value;
    markNeedsLayout();
  }

  // 当子节点被添加时，确保其 parentData 是我们自定义的类型
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WaterfallFlowParentData) {
      child.parentData = WaterfallFlowParentData();
    }
  }

  // ============================================================================
  // 核心布局方法：计算每个子节点的位置和自身尺寸
  // ============================================================================
  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;

    // 没有子节点：按约束设置自身尺寸
    if (firstChild == null) {
      size = constraints.biggest.isFinite ? constraints.biggest : Size.zero;
      return;
    }

    final double width = constraints.maxWidth;
    if (width <= 0 || _columnCount <= 0) {
      size = Size.zero;
      return;
    }

    // 计算每列宽度（总宽 - 间距）/ 列数
    final double columnWidth =
        (width - _crossAxisSpacing * (_columnCount - 1)) / _columnCount;
    // 记录每列当前累计高度，用于“填充最短列”策略
    final List<double> columnHeights = List.filled(_columnCount, 0.0);

    // 遍历所有子节点（通过链表：firstChild → nextSibling）
    RenderBox? child = firstChild;
    while (child != null) {
      final WaterfallFlowParentData pd =
          child.parentData! as WaterfallFlowParentData;

      // 找出当前高度最小的列（实现瀑布流错落效果的关键）
      int shortestIndex = 0;
      for (int i = 1; i < _columnCount; i++) {
        if (columnHeights[i] < columnHeights[shortestIndex]) {
          shortestIndex = i;
        }
      }

      // 布局子节点：固定宽度，高度由子节点内容决定（需显式设置 height）
      child.layout(
        BoxConstraints.tightFor(width: columnWidth),
        parentUsesSize: true, // 父级需要子级的尺寸信息
      );

      // 设置子节点在父容器中的偏移位置
      pd.offset = Offset(
        shortestIndex * (columnWidth + _crossAxisSpacing), // X 坐标
        columnHeights[shortestIndex], // Y 坐标
      );

      // 更新该列的高度（加上子节点高度和垂直间距）
      columnHeights[shortestIndex] += child.size.height + _mainAxisSpacing;

      // 移动到下一个子节点
      child = pd.nextSibling;
    }

    // 父容器高度 = 所有列中最大高度
    final double maxHeight = columnHeights.reduce(math.max);
    size = Size(width, maxHeight);
  }

  // ============================================================================
  // 绘制方法：将每个子节点绘制到对应偏移位置
  // ============================================================================
  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final WaterfallFlowParentData pd =
          child.parentData! as WaterfallFlowParentData;
      // 将子节点绘制在其 layout 时计算的偏移位置上
      context.paintChild(child, offset + pd.offset);
      child = pd.nextSibling;
    }
  }

  // ============================================================================
  // 点击检测：从后往前遍历（上层子项优先响应）
  // ============================================================================
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild; // 从最后一个子节点开始（视觉上层）
    while (child != null) {
      final WaterfallFlowParentData pd =
          child.parentData! as WaterfallFlowParentData;

      // 将全局坐标转换为子节点局部坐标，并递归检测
      final bool isHit = result.addWithPaintOffset(
        offset: pd.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );

      if (isHit) return true; // 一旦命中，立即返回
      child = pd.previousSibling; // 反向遍历链表
    }
    return false;
  }
}

// ============================================================================
// 3. 自定义 Element：管理子 Element 生命周期，连接 Widget 与 RenderObject
// ============================================================================
class _WaterfallFlowElement extends RenderObjectElement {
  _WaterfallFlowElement(WaterfallFlow widget) : super(widget);

  @override
  WaterfallFlow get widget => super.widget as WaterfallFlow;

  // 缓存子 Element 列表，用于正确管理生命周期
  final List<Element> _children = [];

  @override
  RenderWaterfallFlow createRenderObject(BuildContext context) {
    return RenderWaterfallFlow(
      columnCount: widget.columnCount,
      crossAxisSpacing: widget.crossAxisSpacing,
      mainAxisSpacing: widget.mainAxisSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderWaterfallFlow renderObject,
  ) {
    renderObject
      ..columnCount = widget.columnCount
      ..crossAxisSpacing = widget.crossAxisSpacing
      ..mainAxisSpacing = widget.mainAxisSpacing;
  }

  // 组件挂载时重建子节点
  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    _rebuildChildren();
  }

  // 组件更新时重建子节点（简化版，生产环境可用 Diff 优化）
  @override
  void update(covariant WaterfallFlow oldWidget) {
    super.update(oldWidget);
    _rebuildChildren();
  }

  // 组件卸载时清理资源
  @override
  void unmount() {
    _clearChildren();
    super.unmount();
  }

  // 清空所有子 Element
  void _clearChildren() {
    for (final element in _children) {
      element.unmount();
    }
    _children.clear();
  }

  // ============================================================================
  // 核心：重建子节点，并自动为每个子项添加点击支持
  // ============================================================================
  void _rebuildChildren() {
    _clearChildren();

    // 获取关联的 RenderObject
    final RenderWaterfallFlow renderObject =
        this.renderObject as RenderWaterfallFlow;
    renderObject.removeAll(); // 清空 Render 层的子节点

    // 遍历所有传入的 children
    for (int i = 0; i < widget.children.length; i++) {
      Widget child = widget.children[i];

      // 如果用户提供了 onTap 回调，则自动包裹 GestureDetector
      if (widget.onTap != null) {
        child = GestureDetector(
          behavior: HitTestBehavior.opaque, // 确保能拦截点击事件
          onTap: () => widget.onTap!(i), // 回调时传入索引
          child: child,
        );
      }

      // 创建子 Element 并加入管理列表
      final Element childElement = inflateWidget(child, null);
      _children.add(childElement);

      // 将子 RenderObject 添加到父 RenderObject 中
      renderObject.add(childElement.renderObject as RenderBox);
    }
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

// ============================================================================
// 4. 自定义 Widget：对外暴露的 API
// ============================================================================
class WaterfallFlow extends RenderObjectWidget {
  final List<Widget> children;
  final int columnCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final void Function(int index)? onTap; // 点击回调，可选

  const WaterfallFlow({
    Key? key,
    required this.children,
    this.columnCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.onTap,
  }) : super(key: key);

  @override
  _WaterfallFlowElement createElement() => _WaterfallFlowElement(this);

  @override
  RenderWaterfallFlow createRenderObject(BuildContext context) {
    return RenderWaterfallFlow(
      columnCount: columnCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderWaterfallFlow renderObject,
  ) {
    renderObject
      ..columnCount = columnCount
      ..crossAxisSpacing = crossAxisSpacing
      ..mainAxisSpacing = mainAxisSpacing;
  }
}

// ============================================================================
// 5. Demo 应用：展示如何使用 WaterfallFlow
// 注意：Scaffold 必须在 MaterialApp 内部，才能使用 ScaffoldMessenger
// ============================================================================
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const WaterfallFlowDemo(), // 将 UI 逻辑移到独立组件，避免 context 问题
    );
  }
}

/// 独立的演示页面，确保 context 在 MaterialApp 作用域内
class WaterfallFlowDemo extends StatelessWidget {
  const WaterfallFlowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waterfall Flow with Tap')),
      body: SingleChildScrollView(
        child: WaterfallFlow(
          columnCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          onTap: (index) {
            // ✅ 此 context 来自 Scaffold 子树，ScaffoldMessenger 可用
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Tapped item $index')));
          },
          children: List.generate(25, (index) {
            final double itemHeight = 100 + (index * 20) % 100;
            return Container(
              height: itemHeight, // ⚠️ 必须显式设置高度，否则瀑布流无效
              color: Colors.grey,
              alignment: Alignment.center,
              child: Text(
                'Item $index\n${itemHeight.toInt()}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
      ),
    );
  }
}
