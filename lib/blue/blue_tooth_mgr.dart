import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum ConnectStatus { connecting, connected, disconnected, error }

/// 扫描回调
typedef OnScanListener = void Function(List<ScanResult> results);

/// 连接状态回调
typedef OnConnectListener =
    void Function(BluetoothConnectionState status, BluetoothDevice device);

/// 配对状态回调
typedef OnBondStateListener =
    void Function(BluetoothBondState state, BluetoothDevice device);

/// ble 管理器
class BlueToothMgr {
  static BlueToothMgr? _instance = null;

  BlueToothMgr._internal();

  static BlueToothMgr get instance {
    _instance ??= BlueToothMgr._internal();
    return _instance!;
  }

  final int scanTimeOut = 10;
  bool _isScanning = false;

  bool isScanning() => _isScanning;

  BluetoothDevice? _connectedDevice;

  BluetoothDevice? get connectedDevice => _connectedDevice;

  Future<bool> requestPermissions() async {
    PermissionStatus status = await Permission.bluetoothScan.request();
    if (status != PermissionStatus.granted) {
      print("蓝牙扫描权限申请失败");
      return false;
    }

    status = await Permission.bluetoothConnect.request();
    if (status != PermissionStatus.granted) {
      print("蓝牙连接权限申请失败");
      return false;
    }

    status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      print("位置权限申请失败");
      return false;
    }

    print("所有权限已授予");
    return true;
  }

  Future<bool> initBlueTooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("此设备不支持蓝牙");
      return false;
    }

    if (await FlutterBluePlus.isOn == false) {
      await FlutterBluePlus.turnOn();
    }

    // 确保蓝牙适配器已开启
    try {
      await FlutterBluePlus.adapterState
          .firstWhere((state) => state == BluetoothAdapterState.on)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      print("开启蓝牙超时");
      return false;
    }
    return true;
  }

  void startScan({OnScanListener? onScan}) async {
    if (_isScanning) {
      print("正在扫描,无需重复扫描......");
      return;
    }
    _isScanning = true;
    FlutterBluePlus.scanResults.listen((results) {
      onScan?.call(
        results.where((result) => result.device.name.isNotEmpty).toList(),
      );
    });

    await FlutterBluePlus.startScan(timeout: Duration(seconds: scanTimeOut));

    Future.delayed(Duration(seconds: scanTimeOut), () {
      print("扫描完成");
      stopScan();
    });
  }

  void stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  /// 获取当前已配对的设备列表
  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await FlutterBluePlus.bondedDevices;
  }

  /// 连接设备，并在连接后处理配对
  void connectToDevice(
    BluetoothDevice device, {
    OnConnectListener? connectListener,
    OnBondStateListener? bondStateListener,
  }) async {
    // 如果已连接，直接报告成功并返回
    if (device.isConnected) {
      print('当前设备已经连接，无需重复连接: ${device.name}');
      connectListener?.call(BluetoothConnectionState.connected, device);
      return;
    }

    // 核心逻辑：先连接，连接成功后再处理配对
    _actualConnect(device, connectListener, bondStateListener);
  }

  /// 实际的连接与配对处理方法
  void _actualConnect(
    BluetoothDevice device,
    OnConnectListener? connectListener,
    OnBondStateListener? bondStateListener, // 传递配对监听器
  ) async {
    StreamSubscription<BluetoothConnectionState>? connectionSubscription;
    connectionSubscription = device.connectionState.listen((state) async {
      // 设置为 async 以便使用 await
      // 传递连接状态
      connectListener?.call(state, device);

      if (state == BluetoothConnectionState.connected) {
        _connectedDevice = device;
        print('已连接到设备: ${device.name}');

        // --- 配对逻辑 ---
        // 连接成功后，检查配对状态
        var currentBondState = await device.bondState.first;
        if (currentBondState == BluetoothBondState.bonded) {
          print("设备已经配对。");
          bondStateListener?.call(BluetoothBondState.bonded, device);
        } else {
          print("设备未配对，发起配对请求...");
          // 监听配对过程的状态变化
          StreamSubscription<BluetoothBondState>? bondSub;
          bondSub = device.bondState.listen((bondState) {
            bondStateListener?.call(bondState, device);
            print("设备 ${device.name} 配对状态: $bondState");
            if (bondState == BluetoothBondState.bonded ||
                bondState == BluetoothBondState.none) {
              bondSub?.cancel(); // 配对完成或失败后取消监听
            }
          });
          try {
            // 现在设备已连接，可以成功发起配对
            await device.createBond(timeout: 30);
          } catch (e) {
            print("发起配对请求时出错: $e");
            bondSub.cancel();
          }
        }
        // --- 配对逻辑结束 ---
      } else if (state == BluetoothConnectionState.disconnected) {
        if (_connectedDevice?.id == device.id) {
          _connectedDevice = null;
        }
        print('设备已断开连接: ${device.name}');
        connectionSubscription?.cancel();
      }
    });

    try {
      print("正在发起连接，为后续配对做准备...");
      // 注意：移除了不标准的 `license` 参数
      await device.connect(
        license: License.free,
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      print('连接设备时发生错误: $e');
      connectListener?.call(BluetoothConnectionState.disconnected, device);
      connectionSubscription?.cancel();
    }
  }

  void disconnectDevice(
    BluetoothDevice device, {
    OnConnectListener? connectListener,
  }) async {
    await device.disconnect();
    _connectedDevice = null;
    print('已断开连接: ${device.name}');
    connectListener?.call(BluetoothConnectionState.disconnected, device);
  }
}
