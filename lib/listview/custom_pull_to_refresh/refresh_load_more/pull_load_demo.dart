import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test_flutter/listview/custom_pull_to_refresh/refresh_load_more/pull_to_refresh_list_view.dart';

import '../../../utils/logger_util.dart';

void main() {
  runApp(const MyApp2());
}

Widget buildHeadView(
  BuildContext context,
  ScrollPhase phase,
  bool isHolding,
  bool canRefresh,
  bool refreshCompleted,
  double dragOffset,
) {
  LoggerUtil.d("canRefresh = $canRefresh  dragOffset = $dragOffset");

  // State 1: Refreshing.
  if (isHolding) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Color(0xFFFF4D4F),
          strokeWidth: 2,
        ),
      ),
    );
  }

  // State 2: Completed.
  if (refreshCompleted) {
    return const Center(child: Text("刷新完成"));
  }

  // State 3: Dragging.
  // This block handles both "pulling" and "release to refresh" UI states.
  if (phase == ScrollPhase.dragging) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // This arrow animates its rotation based on the canRefresh state.
          AnimatedRotation(
            turns: canRefresh ? 0.5 : 0, // 0.5 turn = 180 degrees
            duration: const Duration(milliseconds: 250),
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.grey,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 8),
          // The text also changes based on the canRefresh state.
          Text(
            canRefresh ? "松手进行刷新" : "下拉进行刷新",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
  return const SizedBox.shrink();
}

Widget buildFootView(bool loading, bool loadComplete) {
  if (loading) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24.0,
        height: 24.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          color: Color(0xFFFF4D4F),
        ),
      ),
    );
  } else if (loadComplete) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // 整体居中
      children: [
        Container(width: 40, height: 2, color: Colors.black), // 左边横线
        const SizedBox(width: 8),
        const Text("加载完成"), // 中间文本
        const SizedBox(width: 8),
        Container(width: 40, height: 2, color: Colors.black), // 右边横线
      ],
    );
  } else {
    return const SizedBox.shrink();
  }
}

class MyApp2 extends StatefulWidget {
  const MyApp2({super.key});

  @override
  State<MyApp2> createState() => _MyApp2State();
}

class _MyApp2State extends State<MyApp2> {
  List<String> testDatas = ["湖南", "湖北", "山东", "山西", "河南"];

  // Add a refresh ID counter to the parent state.
  int _refreshId = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('PullToRefreshListView Demo')),
        body: PullToRefreshListView(
          headViewBuilder: buildHeadView,
          isOnStartRefresh: true,
          onRefresh: () async {
            // Increment the ID and capture it for this specific operation.
            final currentRefreshId = ++_refreshId;
            LoggerUtil.d(
              "PullToRefreshListView start, operation ID: $currentRefreshId",
            );

            await Future.delayed(const Duration(seconds: 5));

            // *** The Core Logic: The Filter ***
            // Before updating the state, check if this is still the latest operation.
            if (currentRefreshId == _refreshId) {
              print("Operation ID $currentRefreshId is current. Updating UI.");
              // This is the latest refresh task, so we can update the UI.
              setState(() {
                testDatas.clear();
                testDatas.add("广东");
                testDatas.add("广西");
                testDatas.add("河北");
                testDatas.add("江苏");
              });
              LoggerUtil.d(
                "PullToRefreshListView finished, testDatas length = ${testDatas.length}   operation ID: $currentRefreshId",
              );
            } else {
              // This is an outdated task. Its result should be ignored.
              LoggerUtil.d(
                "Ignoring result from outdated operation ID $currentRefreshId (latest is $_refreshId).",
              );
            }
          },
          onLoadMore: () async {
            await Future.delayed(const Duration(seconds: 5));
            setState(() {
              testDatas.clear();
              testDatas.add("河南");
              testDatas.add("河北");
              testDatas.add("山西");
              testDatas.add("贵州");
              testDatas.add("广西");
              testDatas.add("海南");
            });
          },

          footViewBuilder: buildFootView,

          // slivers: [
          //   SliverList(
          //     delegate: SliverChildBuilderDelegate(
          //           (context, index) {
          //         return ListTile(title: Text(testDatas[index]));
          //       },
          //       childCount: testDatas.length,
          //     ),
          //   ),
          // ],

          // 使用 GridView 的新用法
          slivers: [
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return _buildGridItem(index);
              }, childCount: testDatas.length),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建单个网格Item - 带圆角+置顶标签+100%样式还原
  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.all(10),
        color: Colors.yellow,
        height: 100,
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: Image.network(
                "https://picsum.photos/300/200?random=1",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                alignment: Alignment.centerLeft,
                child: Text(
                  testDatas[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
