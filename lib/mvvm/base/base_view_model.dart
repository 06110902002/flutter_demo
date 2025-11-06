import 'package:flutter/material.dart'; 
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../utils/toast.dart';

enum LoadStatus
{
    initial, loading, success, empty, error
}

/// ViewModel 基类，所有页面数据通知基类，数据处理逻辑需要继承这个类
abstract class BaseViewModel extends ChangeNotifier
{
    LoadStatus _loadStatus = LoadStatus.initial;
    String? _errorMessage;

    LoadStatus get loadStatus => _loadStatus;
    String? get errorMessage => _errorMessage;

    /// 页面数据处理时状态机
    void updateStatus(LoadStatus status, {String? errorMsg}) 
    {
        _loadStatus = status;
        _errorMessage = errorMsg;
        notifyListeners();
    }

    Future<void> loadData() async
    {
        updateStatus(LoadStatus.loading);
        try
        {
            await fetchData();
        }
        catch (e)
        {
            if (loadStatus != LoadStatus.error) 
            {
                updateStatus(LoadStatus.error, errorMsg: e.toString());
            }
        }
    }

    /// 获取数据 子类需要重载该方法
    Future<void> fetchData();

    void showToast(String message) 
    {
        ToastUtil.show(message);
    }

   /// 页面跳转
    void navigateTo(BuildContext context, Widget page) 
    {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page)
        );
    }
}
