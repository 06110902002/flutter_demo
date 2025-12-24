/// FileName animate_tag
///
/// @Author 505691285qq.com
/// @Date 2025/12/23 14:37
///
/// @Description 带动画的tag 列表
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// ======================
/// App
/// ======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TagDemoPage(),
    );
  }
}

/// ======================
/// Demo Page
/// ======================
class TagDemoPage extends StatefulWidget {
  const TagDemoPage({super.key});

  @override
  State<TagDemoPage> createState() => _TagDemoPageState();
}

class _TagDemoPageState extends State<TagDemoPage> {
  final List<TagModel> _tags = [
    TagModel(text: 'Flutter', assetIcon: 'assets/imgs/close.png'),
    TagModel(text: '一个非常非常非常长的标签，用来测试自动换行效果', assetIcon: 'assets/imgs/seu.jpg'),
    TagModel(text: 'Android', assetIcon: 'assets/imgs/icon_cry.png'),
    TagModel(text: 'iOS'),
    TagModel(text: 'Web'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Tag Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TagList(
          tags: _tags,
          borderRadius: 20,
          onRemove: (tag) {
            setState(() {
              _tags.remove(tag);
            });
          },
        ),
      ),
    );
  }
}

/// ======================
/// Tag Model
/// ======================
class TagModel {
  final String text;
  final String? assetIcon;

  TagModel({required this.text, this.assetIcon});
}

/// ======================
/// Tag List
/// ======================
class TagList extends StatelessWidget {
  final List<TagModel> tags;
  final double borderRadius;
  final Function(TagModel tag) onRemove;

  const TagList({
    super.key,
    required this.tags,
    required this.onRemove,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: tags.map((tag) {
          return AnimatedTag(
            key: ValueKey(tag.text), // ⭐ 核心
            tag: tag,
            borderRadius: borderRadius,
            onRemove: () => onRemove(tag),
          );
        }).toList(),
      ),
    );
  }
}

/// ======================
/// Animated Tag（核心）
/// ======================
class AnimatedTag extends StatefulWidget {
  final TagModel tag;
  final double borderRadius;
  final VoidCallback onRemove;

  const AnimatedTag({
    super.key,
    required this.tag,
    required this.onRemove,
    required this.borderRadius,
  });

  @override
  State<AnimatedTag> createState() => _AnimatedTagState();
}

class _AnimatedTagState extends State<AnimatedTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scale = Tween(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _opacity = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  void _remove() async {
    if (_isRemoving) return;
    _isRemoving = true;
    await _controller.forward();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: _TagView(
        tag: widget.tag,
        borderRadius: widget.borderRadius,
        onDelete: _remove,
      ),
      builder: (_, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// ======================
/// Tag UI（纯展示）
/// ======================
class _TagView extends StatelessWidget {
  final TagModel tag;
  final double borderRadius;
  final VoidCallback onDelete;

  const _TagView({
    required this.tag,
    required this.borderRadius,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tag.assetIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Image.asset(tag.assetIcon!, width: 16, height: 16),
            ),
          Flexible(child: Text(tag.text, style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
