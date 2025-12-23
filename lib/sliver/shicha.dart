/// FileName shicha
///
/// @Author 505691285qq.com
/// @Date 2025/12/17 17:26
///
/// @Description TODO
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ParallaxDemo());
  }
}

class ParallaxDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // SliverAppBar 提供视差效果的头部区域
          SliverAppBar(
            expandedHeight: 250.0, // 设置展开后的高度
            floating: false, //设置为 false，意味着当滑动到顶部时，AppBar 会完全消失，而不会悬浮在顶部
            pinned: true, //设置为 true，表示 AppBar 会在滚动时固定在顶部，不会消失。
            flexibleSpace: FlexibleSpaceBar(
              title: Text('视差效果'),
              background: Image.network(
                'https://images.unsplash.com/photo-1506748686210-d5c0b6c2da88',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // SliverList 用来显示下方的内容
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                  title: Text('Item #$index'),
                  subtitle: Text('Subtitle for item #$index'),
                );
              },
              childCount: 50, // 设置列表项的数量
            ),
          ),
        ],
      ),
    );
  }
}
