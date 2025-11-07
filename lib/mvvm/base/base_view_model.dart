import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import '../utils/toast.dart';

enum LoadStatus { initial, loading, success, empty, error }

abstract class BaseViewModel extends ChangeNotifier {
    LoadStatus _loadStatus = LoadStatus.initial;
    String? _errorMessage;

    LoadStatus get loadStatus => _loadStatus;
    String? get errorMessage => _errorMessage;

    void updateStatus(LoadStatus status, {String? errorMsg}) {
        _loadStatus = status;
        _errorMessage = errorMsg;
        notifyListeners();
    }

    Future<void> loadData() async {
        updateStatus(LoadStatus.loading);
        try {
            await fetchData();
        } catch (e) {
            if (loadStatus != LoadStatus.error) {
                updateStatus(LoadStatus.error, errorMsg: e.toString());
            }
        }
    }

    Future<void> fetchData();

    void showToast(String message) {
        ToastUtil.show(message);
    }

    void navigateTo(BuildContext context, Widget page) {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
        );
    }
}