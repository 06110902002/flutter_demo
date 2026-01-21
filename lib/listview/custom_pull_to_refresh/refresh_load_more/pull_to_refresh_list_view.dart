import 'dart:async';

import 'package:flutter/material.dart';

import '../../../utils/logger_util.dart';
import 'ScrollViewBehavior.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/7 19:49
/// @Copyright by JYXC Since 2023
/// Description: 支持下拉刷新，上拉加载更多的滚动列表，目前仅支持垂直方向,在custom_pull_to_refresh.dart 版本上修改
///
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
  ballisticUp, //向上回弹
  ballisticDown, //向下回弹
  settling, // 回弹结束
  idle, // 静止
}

/// A builder function that creates a widget for the refresh header.
///
/// [context] The build context.
/// [phase] The current scroll phase of the list.
/// [isHolding] Whether the header is currently held in the "refreshing" state.
/// [canRefresh] Whether the user has dragged far enough to trigger a refresh.
/// [refreshCompleted] Whether the refresh has just completed (for showing a success message).
/// [dragOffset] The current drag offset when in the `dragging` phase.
typedef HeadViewBuilder =
    Widget Function(
      BuildContext context,
      ScrollPhase phase,
      bool isHolding,
      bool canRefresh,
      bool refreshCompleted,
      double dragOffset,
    );

///加载更多 底部视图
/// [loading] 加载中的状态
/// [loadComplete] 加载完成
typedef FootViewBuilder = Widget Function(bool loading, bool loadComplete);

/// listView 组件构建器，主要是将ScrollPhysics 这类参数封装方便外部使用
typedef ScrollBehaviorBuilder = ScrollBehavior Function(ScrollPhysics? physics);

/// =======================
/// ChangeNotifier with Safe Notification Scheduling
/// 滚动时的数据通知
/// =======================
class ScrollPositionNotifier extends ChangeNotifier {
  double _position = 0.0;
  double _maxScrollExtent = 0.0;
  ScrollDirection _direction = ScrollDirection.idle;
  ScrollPhase _phase = ScrollPhase.idle;
  bool _isNotificationScheduled = false;

  double get position => _position;

  double get maxScrollExtent => _maxScrollExtent;

  ScrollDirection get direction => _direction;

  ScrollPhase get phase => _phase;

  /// 安全地调度通知，以避免在帧渲染期间调用 notifyListeners
  void _scheduleNotify() {
    if (_isNotificationScheduled) return;
    _isNotificationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasListeners) return;
      _isNotificationScheduled = false;
      notifyListeners();
    });
  }

  /// 用户拖动
  void onUserDrag(double position, double offset, double maxScrollExtent) {
    _position = position;
    _maxScrollExtent = maxScrollExtent;
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

  /// 开始回弹 区分回弹方向：向下还是向上
  void startBallisticWithDirection(
    double position,
    ScrollPhase ballisticDirection,
    ScrollDirection direction,
  ) {
    _position = position;
    _phase = ballisticDirection;
    _direction = direction; // 回弹区分向下还是向上
    _scheduleNotify();
  }

  /// 回弹过程中
  void updateBallistic(double position) {
    /// 处理三种回弹情况，防止不更新滚动值，导致listView 回弹暂停
    if (_phase != ScrollPhase.ballistic &&
        _phase != ScrollPhase.ballisticUp &&
        _phase != ScrollPhase.ballisticDown) {
      return;
    }
    _position = position;
    _scheduleNotify();
  }

  /// 回弹结束
  void finishBallistic() {
    if (_phase != ScrollPhase.ballistic &&
        _phase != ScrollPhase.ballisticUp &&
        _phase != ScrollPhase.ballisticDown) {
      return;
    }
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
/// ScrollPhysics 滚动监听，适配android /IOS 平台
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
    notifier.onUserDrag(newPixels, offset, position.maxScrollExtent);
    return super.applyPhysicsToUserOffset(position, offset);
  }

  ///用户松手后的“惯性阶段”（可能是 fling，也可能是 overscroll 回弹）
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
    //向上回弹
    final bool isOverscrollTop = position.pixels < position.minScrollExtent;
    //向下回弹
    final bool isOverscrollBottom = position.pixels > position.maxScrollExtent;
    final ScrollPhase ballistDirection = isOverscrollTop
        ? ScrollPhase.ballisticUp
        : ScrollPhase.ballisticDown;
    final ScrollDirection direction = isOverscrollTop
        ? ScrollDirection.up
        : ScrollDirection.down;

    final bool isBounce = isOverscrollTop || isOverscrollBottom;

    return _NotifierSimulation(
      sim,
      notifier,
      position.pixels,
      isBounce,
      ballistDirection,
      direction,
    );
  }
}

/// =======================
/// Simulation 包装，滚动列表的回弹器封装
/// =======================
class _NotifierSimulation extends Simulation {
  final Simulation _sim;
  final ScrollPositionNotifier _notifier;
  final bool _isBounce;
  final ScrollPhase _ballisticDirection;
  final ScrollDirection _direction;

  bool _ended = false;

  _NotifierSimulation(
    this._sim,
    this._notifier,
    double startPosition,
    this._isBounce,
    this._ballisticDirection,
    this._direction,
  ) {
    if (_isBounce) {
      _notifier.startBallisticWithDirection(
        startPosition,
        _ballisticDirection,
        _direction,
      );
    }
  }

  @override
  double x(double time) {
    final value = _sim.x(time);

    if (_isBounce) {
      _notifier.updateBallistic(value);

      if (!_ended && _sim.isDone(time)) {
        _ended = true;

        _notifier.finishBallistic();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notifier.settleToIdle();
        });
      }
    }

    return value;
  }

  @override
  double dx(double time) => _sim.dx(time);

  @override
  bool isDone(double time) => _sim.isDone(time);
}

class PullToRefreshListView extends StatefulWidget {
  /// Callback for pull-to-refresh.
  final FutureOr Function()? onRefresh;

  /// Callback for pull-up-to-load-more.
  final FutureOr Function()? onLoadMore;

  /// A builder for the refresh header.
  final HeadViewBuilder? headViewBuilder;

  final FootViewBuilder? footViewBuilder;

  /// Whether to trigger a refresh on start.
  final bool isOnStartRefresh;

  /// The drag distance required to trigger a refresh.
  final double refreshThreshold;

  /// The drag distance required to trigger a load more.
  final double loadMoreThreshold;

  /// A list of slivers to display in the scroll view.
  final List<Widget> slivers;

  static ScrollBehavior Function(ScrollPhysics? physics)
  defaultScrollBehaviorBuilder = _defaultScrollBehaviorBuilder;

  static ScrollBehavior _defaultScrollBehaviorBuilder(ScrollPhysics? physics) =>
      ScrollViewBehavior(physics);

  const PullToRefreshListView({
    super.key,
    this.onRefresh,
    this.onLoadMore,
    this.isOnStartRefresh = false,
    this.headViewBuilder,
    this.footViewBuilder,
    this.refreshThreshold = 100.0,
    this.loadMoreThreshold = 100.0,
    this.slivers = const <Widget>[],
  });

  @override
  State<PullToRefreshListView> createState() => _PullToRefreshListViewState();
}

class _PullToRefreshListViewState extends State<PullToRefreshListView> {
  final ScrollPositionNotifier _notifier = ScrollPositionNotifier();

  Timer? _hideHeaderTimer;
  ScrollPhase _previousPhase = ScrollPhase.idle;
  bool _isHoldingHeader = false;

  /// This flag is crucial. It's true only when we are animating the close.
  bool _isAnimatingClose = false;
  double _heldHeaderHeight = 0;

  // Refresh state
  bool _canTriggerRefresh = false;
  int _refreshOperationId = 0;

  // Load more state
  bool _isLoadingMore = false;
  bool _isLoading = false;
  bool _loadingComplete = false;
  bool _canTriggerLoadMore = false;

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_handleScrollPhaseChange);
    if (widget.isOnStartRefresh) {
      // Use addPostFrameCallback to ensure the widget is built before starting the refresh.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startRefresh();
        }
      });
    }
  }

  @override
  void dispose() {
    _hideHeaderTimer?.cancel();
    // Invalidate any pending operations to prevent setState calls after dispose.
    _refreshOperationId++;
    _notifier.removeListener(_handleScrollPhaseChange);
    _notifier.dispose();
    super.dispose();
  }

  void _startRefresh() {
    // This is a new refresh operation, so we increment the ID.
    final operationId = ++_refreshOperationId;

    // Pin the header at the threshold height.
    setState(() {
      _heldHeaderHeight = widget.refreshThreshold;
      _isHoldingHeader = true;
      _isAnimatingClose = false;
      _canTriggerRefresh = false; // Reset eligibility
    });

    // A helper function to close the header, which checks the operation ID.
    void closeHeader() {
      // Only close if this is still the active operation and the widget is mounted.
      if (!mounted || operationId != _refreshOperationId) return;
      setState(() {
        _isHoldingHeader = false;
        _isAnimatingClose = true;
      });
    }

    if (widget.onRefresh != null) {
      Future.sync(widget.onRefresh!)
          .then((_) {
            // IMPORTANT: This 'if' statement is the filter.
            if (operationId == _refreshOperationId && mounted) {
              // Only the LATEST refresh task can get inside here.
              closeHeader();
              print("Refresh task with ID $operationId succeeded.");
            } else {
              // This block is executed for outdated, "cancelled" refresh tasks.
              print(
                "Ignoring result from outdated refresh task with ID $operationId (current is $_refreshOperationId).",
              );
            }
          })
          .catchError((error, stackTrace) {
            // Also check for validity on error.
            if (operationId == _refreshOperationId && mounted) {
              print('onRefresh 捕获错误: $error');
              closeHeader();
            }
          });
    } else {
      _hideHeaderTimer?.cancel();
      _hideHeaderTimer = Timer(const Duration(seconds: 5), closeHeader);
    }
  }

  void _startLoadMore() {
    if (!mounted || widget.onLoadMore == null) return;

    setState(() {
      _isLoadingMore = true;
      _isLoading = true;
      _loadingComplete = false;
    });
    LoggerUtil.d("Starting to load more...");

    Future.sync(widget.onLoadMore!).whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _isLoading = false;
          _loadingComplete = true;
        });
        LoggerUtil.d("Load more finished.");
      }
    });
  }

  void _handleScrollPhaseChange() {
    // --- Part 1: Handle User Dragging ---
    if (_notifier.phase == ScrollPhase.dragging) {
      // When user starts scrolling, hide the "load complete" message.
      if (_loadingComplete) {
        setState(() {
          _loadingComplete = false;
        });
      }

      // --- Refresh part during drag ---
      if (_isHoldingHeader || _isAnimatingClose) {
        _refreshOperationId++;
        _hideHeaderTimer?.cancel();
        setState(() {
          _isHoldingHeader = false;
          _isAnimatingClose = false;
        });
      }
      _canTriggerRefresh = -_notifier.position >= widget.refreshThreshold;

      // --- Load More part during drag ---
      if (widget.onLoadMore != null && !_isLoadingMore) {
        final overscroll = _notifier.position - _notifier.maxScrollExtent;
        if (overscroll > 0) {
          _canTriggerLoadMore = overscroll >= widget.loadMoreThreshold;
        }
      }
    }
    // --- Part 2: Handle User Releasing Finger for Refresh ---
    else if (_previousPhase == ScrollPhase.dragging &&
        _notifier.phase == ScrollPhase.ballisticUp) {
      if (_canTriggerRefresh && !_isHoldingHeader) {
        _startRefresh();
      }
      _canTriggerRefresh = false;
    }
    // --- Part 3: Handle User Releasing Finger for Load More ---
    else if (_previousPhase == ScrollPhase.dragging &&
        _notifier.phase == ScrollPhase.ballisticDown) {
      if (_canTriggerLoadMore && !_isLoadingMore) {
        _startLoadMore();
      }
      _canTriggerLoadMore = false;
    }

    _previousPhase = _notifier.phase;
  }

  /// This helper builds the header, either using the provided builder
  /// or falling back to a default text widget.
  Widget _buildHeaderView() {
    // If a custom builder is provided, use it.
    if (widget.headViewBuilder != null) {
      // Pass the latest state directly to the builder.
      return widget.headViewBuilder!(
        context,
        _notifier.phase,
        _isHoldingHeader,
        _canTriggerRefresh,
        _isAnimatingClose, // Pass the completion state
        _notifier.position,
      );
    }

    // Default widget if no builder is provided.
    return Text(
      'Position: ${_notifier.position.toStringAsFixed(2)}\n'
      'Status: some status',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 18),
    );
  }

  ScrollBehaviorBuilder get _scrollBehaviorBuilder =>
      PullToRefreshListView.defaultScrollBehaviorBuilder;

  Widget _buildContentListView() {
    final physics = NotifyingBouncingScrollPhysics(
      notifier: _notifier,
      parent: const AlwaysScrollableScrollPhysics(),
    );

    // Create a mutable list from the provided slivers.
    final allSlivers = List<Widget>.from(widget.slivers);

    // If onLoadMore is enabled, add the bottom status indicator as the last sliver.
    if (widget.onLoadMore != null) {
      allSlivers.add(SliverToBoxAdapter(child: _buildBottomStatusWidget()));
    }

    return ScrollConfiguration(
      behavior: _scrollBehaviorBuilder(null),
      // Physics is applied to CustomScrollView.
      child: CustomScrollView(physics: physics, slivers: allSlivers),
    );
  }

  /// 加载更多数据 - 作为列表的一部分
  Widget _buildBottomStatusWidget() {
    if (widget.footViewBuilder != null) {
      return widget.footViewBuilder!(_isLoading, _loadingComplete);
    }

    if (_isLoading) {
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
    } else if (_loadingComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        alignment: Alignment.center,
        child: const Text(
          "加载完成",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              alignment: Alignment.center,
              // The child is built by our helper, which uses the builder function.
              // Wrap the child in a ClipRect to prevent it from painting
              // outside the AnimatedContainer's bounds as it shrinks.
              child: ClipRect(child: _buildHeaderView()),
            );
          },
        ),
        Expanded(child: _buildContentListView()),
      ],
    );
  }
}
