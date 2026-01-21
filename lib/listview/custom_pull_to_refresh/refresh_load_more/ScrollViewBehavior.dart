import 'dart:ui';

import 'package:flutter/material.dart';

/// Author: Rambo.Liu
/// Date: 2026/1/8 16:59
/// @Copyright by JYXC Since 2023
/// Description:
/// 滚动列表的 滚动行为，封装这个方便在外部传递滚动列表进来，因为滚动监听是在组件内部处理的
/// 同时支持web 与pc 的滚动行为
class ScrollViewBehavior extends ScrollBehavior {
  static final Set<PointerDeviceKind> _kDragDevices = PointerDeviceKind.values
      .toSet();

  final ScrollPhysics? _physics;

  const ScrollViewBehavior([this._physics]);

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return _physics ?? super.getScrollPhysics(context);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        assert(details.controller != null);
        if (details.controller!.positions.length > 1 ||
            details.controller!.debugLabel == 'inner') {
          return child;
        }
        return Scrollbar(controller: details.controller, child: child);
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
      default:
        return child;
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices => _kDragDevices;
}
