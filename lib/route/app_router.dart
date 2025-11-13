import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_page.dart';
import 'details_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'animation_page.dart';

// 路由路径常量
class RoutePaths {
  static const String home = '/';
  static const String details = '/details';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String animation = '/animation';
}

// 路由参数键
class RouteParams {
  static const String id = 'id';
  static const String title = 'title';
  static const String data = 'data';
}

// 路由返回结果键
class RouteResultKeys {
  static const String message = 'message';
  static const String data = 'data';
  static const String action = 'action';
}

// 页面构建工具类
class PageBuilderUtils {
  // 构建带 Material 动画的页面
  static CustomTransitionPage buildPageWithAnimation({
    required Widget child,
    required GoRouterState state,
    bool fullscreenDialog = false,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      fullscreenDialog: fullscreenDialog,
    );
  }

  // 构建自定义动画页面
  static CustomTransitionPage buildCustomAnimationPage({
    required Widget child,
    required GoRouterState state,
    required String animationType,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (animationType) {
          case 'fade':
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case 'scale':
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          case 'rotation':
            return RotationTransition(
              turns: animation,
              child: child,
            );
          case 'slide':
          default:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
        }
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

class AppRouter {
  late final GoRouter _router;
  final List<RouteRecord> _routeHistory = [];
  final ValueNotifier<String> _currentRoute = ValueNotifier<String>('/');
  final List<VoidCallback> _listeners = [];

  AppRouter() {
    _router = GoRouter(
      routes: [
        // 主页
        GoRoute(
          path: RoutePaths.home,
          name: 'home',
          pageBuilder: (context, state) {
            return PageBuilderUtils.buildPageWithAnimation(
              child: const HomePage(),
              state: state,
            );
          },
        ),

        // 详情页 - 支持参数
        GoRoute(
          path: '${RoutePaths.details}/:${RouteParams.id}',
          name: 'details',
          pageBuilder: (context, state) {
            final id = int.tryParse(state.pathParameters[RouteParams.id] ?? '0') ?? 0;
            final extraData = state.extra as Map<String, dynamic>?;

            return PageBuilderUtils.buildPageWithAnimation(
              child: DetailsPage(
                itemId: id,
                extraData: extraData,
              ),
              state: state,
            );
          },
        ),

        // 个人资料页
        GoRoute(
          path: RoutePaths.profile,
          name: 'profile',
          pageBuilder: (context, state) {
            return PageBuilderUtils.buildPageWithAnimation(
              child: const ProfilePage(),
              state: state,
              fullscreenDialog: true,
            );
          },
        ),

        // 设置页
        GoRoute(
          path: RoutePaths.settings,
          name: 'settings',
          pageBuilder: (context, state) {
            return PageBuilderUtils.buildPageWithAnimation(
              child: const SettingsPage(),
              state: state,
            );
          },
        ),

        // 动画页面
        GoRoute(
          path: RoutePaths.animation,
          name: 'animation',
          pageBuilder: (context, state) {
            final animationType = state.uri.queryParameters['type'] ?? 'slide';
            return PageBuilderUtils.buildCustomAnimationPage(
              child: const AnimationPage(),
              state: state,
              animationType: animationType,
            );
          },
        ),
      ],

      // 路由观察者 - 监听生命周期
      observers: [
        _RouteObserver(),
      ],

      // 错误页面
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('页面未找到')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('页面未找到: ${state.uri.path}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go(RoutePaths.home),
                  child: const Text('返回首页'),
                ),
              ],
            ),
          ),
        );
      },

      // 重定向逻辑
      redirect: (context, state) {
        _recordRouteChange(state.uri.path);
        return null;
      },
    );
  }

  GoRouter get routerConfig => _router;

  String get currentRoute => _currentRoute.value;

  List<RouteRecord> get routeHistory => List.unmodifiable(_routeHistory);

  // 添加监听器
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // 移除监听器
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // 通知监听器
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  // 记录路由变化
  void _recordRouteChange(String path) {
    _currentRoute.value = path;
    _routeHistory.add(RouteRecord(
      path: path,
      timestamp: DateTime.now(),
    ));
    _notifyListeners();
  }

  // 公共导航方法
  void navigateToHome(BuildContext context) {
    context.go(RoutePaths.home);
  }

  void navigateToDetails(BuildContext context, int id, {Map<String, dynamic>? extraData}) {
    context.go('${RoutePaths.details}/$id', extra: extraData);
  }

  void navigateToProfile(BuildContext context) {
    context.go(RoutePaths.profile);
  }

  void navigateToSettings(BuildContext context) {
    context.go(RoutePaths.settings);
  }

  void navigateWithAnimation(BuildContext context, String animationType) {
    context.go('${RoutePaths.animation}?type=$animationType');
  }

  // 带返回值的导航
  Future<T?> pushForResult<T>(BuildContext context, String path, {Object? extra}) async {
    return await context.push<T>(path, extra: extra);
  }

  void dispose() {
    _listeners.clear();
  }
}

// 路由记录
class RouteRecord {
  final String path;
  final DateTime timestamp;

  RouteRecord({
    required this.path,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'RouteRecord{path: $path, timestamp: $timestamp}';
  }
}

// 路由观察者 - 监听页面生命周期
class _RouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('🚀 页面进入: ${route.settings.name}');
    print('📊 前一页面: ${previousRoute?.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('↩️ 页面退出: ${route.settings.name}');
    print('📊 返回至: ${previousRoute?.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('🔄 页面替换: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('🗑️ 页面移除: ${route.settings.name}');
  }
}

// 路由感知 Mixin
mixin RouteAware {
  void onRouteChanged(String newRoute) {}
}