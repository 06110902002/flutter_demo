/// Author: Rambo.Liu
/// Date: 2026/2/9 16:44
/// @Copyright by ZYQL Since 2025
/// Description: TODO
// lib/main.dart - 修复后的完整代码
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const AIStreamingTextDemoApp());
}

class AIStreamingTextDemoApp extends StatelessWidget {
  const AIStreamingTextDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI流式文本 - 增强版',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// ================== 增强版流式文本组件 ==================

class EnhancedStreamingText extends StatefulWidget {
  final String text;
  Duration speed;
  final TextStyle style;
  final TextAlign textAlign;
  final VoidCallback? onComplete;
  final bool autoStart;
  final int maxLines;
  final TextOverflow overflow;
  final bool showControls;
  final bool showProgress;
  final Color? cursorColor;
  final bool showCursor;
  final Duration cursorBlinkSpeed;
  final Function(int)? onCharacterTyped;

  EnhancedStreamingText({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 30),
    this.style = const TextStyle(fontSize: 16, color: Colors.black),
    this.textAlign = TextAlign.left,
    this.onComplete,
    this.autoStart = true,
    this.maxLines = 10,
    this.overflow = TextOverflow.ellipsis,
    this.showControls = true,
    this.showProgress = true,
    this.cursorColor = Colors.blue,
    this.showCursor = true,
    this.cursorBlinkSpeed = const Duration(milliseconds: 500),
    this.onCharacterTyped,
  });

  @override
  _EnhancedStreamingTextState createState() => _EnhancedStreamingTextState();
}

class _EnhancedStreamingTextState extends State<EnhancedStreamingText>
    with SingleTickerProviderStateMixin {
  late String _displayText;
  late int _currentIndex;
  Timer? _timer;
  late AnimationController _cursorController;
  bool _isCursorVisible = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _displayText = '';
    _currentIndex = 0;

    _cursorController =
        AnimationController(duration: widget.cursorBlinkSpeed, vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _isCursorVisible = !_isCursorVisible;
              });
              _cursorController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              setState(() {
                _isCursorVisible = !_isCursorVisible;
              });
              _cursorController.forward();
            }
          });

    if (widget.autoStart && widget.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startStreaming();
      });
    }
  }

  void _startStreaming() {
    if (_timer != null) {
      _timer!.cancel();
    }

    _isPlaying = true;
    _cursorController.forward();

    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText += widget.text[_currentIndex];
          _currentIndex++;
          widget.onCharacterTyped?.call(_currentIndex);
        });
      } else {
        timer.cancel();
        _isPlaying = false;
        _cursorController.stop();
        setState(() {
          _isCursorVisible = false;
        });
        widget.onComplete?.call();
      }
    });
  }

  void pauseStreaming() {
    _timer?.cancel();
    _isPlaying = false;
    _cursorController.stop();
  }

  void resumeStreaming() {
    if (_currentIndex < widget.text.length) {
      _startStreaming();
    }
  }

  void skipToEnd() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _displayText = widget.text;
      _currentIndex = widget.text.length;
      _isPlaying = false;
      _isCursorVisible = false;
    });
    _cursorController.stop();
    widget.onComplete?.call();
  }

  void restartStreaming() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _displayText = '';
      _currentIndex = 0;
      _isPlaying = false;
    });
    _startStreaming();
  }

  void setSpeed(Duration newSpeed) {
    if (_timer != null && _timer!.isActive) {
      pauseStreaming();
      widget.speed = newSpeed;
      resumeStreaming();
    } else {
      widget.speed = newSpeed;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Stack(
            children: [
              Text(
                _displayText,
                style: widget.style,
                textAlign: widget.textAlign,
                maxLines: widget.maxLines,
                overflow: widget.overflow,
              ),

              if (widget.showCursor && _isPlaying && _isCursorVisible)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    height: widget.style.fontSize ?? 16,
                    color: widget.cursorColor,
                  ),
                ),
            ],
          ),
        ),

        if (widget.showControls) ...[
          const SizedBox(height: 12),
          _buildControlPanel(),
        ],

        if (widget.showProgress) ...[
          const SizedBox(height: 12),
          _buildProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildControlPanel() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 速度选择部分 - 改为垂直布局或可滚动
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('速度:', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                // 使用Wrap或可滚动的Row
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSpeedButton(
                        '极慢',
                        const Duration(milliseconds: 100),
                      ),
                      const SizedBox(width: 4),
                      _buildSpeedButton('慢', const Duration(milliseconds: 50)),
                      const SizedBox(width: 4),
                      _buildSpeedButton('正常', const Duration(milliseconds: 30)),
                      const SizedBox(width: 4),
                      _buildSpeedButton('快', const Duration(milliseconds: 15)),
                      const SizedBox(width: 4),
                      _buildSpeedButton('极快', const Duration(milliseconds: 5)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 播放控制 - 使用Wrap或调整布局
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: restartStreaming,
                  icon: const Icon(Icons.replay, size: 16),
                  label: const Text('重新开始'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[800],
                    minimumSize: const Size(0, 36),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _isPlaying ? pauseStreaming : resumeStreaming,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(_isPlaying ? '暂停' : '继续'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying
                        ? Colors.orange[100]
                        : Colors.green[100],
                    foregroundColor: _isPlaying
                        ? Colors.orange[800]
                        : Colors.green[800],
                    minimumSize: const Size(0, 36),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: skipToEnd,
                  icon: const Icon(Icons.fast_forward, size: 16),
                  label: const Text('跳过'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                    foregroundColor: Colors.blue[800],
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedButton(String label, Duration speed) {
    final isActive = widget.speed == speed;
    return GestureDetector(
      onTap: () => setSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isActive ? Colors.blue : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.blue[800] : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final percentage = widget.text.isEmpty
        ? 0.0
        : (_currentIndex / widget.text.length * 100);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: widget.text.isEmpty ? 0 : _currentIndex / widget.text.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(percentage),
            ),
            minHeight: 12,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getProgressColor(percentage).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: _getProgressColor(percentage)),
              ),
              child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(percentage),
                ),
              ),
            ),

            Text(
              '$_currentIndex/${widget.text.length} 字符',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),

            Text(
              _getTimeEstimate(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }

  String _getTimeEstimate() {
    if (_currentIndex == 0 || !_isPlaying) return '--:--';

    final elapsedTime = _currentIndex * widget.speed.inMilliseconds;
    final totalTime = widget.text.length * widget.speed.inMilliseconds;
    final remainingTime = totalTime - elapsedTime;

    final seconds = (remainingTime / 1000).ceil();
    if (seconds < 60) {
      return '剩余 ${seconds}秒';
    } else {
      final minutes = (seconds / 60).ceil();
      return '剩余 ${minutes}分钟';
    }
  }
}

// ================== AI 聊天气泡组件 ==================

class AIChatBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final Duration streamingSpeed;
  final VoidCallback? onStreamingComplete;
  final bool showTypingIndicator;

  const AIChatBubble({
    super.key,
    required this.message,
    this.isUser = false,
    this.streamingSpeed = const Duration(milliseconds: 20),
    this.onStreamingComplete,
    this.showTypingIndicator = false,
  });

  @override
  _AIChatBubbleState createState() => _AIChatBubbleState();
}

class _AIChatBubbleState extends State<AIChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _typingController;
  bool _isStreamingComplete = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  void _onStreamingComplete() {
    setState(() {
      _isStreamingComplete = true;
    });
    widget.onStreamingComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.purple[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: widget.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.isUser ? '您' : 'AI助手',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  constraints: const BoxConstraints(minWidth: 50),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.isUser ? Colors.blue[50] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.isUser
                          ? Colors.blue[100]!
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.isUser)
                        Text(
                          widget.message,
                          style: const TextStyle(fontSize: 16),
                        )
                      else
                        EnhancedStreamingText(
                          text: widget.message,
                          speed: widget.streamingSpeed,
                          style: const TextStyle(fontSize: 16),
                          onComplete: _onStreamingComplete,
                          autoStart: true,
                          showControls: false,
                          showCursor: true,
                        ),

                      if (!widget.isUser &&
                          !_isStreamingComplete &&
                          widget.showTypingIndicator)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildTypingIndicator(),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatTime(DateTime.now()),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),

          if (widget.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.teal[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTypingDot(0),
        const SizedBox(width: 4),
        _buildTypingDot(200),
        const SizedBox(width: 4),
        _buildTypingDot(400),
      ],
    );
  }

  Widget _buildTypingDot(int delay) {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        return Opacity(
          opacity: _typingController.value > (delay / 1000) ? 1.0 : 0.3,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

// ================== 主页面 ==================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentTab = 0;
  final PageController _pageController = PageController();
  final List<Map<String, dynamic>> _chatMessages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 示例文本
  final String _longSampleText = '''
**Flutter 流式文本组件测试**

这是一个完整的增强版流式文本组件测试示例，展示所有功能：

🔧 **核心功能**
1. 模拟AI对话的逐字显示效果
2. 支持多种速度调节（极慢、慢、正常、快、极快）
3. 实时进度显示和彩色进度条
4. 闪烁光标效果
5. 完整的控制面板（暂停、继续、跳过、重新开始）

📊 **进度反馈**
- 彩色进度条（红→橙→绿）
- 精确百分比显示
- 字符计数统计
- 剩余时间估计

💬 **聊天集成**
- AI风格聊天气泡
- 用户和AI角色区分
- 打字指示器动画
- 时间戳显示

🎨 **自定义选项**
- 可调节显示速度
- 自定义文本样式
- 光标颜色和速度
- 控制面板开关

🚀 **使用场景**
- AI聊天应用
- 故事讲述应用
- 代码演示工具
- 教育类应用
- 产品展示

这个组件完全开源，您可以根据需要自由修改和扩展。希望它能为您的项目带来价值！

**技术支持**
如果您在使用过程中遇到问题或有改进建议，欢迎反馈。我们将持续更新和完善这个组件。''';

  final List<Map<String, dynamic>> _demoSections = [
    {
      'title': '基础演示',
      'description': '展示基本流式文本功能',
      'icon': Icons.play_circle_outline,
      'color': Colors.blue,
    },
    {
      'title': '速度测试',
      'description': '测试不同显示速度',
      'icon': Icons.speed,
      'color': Colors.green,
    },
    {
      'title': '聊天演示',
      'description': '模拟AI对话场景',
      'icon': Icons.chat_bubble_outline,
      'color': Colors.purple,
    },
    {
      'title': '设置',
      'description': '自定义组件参数',
      'icon': Icons.settings,
      'color': Colors.orange,
    },
  ];

  Duration _currentSpeed = const Duration(milliseconds: 30);
  bool _showControls = true;
  bool _showProgress = true;
  bool _showCursor = true;
  Color _cursorColor = Colors.blue;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    // 添加初始消息
    _addAIMessage(_longSampleText);
    // 添加一些示例对话
    Future.delayed(const Duration(seconds: 2), () {
      _addUserMessage('这个流式文本组件看起来很强大！');
    });
  }

  void _addAIMessage(String text) {
    setState(() {
      _chatMessages.add({
        'text': text,
        'isUser': false,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _chatMessages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
    });
    _scrollToBottom();

    // 模拟AI回复
    Future.delayed(const Duration(seconds: 1), () {
      _addAIMessage(_getRandomResponse());
    });
  }

  String _getRandomResponse() {
    final responses = [
      '是的，这个组件确实功能强大！它支持多种自定义选项。',
      '您还可以调整显示速度和查看实时进度。',
      '这个组件特别适合用于AI对话场景，能提供很好的用户体验。',
      '您可以在设置页面调整各种参数，包括光标颜色和控制面板显示。',
      '流式文本显示让AI对话更加自然和生动，用户可以看到文字逐渐出现的效果。',
    ];
    return responses[Random().nextInt(responses.length)];
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

  void _onCharacterTyped(int count) {
    setState(() {
      _characterCount = count;
    });
  }

  // ================== 辅助方法 ==================

  // 构建统计卡片 - 修复：使用响应式布局
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 9, color: Colors.grey[700]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 修复：格式化颜色值为十六进制字符串
  String _getColorHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  // 构建速度信息行
  Widget _buildSpeedInfo(String speed, String time, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 60),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: _getSpeedColor(speed),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              speed,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 根据速度获取颜色
  Color _getSpeedColor(String speed) {
    switch (speed) {
      case '极慢':
        return Colors.red;
      case '慢':
        return Colors.orange;
      case '正常':
        return Colors.green;
      case '快':
        return Colors.blue;
      case '极快':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // 构建速度测试卡片
  Widget _buildSpeedTestCard(
    String title,
    String content,
    Duration speed,
    Color color,
  ) {
    return Card(
      elevation: 2,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: color.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            EnhancedStreamingText(
              text: content,
              speed: speed,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: color.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white,
              ),
              showControls: false,
              showProgress: false,
              showCursor: true,
              cursorColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // 构建设置项
  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    Widget? trailing,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            SizedBox(width: 200, child: trailing),
          ],
        ],
      ),
    );
  }

  // 构建开关设置项
  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: Colors.blue),
        ],
      ),
    );
  }

  // 构建颜色选择项
  Widget _buildColorSetting(
    String title,
    String subtitle,
    IconData icon,
    Color value,
    List<Color> colors,
    Function(Color) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = color.value == value.value;
                return GestureDetector(
                  onTap: () => onChanged(color),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI流式文本 - 增强版'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('关于'),
                  content: const Text(
                    '这是一个完整的AI流式文本组件测试示例。'
                    '展示了所有增强功能，包括速度控制、进度显示、光标效果等。'
                    '\n\n版本：2.0.1\n构建日期：2024年',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部标签栏
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _demoSections.length,
              itemBuilder: (context, index) {
                final section = _demoSections[index];
                final isActive = _currentTab == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentTab = index;
                      });
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: Icon(
                      section['icon'] as IconData,
                      size: 16,
                      color: isActive
                          ? Colors.white
                          : section['color'] as Color,
                    ),
                    label: Text(section['title'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive
                          ? section['color'] as Color
                          : Colors.transparent,
                      foregroundColor: isActive
                          ? Colors.white
                          : section['color'] as Color,
                      elevation: isActive ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: section['color'] as Color),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 页面内容
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentTab = index;
                });
              },
              children: [
                // 标签1：基础演示
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '基础流式文本演示',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '展示基本功能和效果',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: EnhancedStreamingText(
                            text: '这是一个基础演示，展示流式文本的基本效果。文字会逐字显示，模拟AI对话的体验。',
                            speed: _currentSpeed,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                            onComplete: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('基础演示完成！'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            showControls: _showControls,
                            showProgress: _showProgress,
                            showCursor: _showCursor,
                            cursorColor: _cursorColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '长文本测试',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              EnhancedStreamingText(
                                text:
                                    'Flutter是Google开源的UI工具包，用于构建跨平台应用。'
                                    '它使用Dart语言，支持iOS、Android、Web和桌面平台。'
                                    'Flutter的热重载功能让开发变得更加高效，可以实时看到UI变化。'
                                    '这个流式文本组件就是使用Flutter构建的，展示了其强大的UI构建能力。',
                                speed: _currentSpeed,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.6,
                                ),
                                maxLines: 5,
                                onCharacterTyped: _onCharacterTyped,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 统计信息 - 修复：使用Expanded避免溢出
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '统计信息',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildStatCard(
                                    '字符数',
                                    '$_characterCount',
                                    Icons.text_fields,
                                  ),
                                  _buildStatCard(
                                    '速度',
                                    '${_currentSpeed.inMilliseconds}ms/字',
                                    Icons.speed,
                                  ),
                                  _buildStatCard(
                                    '颜色',
                                    _getColorHex(_cursorColor),
                                    Icons.color_lens,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 标签2：速度测试
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '速度测试',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '测试不同显示速度的效果',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),

                      // 速度说明
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '速度说明',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildSpeedInfo('极慢', '100ms/字', '适合强调重要内容'),
                              _buildSpeedInfo('慢', '50ms/字', '舒适的阅读速度'),
                              _buildSpeedInfo('正常', '30ms/字', '默认推荐速度'),
                              _buildSpeedInfo('快', '15ms/字', '流畅的显示效果'),
                              _buildSpeedInfo('极快', '5ms/字', '几乎瞬间显示'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 不同速度的测试
                      Column(
                        children: [
                          _buildSpeedTestCard(
                            '极慢测试 (100ms/字)',
                            '这是极慢速度测试，每个字符显示间隔100毫秒。适合需要用户仔细阅读的重要信息或强调内容。',
                            const Duration(milliseconds: 100),
                            Colors.red[100]!,
                          ),
                          const SizedBox(height: 12),
                          _buildSpeedTestCard(
                            '慢速测试 (50ms/字)',
                            '这是慢速测试，适合需要用户思考或理解的复杂内容。提供舒适的阅读体验。',
                            const Duration(milliseconds: 50),
                            Colors.orange[100]!,
                          ),
                          const SizedBox(height: 12),
                          _buildSpeedTestCard(
                            '正常测试 (30ms/字)',
                            '这是正常速度测试，平衡了可读性和流畅性。适合大多数应用场景。',
                            const Duration(milliseconds: 30),
                            Colors.green[100]!,
                          ),
                          const SizedBox(height: 12),
                          _buildSpeedTestCard(
                            '快速测试 (15ms/字)',
                            '这是快速测试，文字流畅显示，适合对话场景和用户等待时间较短的情况。',
                            const Duration(milliseconds: 15),
                            Colors.blue[100]!,
                          ),
                          const SizedBox(height: 12),
                          _buildSpeedTestCard(
                            '极快测试 (5ms/字)',
                            '这是极快测试，文字几乎瞬间显示完成，适合技术演示或快速信息展示。',
                            const Duration(milliseconds: 5),
                            Colors.purple[100]!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 标签3：聊天演示
                Column(
                  children: [
                    // 聊天标题
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: const Icon(Icons.chat, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI对话演示',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '模拟真实的AI对话场景',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text('${_chatMessages.length} 条消息'),
                            backgroundColor: Colors.blue[50],
                          ),
                        ],
                      ),
                    ),

                    // 聊天内容
                    Expanded(
                      child: _chatMessages.isEmpty
                          ? const Center(child: Text('暂无消息'))
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _chatMessages.length,
                              itemBuilder: (context, index) {
                                final message = _chatMessages[index];
                                return AIChatBubble(
                                  message: message['text'] as String,
                                  isUser: message['isUser'] as bool,
                                  streamingSpeed: _currentSpeed,
                                  showTypingIndicator: true,
                                );
                              },
                            ),
                    ),

                    // 输入区域
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                        ),
                        color: Theme.of(context).cardColor,
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
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () {
                                    if (_textController.text.isNotEmpty) {
                                      _addUserMessage(_textController.text);
                                      _textController.clear();
                                    }
                                  },
                                ),
                              ),
                              onSubmitted: (value) {
                                if (value.isNotEmpty) {
                                  _addUserMessage(value);
                                  _textController.clear();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'clear',
                                child: Row(
                                  children: [
                                    Icon(Icons.clear_all, size: 20),
                                    SizedBox(width: 8),
                                    Text('清空聊天'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'example',
                                child: Row(
                                  children: [
                                    Icon(Icons.message, size: 20),
                                    SizedBox(width: 8),
                                    Text('添加示例消息'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'clear') {
                                setState(() {
                                  _chatMessages.clear();
                                });
                              } else if (value == 'example') {
                                _addAIMessage(_longSampleText);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 标签4：设置
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '组件设置',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '自定义组件参数和样式',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 20),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '显示设置',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 速度选择
                              _buildSettingItem(
                                '显示速度',
                                '当前: ${_currentSpeed.inMilliseconds}ms/字',
                                Icons.speed,
                                Slider(
                                  value: _currentSpeed.inMilliseconds
                                      .toDouble(),
                                  min: 5,
                                  max: 100,
                                  divisions: 19,
                                  label: '${_currentSpeed.inMilliseconds}ms',
                                  onChanged: (value) {
                                    setState(() {
                                      _currentSpeed = Duration(
                                        milliseconds: value.toInt(),
                                      );
                                    });
                                  },
                                ),
                              ),

                              const Divider(),

                              // 开关设置
                              _buildSwitchSetting(
                                '显示控制面板',
                                '显示暂停、继续、跳过等控制按钮',
                                Icons.control_camera,
                                _showControls,
                                (value) {
                                  setState(() {
                                    _showControls = value;
                                  });
                                },
                              ),

                              _buildSwitchSetting(
                                '显示进度条',
                                '显示进度条和统计信息',
                                Icons.bar_chart,
                                _showProgress,
                                (value) {
                                  setState(() {
                                    _showProgress = value;
                                  });
                                },
                              ),

                              _buildSwitchSetting(
                                '显示光标',
                                '显示闪烁的输入光标',
                                Icons.edit,
                                _showCursor,
                                (value) {
                                  setState(() {
                                    _showCursor = value;
                                  });
                                },
                              ),

                              const Divider(),

                              // 颜色选择
                              _buildColorSetting(
                                '光标颜色',
                                '选择光标显示颜色',
                                Icons.color_lens,
                                _cursorColor,
                                [
                                  Colors.blue,
                                  Colors.red,
                                  Colors.green,
                                  Colors.purple,
                                  Colors.orange,
                                  Colors.teal,
                                  Colors.pink,
                                  Colors.amber,
                                ],
                                (color) {
                                  setState(() {
                                    _cursorColor = color;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 重置按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentSpeed = const Duration(milliseconds: 30);
                              _showControls = true;
                              _showProgress = true;
                              _showCursor = true;
                              _cursorColor = Colors.blue;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('设置已重置为默认值'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('重置为默认设置'),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: '基础演示',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.speed), label: '速度测试'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '聊天演示',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
      floatingActionButton: _currentTab == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _addUserMessage(_textController.text);
                  _textController.clear();
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('发送'),
              backgroundColor: Colors.blue,
            )
          : null,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
