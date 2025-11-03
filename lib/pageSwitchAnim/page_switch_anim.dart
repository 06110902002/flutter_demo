import 'package:flutter/material.dart';

/// Container Transform 页面切换效果，类似android 共享元素动画
void main() {
    runApp(const MaterialApp(
        title: 'Container Transform Demo',
        home: HomePage(),
        debugShowCheckedModeBanner: false,
    ));
}

// 主页面 - 商品列表
class HomePage extends StatelessWidget {
    const HomePage({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('商品列表'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
            ),
            body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                    // 第一个商品卡片（水平布局）
                    _buildHorizontalItem(context, 0),
                    const SizedBox(height: 16),
                    // 第二个商品卡片（水平布局）
                    _buildHorizontalItem(context, 1),
                    const SizedBox(height: 16),
                    // 垂直布局的商品卡片：上图下文
                    _buildVerticalItem(context, 2),
                ],
            ),
        );
    }

    // 水平布局的商品卡片（用于非图片详情）
    Widget _buildHorizontalItem(BuildContext context, int index) {
        return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
                leading: Hero(
                    tag: 'product_image_$index',
                    createRectTween: (begin, end) {
                        return MaterialRectCenterArcTween(begin: begin, end: end);
                    },
                    child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: _getColor(index),
                            borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                            child: Text(
                                '$index',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                ),
                            ),
                        ),
                    ),
                ),
                title: Text(
                    '商品 $index',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('点击查看详情', style: TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DetailPage(index: index, isImageItem: false)),
                    );
                },
            ),
        );
    }

    // 垂直布局的商品卡片：上图下文
    Widget _buildVerticalItem(BuildContext context, int index) {
        return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: InkWell(
                onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DetailPage(index: index, isImageItem: true),
                        ),
                    );
                },
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        // hero + tag 核心实现 类android 共享元素动画
                        Hero(
                            tag: 'product_image_$index',
                            //共享元素  动画插值器
                            createRectTween: (begin, end) {
                                return MaterialRectCenterArcTween(begin: begin, end: end);
                            },
                            child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                    "https://picsum.photos/seed/$index/300/200",
                                    height: 180,
                                    fit: BoxFit.cover,
                                ),
                            ),
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                '这是一张美丽的风景图片，展示了自然的壮丽景色',
                                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    Color _getColor(int index) {
        const colors = [Colors.blue, Colors.green];
        return colors[index % colors.length];
    }
}


// 详情页面 - 根据 isImageItem 切换布局
class DetailPage extends StatelessWidget {
    final int index;
    final bool isImageItem; // 区分是否为图片类 item

    const DetailPage({Key? key, required this.index, required this.isImageItem}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        // 如果是图片类 item，使用新布局（带顶部返回按钮）
        if (isImageItem) {
            return Scaffold(
                body: SafeArea(
                    child: Column(
                        children: [
                            // ========== 新增：顶部导航栏（包含返回按钮）==========
                            Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                    children: [
                                        // 返回按钮（与 SliverAppBar 中样式一致）
                                        IconButton(
                                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                                            onPressed: () => Navigator.pop(context),
                                        ),
                                        const Spacer(), // 将分享按钮推到右边
                                        // 分享按钮保留在顶部右侧（可选，也可保留在下方）
                                        // 如果您希望只在下方显示，可以删除这一行
                                    ],
                                ),
                            ),

                            // ========== 1. 居中大图（Hero 动画）==========
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Hero(
                                    tag: 'product_image_$index',
                                    createRectTween: (begin, end) {
                                        return MaterialRectCenterArcTween(begin: begin, end: end);
                                    },
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                            "https://picsum.photos/seed/$index/400/300",
                                            width: 300,
                                            height: 300,
                                            fit: BoxFit.cover,
                                        ),
                                    ),
                                ),
                            ),

                            // ========== 2. 第一行：右侧分享按钮（距离右边距 20）==========
                            Padding(
                                padding: const EdgeInsets.only(right: 20, bottom: 16),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                        ElevatedButton.icon(
                                            onPressed: () {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('已分享！')),
                                                );
                                            },
                                            icon: const Icon(Icons.share, size: 18),
                                            label: const Text('分享'),
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                ),
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                            ),
                                        ),
                                    ],
                                ),
                            ),

                            // ========== 3. 第二行：图片详细文案（可滚动）==========
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: SingleChildScrollView(
                                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                const Text(
                                                    '图片详情介绍',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                    ),
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                    '这是一张由专业摄影师拍摄的自然风光照片。'
                                                        '画面中展现了壮丽的山脉、清澈的湖泊和蓝天白云，'
                                                        '体现了大自然的宁静与美丽。这张照片拍摄于清晨时分，'
                                                        '阳光斜射在山峰上，形成了迷人的光影效果。'
                                                        '它不仅是一幅视觉享受的作品，也提醒我们要珍惜和保护自然环境。',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[700],
                                                        height: 1.6,
                                                    ),
                                                    textAlign: TextAlign.justify,
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                    '拍摄地点：阿尔卑斯山脉',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                    '拍摄时间：2025年春季',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                ),
                                            ],
                                        ),
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            );
        }

        // 否则使用原来的 Sliver 布局（兼容其他 item）
        return Scaffold(
            body: CustomScrollView(
                slivers: [
                    SliverAppBar(
                        pinned: true,
                        expandedHeight: 280.0,
                        backgroundColor: _getColor(index),
                        flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                                children: [
                                    Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                            padding: const EdgeInsets.only(top: 60),
                                            child: Hero(
                                                tag: 'product_image_$index',
                                                createRectTween: (begin, end) {
                                                    return MaterialRectCenterArcTween(begin: begin, end: end);
                                                },
                                                child: Container(
                                                    width: 120,
                                                    height: 120,
                                                    decoration: BoxDecoration(
                                                        color: _getColor(index).withOpacity(0.9),
                                                        borderRadius: BorderRadius.circular(24),
                                                        boxShadow: [
                                                            BoxShadow(
                                                                color: _getColor(index).withOpacity(0.3),
                                                                blurRadius: 20,
                                                                offset: const Offset(0, 10),
                                                            ),
                                                        ],
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                            '$index',
                                                            style: const TextStyle(
                                                                fontSize: 60,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                            color: Colors.white,
                        ),
                    ),
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                                (context, i) {
                                return ListTile(
                                    title: Text('详情内容 $i'),
                                    subtitle: Text('这是第 $i 项的详细信息'),
                                    leading: Container(
                                        width: 40,
                                        height: 40,
                                        color: _getColor((index + i) % 2),
                                        child: Center(
                                            child: Text('$i', style: const TextStyle(color: Colors.white)),
                                        ),
                                    ),
                                );
                            },
                            childCount: 20,
                        ),
                    ),
                ],
            ),
        );
    }

    Color _getColor(int index) {
        const colors = [Colors.blue, Colors.green];
        return colors[index % colors.length];
    }
}