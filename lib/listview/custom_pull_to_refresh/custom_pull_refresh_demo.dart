/// Author: Rambo.Liu
/// Date: 2026/1/7 17:50
/// @Copyright by JYXC Since 2023
/// Description: 自定义下拉刷新的实现原理
import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// =======================
/// 用户手势方向（只表示意图）
/// =======================
enum ScrollDirection {
  up, // 用户上推
  down, // 用户下拉
  idle,
}

/// =======================
/// 滚动物理阶段
/// =======================
enum ScrollPhase {
  dragging, // 拖动中
  ballistic, // 回弹中
  settling, // 回弹结束
  idle, // 静止
}

/// =======================
/// ChangeNotifier with Safe Notification Scheduling
/// =======================
class ScrollPositionNotifier extends ChangeNotifier {
  double _position = 0.0;
  ScrollDirection _direction = ScrollDirection.idle;
  ScrollPhase _phase = ScrollPhase.idle;
  bool _isNotificationScheduled = false;

  double get position => _position;

  ScrollDirection get direction => _direction;

  ScrollPhase get phase => _phase;

  /// 安全地调度通知，以避免在帧渲染期间调用 notifyListeners
  void _scheduleNotify() {
    if (_isNotificationScheduled) return;
    _isNotificationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isNotificationScheduled = false;
      notifyListeners();
    });
  }

  /// 用户拖动
  void onUserDrag(double position, double offset) {
    _position = position;
    _phase = ScrollPhase.dragging;

    if (offset != 0) {
      // 用户手指上推，列表内容向上滚动，offset 为负值。
      // 用户手指下拉，列表内容向下滚动，offset 为正值。
      _direction = offset > 0 ? ScrollDirection.down : ScrollDirection.up;
    }
    _scheduleNotify();
  }

  /// 开始回弹
  void startBallistic(double position) {
    _position = position;
    _phase = ScrollPhase.ballistic;
    _direction = ScrollDirection.up; // 回弹总是向上
    _scheduleNotify();
  }

  /// 回弹过程中
  void updateBallistic(double position) {
    if (_phase != ScrollPhase.ballistic) return;
    _position = position;
    _scheduleNotify();
  }

  /// 回弹结束
  void finishBallistic() {
    if (_phase != ScrollPhase.ballistic) return;
    _phase = ScrollPhase.settling;
    _scheduleNotify();
  }

  /// 完全静止
  void settleToIdle() {
    // 允许从 settling 或 dragging 状态变为 idle
    if (_phase == ScrollPhase.idle) return;
    _phase = ScrollPhase.idle;
    _direction = ScrollDirection.idle;
    _scheduleNotify();
  }
}

/// =======================
/// ScrollPhysics
/// =======================
class NotifyingBouncingScrollPhysics extends BouncingScrollPhysics {
  final ScrollPositionNotifier notifier;

  const NotifyingBouncingScrollPhysics({
    required this.notifier,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  NotifyingBouncingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NotifyingBouncingScrollPhysics(
      notifier: notifier,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final newPixels = position.pixels - offset;
    notifier.onUserDrag(newPixels, offset);
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    final sim = super.createBallisticSimulation(position, velocity);
    if (sim == null) {
      // 如果没有产生模拟（例如，滚动没有超出边界），则通知变为静止
      notifier.settleToIdle();
      return null;
    }
    return _NotifierSimulation(sim, notifier, position.pixels);
  }
}

/// =======================
/// Simulation 包装
/// =======================
class _NotifierSimulation extends Simulation {
  final Simulation _sim;
  final ScrollPositionNotifier _notifier;
  bool _ended = false;

  _NotifierSimulation(this._sim, this._notifier, double startPosition) {
    _notifier.startBallistic(startPosition);
  }

  @override
  double x(double time) {
    final value = _sim.x(time);
    _notifier.updateBallistic(value);

    if (!_ended && _sim.isDone(time)) {
      _ended = true;
      _notifier.finishBallistic();
      // 在下一帧转为 idle，确保 settling 状态可以被 UI 观察到
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifier.settleToIdle();
      });
    }
    return value;
  }

  @override
  double dx(double time) => _sim.dx(time);

  @override
  bool isDone(double time) => _sim.isDone(time);
}

/// =======================
/// App UI
/// =======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ScrollDemoPage());
  }
}

class ScrollDemoPage extends StatefulWidget {
  const ScrollDemoPage({super.key});

  @override
  State<ScrollDemoPage> createState() => _ScrollDemoPageState();
}

class _ScrollDemoPageState extends State<ScrollDemoPage> {
  final ScrollPositionNotifier _notifier = ScrollPositionNotifier();
  final double max_head_view_height = 100.0;

  Timer? _hideHeaderTimer;
  ScrollPhase _previousPhase = ScrollPhase.idle;
  bool _isHoldingHeader = false;

  // This flag is crucial. It's true only when we are animating the close.
  bool _isAnimatingClose = false;
  double _heldHeaderHeight = 0;

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_handleScrollPhaseChange);
  }

  @override
  void dispose() {
    _hideHeaderTimer?.cancel();
    _notifier.removeListener(_handleScrollPhaseChange);
    _notifier.dispose();
    super.dispose();
  }

  void _handleScrollPhaseChange() {
    // When a pull-to-refresh is triggered
    if (_notifier.phase == ScrollPhase.ballistic &&
        _previousPhase == ScrollPhase.dragging &&
        _notifier.position.abs() > max_head_view_height) {
      setState(() {
        _heldHeaderHeight = -_notifier.position;
        if (_heldHeaderHeight > max_head_view_height) {
          _heldHeaderHeight = max_head_view_height;
        }
        _isHoldingHeader = true;
        _isAnimatingClose = false; // Ensure this is false when we start holding

        _hideHeaderTimer?.cancel();
        _hideHeaderTimer = Timer(const Duration(seconds: 5), () {
          if (!mounted) return;
          setState(() {
            _isHoldingHeader = false;
            _isAnimatingClose = true; // Start the closing animation
          });
        });
      });
    }

    // If user starts dragging again, cancel any pending animations/timers
    if (_notifier.phase == ScrollPhase.dragging) {
      if (_isHoldingHeader || _isAnimatingClose) {
        setState(() {
          _isHoldingHeader = false;
          _isAnimatingClose = false;
          _hideHeaderTimer?.cancel();
          print("取消定时任务");
        });
      }
    }

    _previousPhase = _notifier.phase;
  }

  String statusText() {
    if (_isHoldingHeader) {
      return '模拟刷新中...';
    }
    if (_isAnimatingClose) {
      return '刷新完成';
    }
    switch (_notifier.phase) {
      case ScrollPhase.ballistic:
        return '回弹中';
      case ScrollPhase.settling:
        return '回弹结束';
      case ScrollPhase.idle:
        return '静止';
      case ScrollPhase.dragging:
        return _notifier.direction == ScrollDirection.down ? '下拉中' : '上推中';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bouncing Scroll State Demo')),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _notifier,
            builder: (context, child) {
              double headViewHeight;

              if (_isHoldingHeader) {
                headViewHeight = _heldHeaderHeight;
              } else if (_isAnimatingClose) {
                // Target for the closing animation
                headViewHeight = 0;
              } else {
                // Normal drag behavior
                final scrollValue = _notifier.position;
                headViewHeight = 0;
                if (scrollValue < 0) {
                  headViewHeight = -scrollValue;
                }
                if (headViewHeight > max_head_view_height) {
                  headViewHeight = max_head_view_height;
                }
              }
              if (headViewHeight < 0) {
                headViewHeight = 0;
              }

              // By using AnimatedContainer and dynamically changing the duration,
              // we get animation only when we want it.
              return AnimatedContainer(
                duration: _isAnimatingClose
                    ? const Duration(milliseconds: 300) // Animate when closing
                    : Duration.zero,
                // No animation during drag
                curve: Curves.easeOut,
                height: headViewHeight,
                onEnd: () {
                  // Reset the flag after the animation is done
                  if (_isAnimatingClose) {
                    setState(() {
                      _isAnimatingClose = false;
                    });
                  }
                },
                color: Colors.yellow,
                alignment: Alignment.center,
                child: Text(
                  'Position: ${_notifier.position.toStringAsFixed(2)}\n'
                  'Status: ${statusText()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              physics: NotifyingBouncingScrollPhysics(
                notifier: _notifier,
                parent: const AlwaysScrollableScrollPhysics(),
              ),
              itemCount: 50,
              itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ],
      ),
    );
  }
}
