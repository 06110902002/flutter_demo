import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  final int itemId;
  final Map<String, dynamic>? extraData;

  const DetailsPage({
    super.key,
    required this.itemId,
    this.extraData,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _counter = 0;
  String? _userAction;

  @override
  void initState() {
    super.initState();
    print('🔍 详情页初始化 - ID: ${widget.itemId}');
    print('📦 接收到的参数: ${widget.extraData}');
  }

  @override
  void dispose() {
    print('🗑️ 详情页销毁 - ID: ${widget.itemId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('详情页 - ${widget.itemId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareItem,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '项目 ID: ${widget.itemId}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.extraData != null) ...[
                      Text('标题: ${widget.extraData!['title']}'),
                      Text('描述: ${widget.extraData!['description']}'),
                      Text('时间: ${widget.extraData!['timestamp']}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 状态管理
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '页面状态管理',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '计数器: $_counter',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _decrementCounter,
                          child: const Text('减少'),
                        ),
                        ElevatedButton(
                          onPressed: _incrementCounter,
                          child: const Text('增加'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 用户操作
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '用户操作',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('喜欢'),
                          selected: _userAction == 'like',
                          onSelected: (selected) => _setUserAction('like'),
                        ),
                        ChoiceChip(
                          label: const Text('收藏'),
                          selected: _userAction == 'favorite',
                          onSelected: (selected) => _setUserAction('favorite'),
                        ),
                        ChoiceChip(
                          label: const Text('分享'),
                          selected: _userAction == 'share',
                          onSelected: (selected) => _setUserAction('share'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 返回操作
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _returnWithData(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('返回并传递数据'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('简单返回'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  void _setUserAction(String action) {
    setState(() {
      _userAction = action;
    });
  }

  void _shareItem() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('分享功能已触发'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _returnWithData(BuildContext context) {
    final result = {
      'itemId': widget.itemId,
      'finalCount': _counter,
      'userAction': _userAction,
      'message': '从详情页返回的数据',
      'timestamp': DateTime.now().toString(),
    };

    Navigator.pop(context, result);
  }
}