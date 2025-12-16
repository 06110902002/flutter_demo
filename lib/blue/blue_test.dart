import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'blue_tooth_mgr.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蓝牙扫描示例',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  Map<String, String> _connectionStatus = {}; // 用于存储设备的连接状态

  @override
  void initState() {
    super.initState();
    // _requestPermissions();
    // _initBluetooth();
    BlueToothMgr.instance
        .initBlueTooth()
        .then((result) {
          print("39------initStatus: $result");
        })
        .catchError((error) {
          print("42------error: $error");
        });

    Future.delayed(Duration(seconds: 5), () {
      print("测试获取已经绑定的蓝牙设备");
      getBondDevices();
    });
  }

  void getBondDevices() async {
    List<BluetoothDevice> bondedDevices = await BlueToothMgr.instance
        .getBondedDevices();
    for (var device in bondedDevices) {
      print('已配对设备: ${device.name} - ${device.id}');
    }
  }

  // 请求必要的权限
  void _requestPermissions() async {
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  // 初始化蓝牙
  void _initBluetooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      print("此设备不支持蓝牙");
      return;
    }

    if (await FlutterBluePlus.isOn == false) {
      await FlutterBluePlus.turnOn();
    }

    // 确保蓝牙适配器已开启
    await FlutterBluePlus.adapterState.firstWhere(
      (state) => state == BluetoothAdapterState.on,
    );
  }

  // 开始扫描
  void _startScan() async {
    BlueToothMgr.instance.startScan(
      onScan: (results) {
        setState(() {
          _scanResults = results;
        });
      },
    );

    // 原来的使用方法
    // if (_isScanning) return;
    //
    // setState(() {
    //   _isScanning = true;
    //   _scanResults.clear();
    // });
    // await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    //
    // FlutterBluePlus.scanResults.listen((results) {
    //   setState(() {
    //     _scanResults = results
    //         .where((result) => result.device.name.isNotEmpty)
    //         .toList();
    //   });
    // });
    //
    // // 15秒后停止扫描
    // Future.delayed(const Duration(seconds: 15), () {
    //   _stopScan();
    // });
  }

  // 停止扫描
  void _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  // 连接到设备
  void _connectToDevice(BluetoothDevice device) async {
    BlueToothMgr.instance.connectToDevice(
      device,
      connectListener: (status, device) {
        print("连接状态 status: $status, device: $device");
        setState(() {});
      },
    );

    // if (_connectedDevice == device) {
    //   // 如果当前设备已连接，点击时断开连接
    //   await device.disconnect();
    //   setState(() {
    //     _connectedDevice = null;
    //     _connectionStatus[device.id.toString()] = '未连接';
    //   });
    //   print('已断开连接: ${device.name}');
    //   return;
    // }
    //
    // // 如果有其他设备已连接，先断开连接
    // if (_connectedDevice != null) {
    //   await _connectedDevice!.disconnect();
    // }
    //
    // // 监听设备连接状态
    // StreamSubscription? connectionSubscription;
    // connectionSubscription = device.state.listen((state) {
    //   setState(() {
    //     _connectionStatus[device.id.toString()] = state.toString();
    //   });
    //   if (state == BluetoothDeviceState.connected) {
    //     _connectedDevice = device;
    //     print('已连接到设备: ${device.name}');
    //   } else if (state == BluetoothDeviceState.disconnected) {
    //     _connectedDevice = null;
    //     print('设备已断开连接: ${device.name}');
    //   }
    //   connectionSubscription?.cancel();
    // });
    //
    // try {
    //   await device.connect(autoConnect: false);
    // } catch (e) {
    //   setState(() {
    //     _connectionStatus[device.id.toString()] = '连接失败';
    //   });
    //   print('连接设备时发生错误: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('蓝牙扫描示例')),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(child: _buildScanResults()),
        ],
      ),
    );
  }

  // 控制面板
  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              child: Text(_isScanning ? '正在扫描...' : '开始扫描'),
            ),
            ElevatedButton(
              onPressed: _isScanning ? _stopScan : null,
              child: Text('停止扫描'),
            ),
          ],
        ),
      ),
    );
  }

  // 扫描结果列表
  Widget _buildScanResults() {
    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        ScanResult result = _scanResults[index];
        BluetoothDevice device = result.device;
        // print(
        //   "204------device name: ${device.name}  device id: ${device.id}   isconnected: ${device.isConnected}",
        // );
        String connectionStatus = device.isConnected ? "已连接" : "未连接";
        return ListTile(
          title: Text(device.name),
          subtitle: Text('${device.id.toString()} - $connectionStatus'),
          trailing: Text(result.rssi.toString()),
          onTap: () => _connectToDevice(device),
        );
      },
    );
  }
}
