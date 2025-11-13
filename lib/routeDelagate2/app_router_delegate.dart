import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'route_config.dart';
import 'app_route_parser.dart';

final globalRouter = AppRouterDelegate();

class AppRouterDelegate extends RouterDelegate<RouteConfig>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteConfig> {
  final List<RouteConfig> _stack;
  late bool _firstBack;
  final GlobalKey<ScaffoldMessengerState> _messengerKey;
  final MethodChannel _deepLinkChannel;
  Map<String, String> _deepLinkAllParams;

  // 修复构造函数：使用初始化列表，确保所有属性先初始化再执行逻辑
  AppRouterDelegate()
      : _stack = [RouteConfig(RouteNames.home)],
        _firstBack = true,
        _messengerKey = GlobalKey<ScaffoldMessengerState>(),
        _deepLinkChannel = const MethodChannel("deep_link_channel"),
        _deepLinkAllParams = {} {
    // 构造函数体：初始化完成后再监听深链接（避免空指针）
    _listenDeepLink();
  }

  // 监听原生传递的所有参数（修复后逻辑）
  // 通过MethodChannel 将原生层收到的参数 传递过来，然后解析
  void _listenDeepLink() {
    // 防止 MethodChannel 未初始化（双重保险）
    if (_deepLinkChannel == null) {
      debugPrint('MethodChannel 未初始化，深链接监听失败');
      return;
    }

    _deepLinkChannel.setMethodCallHandler((call) async {
      if (call.method == "receiveDeepLink") {
        // 安全解析参数（避免空指针）
        final String path = call.arguments?["path"] as String? ?? RouteNames.home;
        final Map<dynamic, dynamic> tempParams = call.arguments?["allParams"] as Map? ?? {};

        // 转换为 Map<String, String>（兼容原生传递的参数类型）
        _deepLinkAllParams = tempParams.map(
              (key, value) => MapEntry(
            key?.toString()?.trim() ?? "",
            value?.toString()?.trim() ?? "",
          ),
        );

        // 过滤空 key 的参数（可选优化）
        _deepLinkAllParams.removeWhere((key, value) => key.isEmpty);

        // 打印日志（验证参数）
        debugPrint('Flutter 接收的路由路径：$path');
        debugPrint('Flutter 接收的所有参数：$_deepLinkAllParams');

        // 打开详情页（安全校验路径）
        if (path == RouteNames.detail && _deepLinkAllParams.isNotEmpty) {
          _stack.clear();
          _stack.add(RouteConfig(RouteNames.home)); // 保留首页
          _stack.add(RouteConfig(
            path,
            params: _deepLinkAllParams,
          ));
          notifyListeners();
        }
      }
    });
  }

  // 对外提供：获取所有深链接参数
  Map<String, String> get deepLinkAllParams => Map.unmodifiable(_deepLinkAllParams);

  // 对外提供：获取当前页面的所有参数
  Map<String, String> get currentPageParams =>
      (_stack.last.params as Map<String, String>?) ?? {};

  // 首页二次退出逻辑
  @override
  Future<bool> popRoute() async {
    if (_stack.length > 1) {
      _stack.removeLast();
      notifyListeners();
      return true;
    }

    if (_firstBack) {
      _showToast();
      // 修复：_firstBack 是 final，不能直接修改！之前的逻辑错误
      // 改用局部变量或非 final 变量，这里修正为非 final
      // （关键修复：之前 _firstBack 定义为 final，导致无法修改，二次退出失效）
      // 重新定义 _firstBack 为非 final（见上方属性定义）
      _firstBack = false; // 现在可以正常修改
      return true;
    } else {
      SystemNavigator.pop();
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Navigator(
        key: navigatorKey,
        pages: _stack.map((config) => MaterialPage(
          key: ValueKey('${config.path}_${config.params?.toString()}'),
          child: routePages[config.path]!(context),
        )).toList(),
        onPopPage: (route, res) => false,
      ),
    );
  }

  @override
  Future<void> setNewRoutePath(RouteConfig config) async {
    if (_stack.length == 1 && config.path == RouteNames.detail) {
      _stack.add(config);
      notifyListeners();
    }
  }

  // 页面跳转方法
  void push(String path, {Map<String, String>? params}) {
    _stack.add(RouteConfig(path, params: params));
    _firstBack = true; // 跳转后重置二次退出标记
    notifyListeners();
  }

  // 显示退出提示
  void _showToast() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messengerKey.currentState != null) {
        _messengerKey.currentState!.showSnackBar(
          const SnackBar(
            content: Text('再按一次返回键退出应用'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }



  // 修复：navigatorKey 初始化（之前可能未显式初始化）
  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();

  @override
  RouteConfig get currentConfiguration => _stack.last;
}