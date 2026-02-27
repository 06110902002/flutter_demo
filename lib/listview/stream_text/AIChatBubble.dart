/// Author: Rambo.Liu
/// Date: 2026/2/9 16:26
/// @Copyright by ZYQL Since 2025
/// Description: TODO
// lib/widgets/ai_chat_bubble.dart
import 'package:flutter/material.dart';

import 'StreamingTextWidget.dart';

class AIChatBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final Duration streamingSpeed;
  final VoidCallback? onStreamingComplete;
  final bool showTypingIndicator;

  const AIChatBubble({
    Key? key,
    required this.message,
    this.isUser = false,
    this.streamingSpeed = const Duration(milliseconds: 20),
    this.onStreamingComplete,
    this.showTypingIndicator = false,
  }) : super(key: key);

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
          // AI头像
          if (!widget.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: widget.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // 用户名
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.isUser ? '您' : 'AI助手',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 聊天气泡
                Container(
                  constraints: const BoxConstraints(
                    minWidth: 50,
                    maxWidth: double.infinity,
                  ),
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
                        // 用户消息直接显示
                        Text(
                          widget.message,
                          style: const TextStyle(fontSize: 16),
                        )
                      else
                        // AI消息使用流式显示
                        StreamingTextWidget(
                          text: widget.message,
                          speed: widget.streamingSpeed,
                          style: const TextStyle(fontSize: 16),
                          onComplete: _onStreamingComplete,
                          autoStart: true,
                        ),

                      // 打字指示器（仅在AI消息且未完成时显示）
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

                // 时间戳
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatTime(DateTime.now()),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // 用户头像
          if (widget.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
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
