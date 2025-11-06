/// @author: jiangjunhui
/// @date: 2025/2/24
library;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

///import '../http/core/network_service.dart';

// 标准视图状态
enum ViewState { idle, loading, success, error }


abstract class BaseViewModel extends ChangeNotifier {
  // 状态标记
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  //NetworkService networkService = NetworkService();

  /// onInit()：Controller 初始化时触发，适合初始化数据
  @mustCallSuper
  void onInit() {}

  /// onDispose()：Controller 销毁时触发，用于资源清理
  @mustCallSuper
  void onDispose() {
    //networkService.cancelAllRequests();
  }

  /// 统一请求网络
  void loadData() {}

  /// 统一错误处理入口 handleError()
  void handleError(dynamic error) {
    debugPrint('Controller Error: $error');
    // 可扩展统一错误处理逻辑
  }

  BaseViewModel() {
    onInit();
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      onDispose();
      super.dispose();
    }
  }

  /*
  * 提供 safeNotify() 方法，避免在 disposed 状态下触发通知 继承 ChangeNotifier 实现自动监听管理
  * */
  // 安全更新方法（防重复通知）
  @protected
  void safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  // 状态管理扩展
  ViewState _state = ViewState.idle;

  ViewState get state => _state;

  void setState(ViewState newState) {
    _state = newState;
    safeNotify();
  }
}

/*
class UserViewModel extends BaseViewModel {
  final UserRepository _repository;
  User? _user;
  String? _errorMessage;

  User? get user => _user;
  String? get errorMessage => _errorMessage;

  UserViewModel(this._repository); // 依赖注入

  Future<void> loadUser() async {
    setState(ViewState.loading);
    try {
      _user = await _repository.fetchUser();
      setState(ViewState.success);
    } catch (e) {
      _errorMessage = 'Failed to load user: ${e.toString()}';
      setState(ViewState.error);
      handleError(e);
    }
  }

  @override
  void onDispose() {
    _user = null;
    super.onDispose();
  }
}
* */
