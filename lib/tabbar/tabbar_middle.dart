/// Author: Rambo.Liu
/// Date: 2025/12/31 10:47
/// @Copyright by JYXC Since 2023
/// Description: tabbar 滑动居中
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '无闪现标签页',
      theme: ThemeData(useMaterial3: true),
      home: TutorialPage(),
    );
  }
}

class TutorialPage extends StatefulWidget {
  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  final PageController _pageController = PageController();
  final ScrollController _listScrollController = ScrollController();

  final List<String> tabTitles = [
    '新手必看',
    '配件使用',
    '云服务',
    '拍摄技巧',
    '剪辑教程',
    '固件升级',
    '创意玩法',
    '故障排查',
    '社区分享',
    '高级调色',
    '延时摄影',
  ];

  final List<GlobalKey> _tabKeys = [];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabKeys.clear();
    for (int i = 0; i < tabTitles.length; i++) {
      _tabKeys.add(GlobalKey(debugLabel: 'tab_key_$i'));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  /// 点击标签：瞬间跳转 + 更新状态 + 滚动标签
  void _onTabTap(int index) {
    if (_currentPage == index) return;

    // 1. 瞬间跳转内容（不经过中间页）
    _pageController.jumpToPage(index);

    // 2. 立即更新高亮状态
    setState(() {
      _currentPage = index;
    });

    // 3. 平滑滚动标签到可视区（制造流畅感）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _tabKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300), // 标签滚动带动画
          curve: Curves.easeOut,
          alignment: 0.5,
        );
      }
    });
  }

  /// 滑动内容时（用户手动滑）：同步高亮
  void _onPageChanged(int index) {
    if (_currentPage == index) return;
    setState(() {
      _currentPage = index;
    });
    // 手动滑动时也滚动标签（可选）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _tabKeys[index];
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: 0.5,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 标题栏
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "基础入门",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "更多 >",
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),

          // 自定义标签栏
          SizedBox(
            height: 40,
            child: ListView.builder(
              controller: _listScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: tabTitles.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final isSelected = _currentPage == index;
                return GestureDetector(
                  key: _tabKeys[index],
                  onTap: () => _onTabTap(index),
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tabTitles[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 内容区域：PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: tabTitles.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildContent(tabTitles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String title) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              children: List.generate(5, (i) => _buildListItem("示例视频 $i")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.play_circle_outline, size: 16, color: Colors.grey[500]),
          SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
