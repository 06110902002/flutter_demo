import 'package:flutter/material.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/26 14:23
/// @Copyright by ZYQL Since 2025
/// Description: TODO
///
///

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scroll To Index Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ResponsivePage(),
    );
  }
}

class ResponsiveCardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 800;
        final isMediumScreen = constraints.maxWidth > 400;

        return GridView.builder(
          padding: EdgeInsets.all(isLargeScreen ? 20 : 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 4 : (isMediumScreen ? 2 : 1),
            childAspectRatio: isLargeScreen ? 1.2 : 1.5,
            crossAxisSpacing: isLargeScreen ? 20 : 10,
            mainAxisSpacing: isLargeScreen ? 20 : 10,
          ),
          itemBuilder: (context, index) => Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(isLargeScreen ? 20 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue[100],
                      width: double.infinity,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 16 : 8),
                  Text(
                    'Item $index',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isLargeScreen ? 8 : 4),
                  Text(
                    'Description for item $index',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          itemCount: 10,
        );
      },
    );
  }
}

//测试二
class ResponsivePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responsive Layout')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final isTall = constraints.maxHeight > 500;

          if (isWide) {
            // 宽屏布局
            return _buildWideLayout(isTall);
          } else {
            // 窄屏布局
            return _buildNarrowLayout(isTall);
          }
        },
      ),
    );
  }

  Widget _buildWideLayout(bool isTall) {
    return Row(
      children: [
        // 侧边栏
        Container(
          width: 250,
          color: Colors.blueGrey[50],
          child: ListView(
            children: [
              ListTile(title: Text('Dashboard')),
              ListTile(title: Text('Profile')),
              ListTile(title: Text('Settings')),
              ListTile(title: Text('Help')),
            ],
          ),
        ),

        // 主要内容
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: isTall ? _buildTallContent() : _buildShortContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(bool isTall) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (isTall) _buildTallContent() else _buildShortContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTallContent() {
    return Column(
      children: [
        // 多个卡片
        _buildStatCard('Revenue', '\$12,456'),
        _buildStatCard('Users', '1,234'),
        _buildStatCard('Growth', '12.5%'),
        _buildStatCard('Engagement', '78%'),
      ],
    );
  }

  Widget _buildShortContent() {
    return Column(
      children: [
        _buildStatCard('Key Metrics', 'See details'),
        _buildStatCard('Quick Actions', 'View all'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 18, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
