/// Author: Rambo.Liu
/// Date: 2026/2/9 16:27
/// @Copyright by ZYQL Since 2025
/// Description: TODO
// lib/main.dart
import 'package:flutter/material.dart';

import 'AIChatBubble.dart';
import 'StreamingTextWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI流式文本演示',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const StreamingTextDemo(),
    );
  }
}

class StreamingTextDemo extends StatefulWidget {
  const StreamingTextDemo({Key? key}) : super(key: key);

  @override
  _StreamingTextDemoState createState() => _StreamingTextDemoState();
}

class _StreamingTextDemoState extends State<StreamingTextDemo> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 示例文本
  final String _sampleText = '''
欢迎使用AI流式文本组件！这是一个模拟AI对话中逐字显示效果的Flutter组件。

主要特性：
1. 模拟真实的AI对话逐字显示效果
2. 支持暂停、继续、跳过和重新开始
3. 显示进度条和进度百分比
4. 打字指示器动画
5. 支持自定义显示速度
6. 响应式设计，适配不同屏幕

使用场景：
- AI聊天对话界面
- 故事讲述应用
- 代码演示工具
- 教育类应用中的逐步讲解

这是一个完整的示例，您可以根据需要进行修改和扩展。组件设计为高度可定制，可以调整颜色、速度、样式等参数。

希望这个组件对您的项目有所帮助！''';

  @override
  void initState() {
    super.initState();
    // 添加初始AI消息
    _addAIMessage(_sampleText);
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      _addUserMessage(_textController.text);
      _textController.clear();

      // 模拟AI回复（实际应用中这里应该调用AI API）
      Future.delayed(const Duration(seconds: 1), () {
        _addAIMessage(
          '收到您的消息！这是我为您生成的回复，演示流式文本效果。'
          '这个组件可以很好地模拟AI对话的体验。'
          '您可以在实际项目中集成真正的AI API。',
        );
      });
    }
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
    _addAIMessage(_sampleText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI流式文本演示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
            tooltip: '清空聊天',
          ),
        ],
      ),
      body: Column(
        children: [
          // 标题和描述
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI流式文本组件演示',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '模拟AI对话中的逐字显示效果，支持暂停、继续、跳过等功能',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14),
                ),
              ],
            ),
          ),

          // 独立组件演示
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '独立流式文本组件：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  StreamingTextWidget(
                    text: '这是一个独立的流式文本组件演示。您可以在这里看到文本逐字显示的效果。支持暂停、继续、跳过等控制功能。',
                    speed: const Duration(milliseconds: 250),
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    '速度调节演示：',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  StreamingTextWidget(
                    text: '这是快速显示模式，速度设置为50ms/字符。',
                    speed: const Duration(milliseconds: 50),
                    style: TextStyle(fontSize: 16, color: Colors.green[700]),
                  ),
                  const SizedBox(height: 8),
                  StreamingTextWidget(
                    text: '这是慢速显示模式，速度设置为100ms/字符，适合强调重要内容。',
                    speed: const Duration(milliseconds: 100),
                    style: TextStyle(fontSize: 16, color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // 聊天界面
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // 聊天标题
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'AI聊天演示',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_messages.length} 条消息',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // 消息列表
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(child: Text('暂无消息'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return AIChatBubble(
                              message: message['text'],
                              isUser: message['isUser'],
                              streamingSpeed: const Duration(milliseconds: 20),
                              showTypingIndicator: true,
                            );
                          },
                        ),
                ),

                // 输入区域
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: '输入消息...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
