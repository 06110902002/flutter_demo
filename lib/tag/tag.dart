/// FileName tag
///
/// @Author 505691285qq.com
/// @Date 2025/12/22 19:45
///
/// @Description TODO
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
    return MaterialApp(
      title: 'Tag Demo',
      home: const TagDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// ======================
/// Demo 页面
/// ======================
class TagDemoPage extends StatefulWidget {
  const TagDemoPage({super.key});

  @override
  State<TagDemoPage> createState() => _TagDemoPageState();
}

class _TagDemoPageState extends State<TagDemoPage> {
  final List<TagModel> _tags = [
    TagModel(text: 'Flutter', icon: Icons.flutter_dash),
    TagModel(text: 'Dart', assetIcon: 'assets/imgs/close.png'),
    TagModel(text: '一个非常非常非常长的标签文本，用来测试自动换行效果'),
    TagModel(text: 'Android'),
    TagModel(text: 'iOS'),
    TagModel(text: '前端'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tag List Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TagList(
          tags: _tags,
          borderRadius: 20,
          onDelete: (index) {
            setState(() {
              _tags.removeAt(index);
            });
          },
        ),
      ),
    );
  }
}

/// ======================
/// Tag 数据模型
/// ======================
class TagModel {
  final String text;
  final IconData? icon;
  final String? assetIcon; // 本地图片路径

  TagModel({required this.text, this.icon, this.assetIcon});
}

/// ======================
/// Tag 列表组件
/// ======================
class TagList extends StatelessWidget {
  final List<TagModel> tags;
  final double borderRadius;
  final Function(int index)? onDelete;

  const TagList({
    super.key,
    required this.tags,
    this.borderRadius = 16,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10, // tag 横向间距
        runSpacing: 10, // 换行后的纵向间距
        children: List.generate(tags.length, (index) {
          return TagItem(
            tag: tags[index],
            borderRadius: borderRadius,
            onDelete: () => onDelete?.call(index),
          );
        }),
      ),
    );
  }
}

/// ======================
/// 单个 Tag 组件
/// ======================
class TagItem extends StatelessWidget {
  final TagModel tag;
  final double borderRadius;
  final VoidCallback? onDelete;

  const TagItem({
    super.key,
    required this.tag,
    required this.borderRadius,
    this.onDelete,
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
        mainAxisSize: MainAxisSize.min, // ⭐ 关键：内容自适应
        children: [
          /// 左侧图标
          if (tag.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(tag.icon, size: 16, color: Colors.blue),
            ),

          /// 左侧 icon（来自 assets）
          if (tag.assetIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Image.asset(
                tag.assetIcon!,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
            ),

          /// 中间文本
          Flexible(
            child: Text(
              tag.text,
              style: const TextStyle(fontSize: 14),
              softWrap: true,
            ),
          ),

          /// 右侧删除按钮
          if (onDelete != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
