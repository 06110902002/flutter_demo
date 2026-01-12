/// Author: Rambo.Liu
/// Date: 2026/1/9 17:50
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const HandlerDemoApp());
}

class HandlerDemoApp extends StatelessWidget {
  const HandlerDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Handler 队列',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HandlerDemoPage(),
    );
  }
}

/// 消息优先级
enum MessagePriority { low, normal, high, urgent }

extension MessagePriorityExtension on MessagePriority {
  Color get color {
    switch (this) {
      case MessagePriority.low:
        return Colors.grey;
      case MessagePriority.normal:
        return Colors.blue;
      case MessagePriority.high:
        return Colors.orange;
      case MessagePriority.urgent:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case MessagePriority.low:
        return Icons.low_priority;
      case MessagePriority.normal:
        return Icons.schedule;
      case MessagePriority.high:
        return Icons.priority_high;
      case MessagePriority.urgent:
        return Icons.warning;
    }
  }

  String get displayName {
    switch (this) {
      case MessagePriority.low:
        return '低';
      case MessagePriority.normal:
        return '普通';
      case MessagePriority.high:
        return '高';
      case MessagePriority.urgent:
        return '紧急';
    }
  }

  int get weight {
    switch (this) {
      case MessagePriority.low:
        return 1;
      case MessagePriority.normal:
        return 2;
      case MessagePriority.high:
        return 3;
      case MessagePriority.urgent:
        return 4;
    }
  }
}

/// 消息状态
enum MessageState {
  pending, // 等待中
  ready, // 准备就绪
  processing, // 处理中
  completed, // 已完成
  cancelled, // 已取消
}

/// 消息基类
abstract class Message {
  final String id;
  final MessagePriority priority;
  final DateTime timestamp;
  final Map<String, dynamic>? extra;
  MessageState _state = MessageState.pending;

  Message({
    required this.id,
    this.priority = MessagePriority.normal,
    DateTime? timestamp,
    this.extra,
  }) : timestamp = timestamp ?? DateTime.now();

  MessageState get state => _state;

  bool get isReadyForExecution => _state == MessageState.ready;

  void markReady() {
    if (_state == MessageState.pending) {
      _state = MessageState.ready;
    }
  }

  void markProcessing() {
    _state = MessageState.processing;
  }

  void markCompleted() {
    _state = MessageState.completed;
  }

  void markCancelled() {
    _state = MessageState.cancelled;
  }

  Future<void> execute();

  @override
  String toString() {
    return 'Message(id: $id, priority: $priority, state: $_state)';
  }
}

/// 普通任务消息
class TaskMessage extends Message {
  final Future<void> Function() task;
  final String description;

  TaskMessage({
    required String id,
    required this.task,
    required this.description,
    MessagePriority priority = MessagePriority.normal,
    DateTime? timestamp,
    Map<String, dynamic>? extra,
  }) : super(id: id, priority: priority, timestamp: timestamp, extra: extra);

  @override
  Future<void> execute() async {
    markProcessing();
    await task();
    markCompleted();
  }
}

/// 延迟消息
class DelayedMessage extends TaskMessage {
  final Duration delay;

  DelayedMessage({
    required String id,
    required Future<void> Function() task,
    required String description,
    required this.delay,
    MessagePriority priority = MessagePriority.normal,
    Map<String, dynamic>? extra,
  }) : super(
         id: id,
         task: task,
         description: description,
         priority: priority,
         extra: extra,
       );
}

/// Handler状态
enum HandlerState { idle, running, paused, stopped }

extension HandlerStateExtension on HandlerState {
  Color get color {
    switch (this) {
      case HandlerState.idle:
        return Colors.grey;
      case HandlerState.running:
        return Colors.green;
      case HandlerState.paused:
        return Colors.orange;
      case HandlerState.stopped:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case HandlerState.idle:
        return '空闲';
      case HandlerState.running:
        return '运行中';
      case HandlerState.paused:
        return '已暂停';
      case HandlerState.stopped:
        return '已停止';
    }
  }
}

/// 优化的消息队列实现
class _OptimizedMessageQueue {
  final List<Message> _messages = [];

  // 使用StreamController实现事件通知
  final StreamController<void> _notificationController =
      StreamController<void>.broadcast();
  bool _isNotifying = false;

  /// 添加消息到队列
  void add(Message message) {
    _messages.add(message);
    _sortMessages();

    // 如果有监听者，发送通知
    if (_notificationController.hasListener && !_isNotifying) {
      _isNotifying = true;
      _notificationController.add(null);
      _isNotifying = false;
    }
  }

  /// 排序消息
  void _sortMessages() {
    _messages.sort((a, b) {
      // 首先按状态排序：准备就绪的优先于等待中的
      if (a.isReadyForExecution && !b.isReadyForExecution) return -1;
      if (!a.isReadyForExecution && b.isReadyForExecution) return 1;

      // 都准备就绪或都等待中时，按优先级排序
      final priorityCompare = b.priority.weight.compareTo(a.priority.weight);
      if (priorityCompare != 0) return priorityCompare;

      // 同优先级按时间升序排序
      return a.timestamp.compareTo(b.timestamp);
    });
  }

  /// 检查是否有可执行消息
  bool hasExecutableMessage() {
    for (var message in _messages) {
      if (message.isReadyForExecution) {
        return true;
      }
    }
    return false;
  }

  /// 等待可执行消息（带超时）
  Future<bool> waitForMessage({
    Duration timeout = const Duration(seconds: 60),
  }) async {
    // 如果已经有可执行消息，直接返回
    if (hasExecutableMessage()) {
      return true;
    }

    // 等待通知
    try {
      await _notificationController.stream.first.timeout(timeout);
      return hasExecutableMessage();
    } on TimeoutException {
      return false;
    }
  }

  /// 获取下一个可执行的消息
  Message? getNextExecutableMessage() {
    for (var message in _messages) {
      if (message.isReadyForExecution) {
        return message;
      }
    }
    return null;
  }

  /// 移除消息
  bool remove(Message message) {
    final removed = _messages.remove(message);
    return removed;
  }

  /// 移除并返回下一个可执行的消息
  Message? removeNextExecutable() {
    final message = getNextExecutableMessage();
    if (message != null) {
      _messages.remove(message);
    }
    return message;
  }

  /// 清空队列
  void clear() {
    _messages.clear();
  }

  /// 获取队列长度
  int get length => _messages.length;

  /// 检查队列是否为空
  bool get isEmpty => _messages.isEmpty;

  /// 检查队列是否包含指定消息
  bool contains(Message message) {
    return _messages.contains(message);
  }

  /// 获取所有消息（用于显示）
  List<Message> getAllMessages() {
    return List.from(_messages);
  }

  /// 通知队列重新排序（当消息状态变化时调用）
  void notifyChanged() {
    _sortMessages();
    // 发送通知
    if (_notificationController.hasListener && !_isNotifying) {
      _isNotifying = true;
      _notificationController.add(null);
      _isNotifying = false;
    }
  }

  /// 销毁
  void dispose() {
    _notificationController.close();
  }
}

/// 优化的Handler消息队列
class DartHandler {
  // 消息队列
  final _OptimizedMessageQueue _messageQueue = _OptimizedMessageQueue();
  final Map<String, Message> _messageMap = {};
  final Map<String, Timer> _timerMap = {};

  // 处理任务
  Future<void>? _processingTask;
  bool _isProcessing = false;

  // 状态
  HandlerState _state = HandlerState.idle;

  // 停止标志
  bool _shouldStop = false;

  // 配置
  final bool _debugLogging;

  // 统计信息
  int _totalProcessed = 0;
  int _totalFailed = 0;
  int _totalCancelled = 0;
  final List<String> _logMessages = [];

  // 事件流
  final StreamController<void> _eventController =
      StreamController<void>.broadcast();

  DartHandler._({bool debugLogging = false}) : _debugLogging = debugLogging {
    _log('Handler初始化完成');
  }

  static DartHandler? _instance;

  static DartHandler getInstance({bool debugLogging = false}) {
    _instance ??= DartHandler._(debugLogging: debugLogging);
    return _instance!;
  }

  Stream<void> get events => _eventController.stream;

  HandlerState get state => _state;

  int get queueSize => _messageQueue.length;

  List<String> get logs => List.unmodifiable(_logMessages);

  Map<String, int> get statistics => {
    'totalProcessed': _totalProcessed,
    'totalFailed': _totalFailed,
    'totalCancelled': _totalCancelled,
    'pendingMessages': queueSize,
  };

  /// 启动
  Future<void> start() async {
    if (_state == HandlerState.running) {
      _log('Handler已经在运行中');
      return;
    }

    // if (_state == HandlerState.stopped) {
    //   throw Exception('Handler已停止，无法重新启动');
    // }

    _state = HandlerState.running;
    _shouldStop = false;
    _log('Handler启动');
    _eventController.add(null);

    // 启动异步处理循环
    _startProcessingLoop();
  }

  /// 暂停
  Future<void> pause() async {
    if (_state != HandlerState.running) return;

    _state = HandlerState.paused;
    _log('Handler已暂停');
    _eventController.add(null);
  }

  /// 恢复
  Future<void> resume() async {
    if (_state != HandlerState.paused) return;

    _state = HandlerState.running;
    _log('Handler已恢复');
    _eventController.add(null);

    // 如果处理循环没有运行，重新启动
    if (_processingTask == null) {
      _startProcessingLoop();
    }
  }

  /// 停止
  Future<void> stop() async {
    if (_state == HandlerState.stopped) return;

    _state = HandlerState.stopped;
    _shouldStop = true;
    _log('Handler正在停止...');

    // 取消所有定时器
    _cancelAllTimers();

    // 等待当前处理任务完成
    await _processingTask?.catchError((_) {});

    _log('Handler已停止');
    _eventController.add(null);
  }

  /// 发送普通任务
  Future<bool> sendTask({
    required String id,
    required Future<void> Function() task,
    required String description,
    MessagePriority priority = MessagePriority.normal,
    Map<String, dynamic>? extra,
  }) async {
    if (_state == HandlerState.stopped) {
      _log('Handler已停止，无法发送消息');
      return false;
    }

    if (_messageMap.containsKey(id)) {
      _log('消息ID重复: $id');
      return false;
    }

    final message = TaskMessage(
      id: id,
      task: task,
      description: description,
      priority: priority,
      extra: extra,
    );

    // 普通任务立即标记为可执行
    message.markReady();

    _messageQueue.add(message);
    _messageMap[id] = message;

    _log('消息已发送: $id (${priority.displayName}优先级)');
    _eventController.add(null);

    return true;
  }

  /// 发送延迟任务
  Future<bool> sendDelayedTask({
    required String id,
    required Future<void> Function() task,
    required String description,
    required Duration delay,
    MessagePriority priority = MessagePriority.normal,
    Map<String, dynamic>? extra,
  }) async {
    if (_state == HandlerState.stopped) return false;

    if (_messageMap.containsKey(id)) {
      _log('消息ID重复: $id');
      return false;
    }

    final message = DelayedMessage(
      id: id,
      task: task,
      description: description,
      delay: delay,
      priority: priority,
      extra: extra,
    );

    _messageQueue.add(message);
    _messageMap[id] = message;

    _log('延迟消息已发送: $id (${delay.inSeconds}秒后执行)');
    _eventController.add(null);

    // 设置延迟计时器
    _setupDelayedMessage(message);

    return true;
  }

  /// 取消消息
  Future<bool> cancelMessage(String id) async {
    final message = _messageMap[id];
    if (message == null) return false;

    _messageQueue.remove(message);
    _messageMap.remove(id);

    // 取消定时器
    _timerMap[id]?.cancel();
    _timerMap.remove(id);

    // 标记消息为已取消
    message.markCancelled();

    _totalCancelled++;
    _log('消息已取消: $id');
    _eventController.add(null);

    return true;
  }

  /// 取消所有消息
  Future<void> cancelAll() async {
    _log('取消所有消息');

    // 取消所有定时器
    _cancelAllTimers();

    // 取消所有消息
    for (var message in _messageMap.values) {
      message.markCancelled();
    }

    _messageQueue.clear();
    _messageMap.clear();

    _eventController.add(null);
  }

  /// 获取所有待处理消息
  List<Message> getPendingMessages() {
    return _messageQueue.getAllMessages();
  }

  /// 私有方法：启动处理循环
  void _startProcessingLoop() {
    if (_processingTask != null) return;

    _processingTask = _processingLoop();
  }

  /// 处理循环（混合方案：事件驱动+轻量轮询）
  Future<void> _processingLoop() async {
    _log('消息处理循环已启动');

    while (_state == HandlerState.running && !_shouldStop) {
      try {
        // 使用混合方案：
        // 1. 先检查是否有可执行消息
        // 2. 如果没有，等待一小段时间再检查
        if (_messageQueue.hasExecutableMessage()) {
          // 处理消息
          final message = _messageQueue.removeNextExecutable();
          if (message != null) {
            await _processSingleMessage(message);
          }
        } else {
          // 没有可执行消息，等待100ms再检查
          // 这比原来的100ms轮询要好，因为：
          // 1. 使用await让出CPU
          // 2. 100ms间隔足够小，响应迅速
          // 3. 避免了Completer的死锁问题
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } catch (e) {
        _log('处理循环异常: $e');
        // 发生异常时暂停一下，防止快速循环出错
        await Future.delayed(const Duration(milliseconds: 1000));
      }
    }

    _log('消息处理循环已停止');
    _processingTask = null;
  }

  /// 处理单个消息
  Future<void> _processSingleMessage(Message message) async {
    _isProcessing = true;

    try {
      // 从映射表中移除
      _messageMap.remove(message.id);
      _timerMap.remove(message.id);

      _log('开始处理消息: ${message.id} (${message.priority.displayName}优先级)');

      await message.execute();

      _totalProcessed++;
      _log('消息处理完成: ${message.id}');

      _eventController.add(null);
    } catch (e) {
      _totalFailed++;
      _log('消息处理失败: $e');
      _eventController.add(null);
    } finally {
      _isProcessing = false;
    }
  }

  /// 设置延迟消息
  void _setupDelayedMessage(DelayedMessage message) {
    final timer = Timer(message.delay, () {
      if (message.state == MessageState.pending) {
        // 延迟时间到，标记消息为可执行状态
        message.markReady();
        _log('延迟消息准备就绪: ${message.id}');

        // 通知队列重新排序
        _messageQueue.notifyChanged();

        _eventController.add(null);
      }
    });

    _timerMap[message.id] = timer;
  }

  /// 取消所有定时器
  void _cancelAllTimers() {
    for (final timer in _timerMap.values) {
      timer.cancel();
    }
    _timerMap.clear();
    _log('所有定时器已取消');
  }

  /// 日志
  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(11, 23);
    final logEntry = '[$timestamp] $message';

    if (_debugLogging) {
      debugPrint(logEntry);
    }

    _logMessages.add(logEntry);
    if (_logMessages.length > 50) {
      _logMessages.removeAt(0);
    }
  }

  /// 销毁
  Future<void> dispose() async {
    await stop();
    await _eventController.close();
    _messageQueue.dispose();
    _instance = null;
  }
}

/// 演示页面
class HandlerDemoPage extends StatefulWidget {
  const HandlerDemoPage({Key? key}) : super(key: key);

  @override
  State<HandlerDemoPage> createState() => _HandlerDemoPageState();
}

class _HandlerDemoPageState extends State<HandlerDemoPage> {
  late DartHandler _handler;
  int _messageCounter = 0;
  final ScrollController _logScrollController = ScrollController();
  final Map<String, Timer> _periodicTasks = {};

  @override
  void initState() {
    super.initState();
    _handler = DartHandler.getInstance(debugLogging: true);
    _handler.events.listen((_) {
      if (mounted) {
        setState(() {});
        // 滚动日志到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logScrollController.hasClients) {
            _logScrollController.animateTo(
              _logScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // 取消所有周期性任务
    for (var timer in _periodicTasks.values) {
      timer.cancel();
    }
    _periodicTasks.clear();

    _handler.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Handler 消息队列'),
        actions: [
          IconButton(icon: const Icon(Icons.info), onPressed: _showInfoDialog),
        ],
      ),
      body: Column(
        children: [
          // 状态面板
          _buildStatusPanel(),

          // 控制按钮
          _buildControlButtons(),

          // 消息操作按钮
          _buildMessageButtons(),

          // 队列信息
          _buildQueueInfo(),

          // 日志面板
          Expanded(child: _buildLogPanel()),
        ],
      ),
    );
  }

  Widget _buildStatusPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _handler.state.color.withOpacity(0.1),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _handler.state.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '状态: ${_handler.state.displayName}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _handler.state.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '队列大小: ${_handler.queueSize} | 已处理: ${_handler.statistics['totalProcessed']}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearLogs,
            tooltip: '清空日志',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          // 启动按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text('启动'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: _handler.state == HandlerState.running
                ? null
                : () async {
                    await _handler.start();
                    setState(() {});
                  },
          ),

          // 暂停按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.pause, size: 16),
            label: const Text('暂停'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: _handler.state != HandlerState.running
                ? null
                : () async {
                    await _handler.pause();
                    setState(() {});
                  },
          ),

          // 恢复按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.play_circle_fill, size: 16),
            label: const Text('恢复'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: _handler.state != HandlerState.paused
                ? null
                : () async {
                    await _handler.resume();
                    setState(() {});
                  },
          ),

          // 停止按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.stop, size: 16),
            label: const Text('停止'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: _handler.state == HandlerState.stopped
                ? null
                : () async {
                    await _handler.stop();
                    setState(() {});
                  },
          ),

          // 取消所有按钮
          ElevatedButton.icon(
            icon: const Icon(Icons.cancel, size: 16),
            label: const Text('取消所有'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: _handler.queueSize == 0
                ? null
                : () async {
                    await _handler.cancelAll();
                    setState(() {});
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageButtons() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '消息操作',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // 普通任务
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('普通任务'),
                    onPressed: () => _sendNormalTask(),
                  ),

                  // 高优先级任务
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.priority_high,
                      size: 16,
                      color: MessagePriority.high.color,
                    ),
                    label: const Text('高优先级'),
                    onPressed: () => _sendHighPriorityTask(),
                  ),

                  // 紧急任务
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.warning,
                      size: 16,
                      color: MessagePriority.urgent.color,
                    ),
                    label: const Text('紧急任务'),
                    onPressed: () => _sendUrgentTask(),
                  ),

                  // 延迟任务 - 2秒
                  ElevatedButton.icon(
                    icon: const Icon(Icons.timer, size: 16),
                    label: const Text('延迟2秒'),
                    onPressed: () => _sendDelayedTask(seconds: 2),
                  ),

                  // 延迟任务 - 5秒
                  ElevatedButton.icon(
                    icon: const Icon(Icons.timer_3, size: 16),
                    label: const Text('延迟5秒'),
                    onPressed: () => _sendDelayedTask(seconds: 5),
                  ),

                  // 延迟任务 - 10秒
                  ElevatedButton.icon(
                    icon: const Icon(Icons.timer_10, size: 16),
                    label: const Text('延迟10秒'),
                    onPressed: () => _sendDelayedTask(seconds: 10),
                  ),

                  // 模拟耗时任务
                  ElevatedButton.icon(
                    icon: const Icon(Icons.hourglass_bottom, size: 16),
                    label: const Text('耗时任务'),
                    onPressed: () => _sendLongRunningTask(),
                  ),

                  // 批量任务
                  ElevatedButton.icon(
                    icon: const Icon(Icons.queue, size: 16),
                    label: const Text('批量发送'),
                    onPressed: () => _sendBatchTasks(),
                  ),

                  // 周期性任务
                  ElevatedButton.icon(
                    icon: const Icon(Icons.repeat, size: 16),
                    label: const Text('周期任务'),
                    onPressed: () => _sendPeriodicTask(),
                  ),

                  // 取消特定任务
                  ElevatedButton.icon(
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('取消任务'),
                    onPressed: () => _cancelSpecificTask(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueInfo() {
    final messages = _handler.getPendingMessages();

    return ExpansionTile(
      title: const Text('当前队列消息'),
      initiallyExpanded: false,
      children: [
        if (messages.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text('队列为空'))
        else
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                String description = '未知类型';
                if (message is TaskMessage) {
                  description = message.description;
                }

                // 获取状态显示
                String stateText = '等待中';
                Color stateColor = Colors.grey;
                switch (message.state) {
                  case MessageState.pending:
                    stateText = '等待中';
                    stateColor = Colors.grey;
                    break;
                  case MessageState.ready:
                    stateText = '准备就绪';
                    stateColor = Colors.green;
                    break;
                  case MessageState.processing:
                    stateText = '处理中';
                    stateColor = Colors.blue;
                    break;
                  case MessageState.completed:
                    stateText = '已完成';
                    stateColor = Colors.green;
                    break;
                  case MessageState.cancelled:
                    stateText = '已取消';
                    stateColor = Colors.red;
                    break;
                }

                return ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        message.priority.icon,
                        color: message.priority.color,
                        size: 20,
                      ),
                    ],
                  ),
                  title: Text(message.id),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('优先级: ${message.priority.displayName}'),
                      Text(
                        '状态: $stateText',
                        style: TextStyle(color: stateColor, fontSize: 12),
                      ),
                      Text(
                        '描述: $description',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, size: 18),
                    onPressed: () => _cancelMessage(message.id),
                  ),
                  onTap: () => _showMessageDetails(message),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildLogPanel() {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                const Text(
                  '操作日志',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '共 ${_handler.logs.length} 条',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _handler.logs.isEmpty
                ? const Center(child: Text('暂无日志'))
                : ListView.builder(
                    controller: _logScrollController,
                    itemCount: _handler.logs.length,
                    itemBuilder: (context, index) {
                      final log = _handler.logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: SelectableText(
                          log,
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Monospace',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // === 消息操作函数 ===

  void _sendNormalTask() async {
    _messageCounter++;
    final id = 'normal_task_$_messageCounter';

    await _handler.sendTask(
      id: id,
      task: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('普通任务 $id 执行完成');
      },
      description: '普通任务 - 500ms延迟',
      priority: MessagePriority.normal,
    );

    setState(() {});
  }

  void _sendHighPriorityTask() async {
    _messageCounter++;
    final id = 'high_task_$_messageCounter';

    await _handler.sendTask(
      id: id,
      task: () async {
        await Future.delayed(const Duration(milliseconds: 200));
        debugPrint('高优先级任务 $id 执行完成');
      },
      description: '高优先级任务 - 200ms延迟',
      priority: MessagePriority.high,
    );

    setState(() {});
  }

  void _sendUrgentTask() async {
    _messageCounter++;
    final id = 'urgent_task_$_messageCounter';

    await _handler.sendTask(
      id: id,
      task: () async {
        await Future.delayed(const Duration(milliseconds: 100));
        debugPrint('紧急任务 $id 执行完成');
      },
      description: '紧急任务 - 100ms延迟',
      priority: MessagePriority.urgent,
    );

    setState(() {});
  }

  void _sendDelayedTask({required int seconds}) async {
    _messageCounter++;
    final id = 'delayed_task_${seconds}s_$_messageCounter';

    await _handler.sendDelayedTask(
      id: id,
      task: () async {
        debugPrint('延迟任务 $id 在${seconds}秒后执行完成');
      },
      description: '延迟任务 - ${seconds}秒后执行',
      delay: Duration(seconds: seconds),
    );

    setState(() {});
  }

  void _sendLongRunningTask() async {
    _messageCounter++;
    final id = 'long_task_$_messageCounter';

    await _handler.sendTask(
      id: id,
      task: () async {
        for (int i = 1; i <= 5; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          debugPrint('耗时任务 $id 进度: $i/5');
        }
      },
      description: '耗时任务 - 2.5秒完成',
      priority: MessagePriority.normal,
    );

    setState(() {});
  }

  void _sendBatchTasks() async {
    for (int i = 1; i <= 5; i++) {
      _messageCounter++;
      final id = 'batch_task_$_messageCounter';
      final priorityIndex = i % MessagePriority.values.length;
      final priority = MessagePriority.values[priorityIndex];

      await _handler.sendTask(
        id: id,
        task: () async {
          await Future.delayed(Duration(milliseconds: 100 * i));
          debugPrint('批量任务 $id 完成');
        },
        description: '批量任务 - ${priority.displayName}优先级',
        priority: priority,
      );
    }

    setState(() {});
  }

  void _sendPeriodicTask() async {
    _messageCounter++;
    final id = 'periodic_task_$_messageCounter';

    // 周期性任务直接使用Timer，不通过Handler
    int counter = 0;
    final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      counter++;
      debugPrint('周期性任务 $id 第 $counter 次执行');
    });

    _periodicTasks[id] = timer;

    _showSnackBar('周期性任务 $id 已启动（每秒执行）');
  }

  void _cancelSpecificTask() async {
    final messages = _handler.getPendingMessages();
    if (messages.isEmpty) {
      _showSnackBar('队列为空，无法取消');
      return;
    }

    final message = messages.first;
    await _handler.cancelMessage(message.id);
    _showSnackBar('已取消任务: ${message.id}');

    setState(() {});
  }

  void _cancelMessage(String id) async {
    // 先检查是否是周期性任务
    if (_periodicTasks.containsKey(id)) {
      _periodicTasks[id]?.cancel();
      _periodicTasks.remove(id);
      _showSnackBar('已取消周期性任务: $id');
      setState(() {});
      return;
    }

    await _handler.cancelMessage(id);
    _showSnackBar('已取消任务: $id');
    setState(() {});
  }

  // === 辅助函数 ===

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _clearLogs() {
    _handler.logs.clear();
    setState(() {});
    _showSnackBar('日志已清空');
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Handler 消息队列说明'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('特性说明:'),
              SizedBox(height: 12),
              Text('• 消息优先级: 支持4种优先级: 紧急、高、普通、低'),
              Text('• 任务类型: 普通任务、延迟任务（真正延迟执行）'),
              Text('• 任务取消: 支持单个取消和批量取消'),
              Text('• 状态管理: 支持启动、暂停、恢复、停止'),
              Text('• 性能优化: 混合方案，无消息时100ms间隔检查，避免CPU空转'),
              SizedBox(height: 16),
              Text('操作说明:'),
              SizedBox(height: 8),
              Text('• 启动/停止: 控制Handler的运行状态'),
              Text('• 发送任务: 点击不同按钮发送各种类型的任务'),
              Text('• 延迟任务: 可以设置2秒、5秒、10秒延迟'),
              Text('• 查看队列: 展开"当前队列消息"查看待处理任务'),
              Text('• 取消任务: 点击消息右侧的取消按钮或使用"取消任务"按钮'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showMessageDetails(Message message) {
    String description = '未知类型';
    if (message is TaskMessage) {
      description = message.description;
    }

    String stateText = '';
    switch (message.state) {
      case MessageState.pending:
        stateText = '等待中';
        break;
      case MessageState.ready:
        stateText = '准备就绪';
        break;
      case MessageState.processing:
        stateText = '处理中';
        break;
      case MessageState.completed:
        stateText = '已完成';
        break;
      case MessageState.cancelled:
        stateText = '已取消';
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('消息详情: ${message.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID:', message.id),
              _buildDetailRow('优先级:', message.priority.displayName),
              _buildDetailRow('状态:', stateText),
              _buildDetailRow('创建时间:', message.timestamp.toString()),
              _buildDetailRow('描述:', description),
              if (message is DelayedMessage)
                _buildDetailRow('延迟时间:', '${message.delay.inSeconds}秒'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
          if (message.state != MessageState.cancelled &&
              message.state != MessageState.completed)
            TextButton(
              onPressed: () {
                _cancelMessage(message.id);
                Navigator.pop(context);
              },
              child: const Text('取消任务'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
