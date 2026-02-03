/// Author: Rambo.Liu
/// Date: 2026/1/21 20:03
/// @Copyright by JYXC Since 2023
/// Description: 使用图片作为 tabbar indicator
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

/* =============== 1. 图片指示器（提前加载版） =============== */
class ImageIndicator extends Decoration {
  final double wantedHeight;
  final String assetPath;
  final ui.Image? _image; // 允许 null，但必须在构造函数里初始化

  /* 私有构造：把图片一次性塞进来 */
  ImageIndicator._(this.wantedHeight, this.assetPath, this._image);

  /* 工厂：异步加载图片 → 返回已准备好的指示器 */
  static Future<ImageIndicator> create({
    required String assetPath,
    double wantedHeight = 4,
  }) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return ImageIndicator._(wantedHeight, assetPath, frame.image);
  }

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _ImagePainter(this, onChanged);
  }
}

/* =============== 2. 同步 painter =============== */
class _ImagePainter extends BoxPainter {
  final ImageIndicator decoration;

  _ImagePainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final image = decoration._image;
    if (image == null) return; // 还没加载好，先不画

    final width = config.size!.width;
    final height = decoration.wantedHeight;
    final bottomOffset = offset.dy + config.size!.height - height;

    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(offset.dx, bottomOffset, width, height);

    canvas.drawImageRect(image, src, dst, Paint());
  }
}

/* =============== 3. 主页面（FutureBuilder 加载指示器） =============== */
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageIndicator>(
      /* 提前加载图片 */
      future: ImageIndicator.create(
        assetPath: 'assets/imgs/tianmao.jpg',
        wantedHeight: 10,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final indicator = snapshot.data!;

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('图片指示器 TabBar'),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicator: indicator, // <-- 同步使用，不再 async
                tabs: const [
                  Tab(text: '关注'),
                  Tab(text: '推荐'),
                  Tab(text: '热门'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                Center(child: Text('关注页面', style: TextStyle(fontSize: 28))),
                Center(child: Text('推荐页面', style: TextStyle(fontSize: 28))),
                Center(child: Text('热门页面', style: TextStyle(fontSize: 28))),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* =============== 4. 入口 =============== */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const MyHomePage(),
    );
  }
}
