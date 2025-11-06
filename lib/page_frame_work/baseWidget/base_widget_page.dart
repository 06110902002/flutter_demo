/// @author: jiangjunhui
/// @date: 2025/2/24
library;
import 'package:flutter/material.dart';

import '../log/log.dart';
import '../router/route_aware_state.dart';

/// 页面基类（StatefulWidget 版本）
abstract class BaseWidgetPage extends StatefulWidget {
  const BaseWidgetPage({super.key});
}

/// 页面基类状态管理
abstract class BaseWidgetPageState<T extends BaseWidgetPage>
    extends RouteAwareState<T> with WidgetsBindingObserver {
  /// AppBar 标题
  String get appBarTitle => '默认标题';

  /// AppBar 背景色（默认使用主题色）
  Color getAppBarColor(BuildContext context) => Theme.of(context).primaryColor;

  /// 是否自动显示返回按钮（默认 true）
  /// 1.leading 属性拥有最高优先级：
  /// •如果您为 leading 属性提供了一个非 null 的 Widget（就像您代码中的 Icon(Icons.arrow_left)），
  /// 那么 AppBar 将永远显示您提供的这个 Widget。
  /// •在这种情况下，automaticallyImplyLeading 属性的值会被完全忽略，无论您将它设置为 true 还是 false。
  /// 2.automaticallyImplyLeading 属性是备用选项：
  /// •只有当 leading 属性为 null（也就是您没有手动指定 leading Widget）时，automaticallyImplyLeading 才会生效。
  /// •当 automaticallyImplyLeading 为 true (默认值) 时，Flutter 会检查当前页面是否可以返回（例如，它是否是通过 Navigator.push 打开的）。
  /// 如果可以返回，Flutter 会自动创建一个返回按钮（通常是一个 IconButton 包裹的箭头图标）。
  /// •当 automaticallyImplyLeading 为 false 时，Flutter 将不会自动创建任何按钮，leading 位置会保持空白。
  bool get automaticallyImplyLeading => true;

  /// AppBar 右侧操作按钮
  List<Widget>? get appBarActions => null;

  String get pageID => '当前pageId';

  /// 构建页面主体内容（子类必须实现）
  Widget buildBody(BuildContext context);

  /// 构建 AppBar（可覆盖自定义）
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(appBarTitle),
      centerTitle: true,
      backgroundColor: getAppBarColor(context),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: appBarActions,
    );
  }

  /// 构建浮动按钮（默认不显示）
  FloatingActionButton? buildFloatingActionButton(BuildContext context) => null;

  @override
  void initState() {
    super.initState();
    Log.initialize(options: LogOptions(printTime: true));
    Log.debug('61----------页面初始化');
    // 可以在这里添加一些通用的初始化逻辑
    WidgetsBinding.instance.addObserver(this);
    onPageInit();
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 可以在这里添加一些通用的资源释放逻辑
    onPageDispose();
    super.dispose();
  }

  // 可以被子类重写的初始化方法
  void onPageInit() {}

  // 可以被子类重写的资源释放方法
  void onPageDispose() {}

  @override
  void onPageVisible() {
    print('页面变为可见');
  }

  @override
  void onPageHidden() {
    print('页面变为隐藏');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('应用回到前台，页面可见');

    } else if (state == AppLifecycleState.paused) {
      print('应用进入后台，页面隐藏');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
      floatingActionButton: buildFloatingActionButton(context),
      // 可根据需要添加 drawer、bottomNavigationBar 等通用组件
    );
  }
}

/*
// 具体页面实现
class MyHomePage extends WidgetPageBase {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends WidgetPageBaseState<MyHomePage> {
  int _counter = 0;

  @override
  String get appBarTitle => '我的主页';

  @override
  Color getAppBarColor(BuildContext context) => Colors.blue;

  @override
  List<Widget> get appBarActions => [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _counter++),
        ),
      ];

  @override
  Widget buildBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('当前计数：'),
          Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }

  @override
  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => setState(() => _counter--),
      child: const Icon(Icons.remove),
    );
  }
}
* */
