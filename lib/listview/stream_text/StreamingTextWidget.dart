/// Author: Rambo.Liu
/// Date: 2026/2/9 16:26
/// @Copyright by ZYQL Since 2025
/// Description: TODO
// lib/widgets/streaming_text_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';

class StreamingTextWidget extends StatefulWidget {
  final String text;
  final Duration speed;
  final TextStyle style;
  final TextAlign textAlign;
  final VoidCallback? onComplete;
  final bool autoStart;
  final int maxLines;
  final TextOverflow overflow;

  const StreamingTextWidget({
    Key? key,
    required this.text,
    this.speed = const Duration(milliseconds: 30),
    this.style = const TextStyle(fontSize: 16, color: Colors.black),
    this.textAlign = TextAlign.left,
    this.onComplete,
    this.autoStart = true,
    this.maxLines = 10,
    this.overflow = TextOverflow.ellipsis,
  }) : super(key: key);

  @override
  _StreamingTextWidgetState createState() => _StreamingTextWidgetState();
}

class _StreamingTextWidgetState extends State<StreamingTextWidget> {
  late String _displayText;
  late int _currentIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _displayText = '';
    _currentIndex = 0;

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

    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          // 逐字添加，模拟流式效果
          _displayText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  void pauseStreaming() {
    _timer?.cancel();
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
    });
    widget.onComplete?.call();
  }

  void restartStreaming() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _displayText = '';
      _currentIndex = 0;
    });
    _startStreaming();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 文本显示区域
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _displayText,
            style: widget.style,
            textAlign: widget.textAlign,
            maxLines: widget.maxLines,
            overflow: widget.overflow,
          ),
        ),

        // 控制按钮（仅在文本未完全显示时显示）
        if (_currentIndex < widget.text.length) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              // 跳过按钮
              ElevatedButton.icon(
                onPressed: skipToEnd,
                icon: const Icon(Icons.fast_forward, size: 16),
                label: const Text('跳过'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                ),
              ),
              const SizedBox(width: 8),
              // 暂停/继续按钮
              ElevatedButton.icon(
                onPressed: _timer?.isActive == true
                    ? pauseStreaming
                    : resumeStreaming,
                icon: Icon(
                  _timer?.isActive == true ? Icons.pause : Icons.play_arrow,
                  size: 16,
                ),
                label: Text(_timer?.isActive == true ? '暂停' : '继续'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        ],

        // 进度指示器
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: widget.text.isEmpty ? 0 : _currentIndex / widget.text.length,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
        ),

        // 进度文本
        const SizedBox(height: 4),
        Text(
          '${(_currentIndex / widget.text.length * 100).toStringAsFixed(0)}% '
          '($_currentIndex/${widget.text.length} 字符)',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
