import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_protocol.dart';
import 'blue_tooth_mgr.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蓝牙互寻示例',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BluetoothScreen(),
    );
  }
}

/// 聊天/日志记录项
class _LogItem {
  final String text;
  final bool incoming; // true=收到, false=发出/系统
  final bool system;
  _LogItem(this.text, {this.incoming = false, this.system = false});
}

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  bool _isAdvertising = false;
  bool _showAll = false; // 调试: 显示全部设备(不按服务UUID过滤)
  String? _connectingDeviceId;
  int _mtu = 23;

  final List<_LogItem> _logs = [];

  String _localName = "获取中..."; // 本机蓝牙名称(只读)
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final mgr = BlueToothMgr.instance;

    // 收到完整消息 (中心或外围角色)。
    mgr.onMessage = (from, msg, asPeripheral) {
      final role = asPeripheral ? "外围" : "中心";
      String text;
      if (msg.protocolType == ProtocolType.text) {
        text = utf8.decode(msg.data, allowMalformed: true);
      } else {
        text = "0x${msg.protocolType.toRadixString(16)} "
            "${msg.data.length}字节: ${_hex(msg.data)}";
      }
      _addLog("[$role收到] $text", incoming: true);
    };

    mgr.onMtu = (deviceId, mtu) {
      if (mounted) setState(() => _mtu = mtu);
    };

    // 连接关系变化(中心/外围任一角色) -> 刷新界面, 保证两端状态一致。
    mgr.onConnectionChanged = () {
      if (mounted) setState(() {});
    };

    // 扫描结束(超时/主动停止) -> 复位按钮状态。
    mgr.onScanStopped = () {
      if (mounted) setState(() => _isScanning = false);
    };

    mgr.onLog = (log) => _addLog(log, system: true);

    final hasPermission = await mgr.requestPermissions();
    if (hasPermission) {
      await mgr.initBlueTooth();
      // 预先建立 GATT Server, 使本机可被对方发现并写入。
      await mgr.initPeripheral();
      // 读取本机蓝牙名称 (需在蓝牙权限授予后)。
      final name = await mgr.getLocalBluetoothName();
      if (mounted) setState(() => _localName = name);
    } else {
      _addLog("蓝牙权限未授予", system: true);
    }
  }

  String _hex(List<int> data) => data
      .take(32)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join(' ');

  void _addLog(String text,
      {bool incoming = false, bool system = false}) {
    if (!mounted) return;
    setState(() {
      _logs.insert(0, _LogItem(text, incoming: incoming, system: system));
      if (_logs.length > 200) _logs.removeLast();
    });
  }

  void _toggleScan() {
    final mgr = BlueToothMgr.instance;
    if (_isScanning) {
      mgr.stopScan();
      setState(() => _isScanning = false);
    } else {
      setState(() {
        _scanResults = [];
        _isScanning = true;
      });
      mgr.startScan(
        onlyMatching: !_showAll,
        onScan: (results) {
          if (mounted) {
            setState(() {
              _scanResults = results;
              _isScanning = mgr.isScanning();
            });
          }
        },
      );
    }
  }

  void _toggleAdvertising() async {
    final mgr = BlueToothMgr.instance;
    if (_isAdvertising) {
      await mgr.stopAdvertising();
      setState(() => _isAdvertising = false);
    } else {
      await mgr.startAdvertising(_localName);
      setState(() => _isAdvertising = mgr.isAdvertising());
    }
  }

  void _connectToDevice(BluetoothDevice device) {
    final mgr = BlueToothMgr.instance;
    if (device.isConnected) {
      mgr.disconnectDevice(device);
      setState(() {});
      return;
    }
    setState(() => _connectingDeviceId = device.remoteId.str);
    mgr.connectToDevice(
      device,
      connectListener: (status, dev) {
        if (status == BluetoothConnectionState.connected ||
            status == BluetoothConnectionState.disconnected) {
          _connectingDeviceId = null;
        }
        if (status == BluetoothConnectionState.connected) {
          _addLog("已连接 ${dev.platformName}", system: true);
        } else if (status == BluetoothConnectionState.disconnected) {
          _addLog("已断开 ${dev.platformName}", system: true);
        }
        if (mounted) setState(() {});
      },
    );
  }

  void _sendMsg() async {
    final text = _msgController.text;
    if (text.isEmpty) return;
    final mgr = BlueToothMgr.instance;

    bool sent = false;
    // 优先走中心链路 (本机已连接对方); 否则走外围链路 (对方连接了本机)。
    if (mgr.connectedDevice != null) {
      sent = await mgr.sendTextAsCentral(text);
    } else if (mgr.hasSubscribers) {
      sent = await mgr.sendTextAsPeripheral(text);
    } else {
      _addLog("无可用连接, 请先连接或等待对方连接", system: true);
      return;
    }

    if (sent) {
      _addLog("[发出] $text");
      _msgController.clear();
    } else {
      _addLog("发送失败", system: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mgr = BlueToothMgr.instance;
    final bool canSend = mgr.connectedDevice != null || mgr.hasSubscribers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('蓝牙互寻 (双角色)'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text("MTU:$_mtu",
                  style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeripheralPanel(),
          _buildConnectionStatus(),
          const Divider(height: 1),
          _buildControlPanel(),
          SizedBox(
            height: 190,
            child: _buildScanResults(),
          ),
          const Divider(height: 1),
          Expanded(child: _buildLogView()),
          _buildMessageInputBar(canSend),
        ],
      ),
    );
  }

  /// 统一的连接状态显示: 中心角色 + 外围角色。两端都能看到一致的连接/断开。
  Widget _buildConnectionStatus() {
    final mgr = BlueToothMgr.instance;
    final centralId = mgr.centralConnectedId;
    final peripheralIds = mgr.peripheralConnectedIds;
    final bool linked = mgr.isLinked;

    final List<String> lines = [];
    if (centralId != null) {
      lines.add("作为中心 → 已连接 $centralId");
    }
    for (final id in peripheralIds) {
      lines.add("作为外围 ← 已连接 $id");
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: linked ? Colors.green.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: linked ? Colors.green : Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(linked ? Icons.link : Icons.link_off,
              size: 18,
              color: linked ? Colors.green.shade700 : Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              linked ? lines.join('\n') : "未连接",
              style: TextStyle(
                  fontSize: 13,
                  color:
                      linked ? Colors.green.shade900 : Colors.grey.shade700),
            ),
          ),
          if (linked)
            TextButton(
              onPressed: _disconnect,
              style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 8)),
              child: const Text("断开"),
            ),
        ],
      ),
    );
  }

  /// 任意一端发起断开: 中心角色断开对端; 外围角色通知所有中心断开。
  void _disconnect() async {
    final mgr = BlueToothMgr.instance;
    final dev = mgr.connectedDevice;
    if (dev != null) {
      mgr.disconnectDevice(dev);
    }
    if (mgr.peripheralConnectedIds.isNotEmpty) {
      await mgr.disconnectAsPeripheral();
    }
    if (mounted) setState(() {});
  }

  Widget _buildPeripheralPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("本机蓝牙名称",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(_localName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _toggleAdvertising,
              style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isAdvertising ? Colors.red : Colors.green),
              child: Text(_isAdvertising ? '停止广播' : '开启广播'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _toggleScan,
              child: Text(_isScanning ? '停止扫描' : '开始扫描周围设备'),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("显示全部", style: TextStyle(fontSize: 11)),
              Switch(
                value: _showAll,
                onChanged: (v) {
                  setState(() => _showAll = v);
                  if (_isScanning) {
                    // 重新以新过滤方式扫描
                    BlueToothMgr.instance.stopScan();
                    setState(() => _isScanning = false);
                    _toggleScan();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanResults() {
    if (_scanResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            _showAll
                ? "未发现任何BLE设备\n(确认已开始扫描、蓝牙已开)"
                : "未发现本应用设备\n请确认对方已成功开启广播;\n可打开右侧「显示全部」查看周围所有设备来排查",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final result = _scanResults[index];
        final dev = result.device;
        final isConnecting = _connectingDeviceId == dev.remoteId.str;
        final bool matched =
            BlueToothMgr.instance.matchesService(result);
        final name = dev.platformName.isNotEmpty
            ? dev.platformName
            : (result.advertisementData.advName.isNotEmpty
                ? result.advertisementData.advName
                : dev.remoteId.str); // 广播包放不下名称时, 用 MAC 代替"未知设备"
        return ListTile(
          dense: true,
          leading: Icon(
              dev.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              color: dev.isConnected
                  ? Colors.green
                  : (matched ? Colors.blue : Colors.grey)),
          title: Row(
            children: [
              Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
              if (matched)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Text("[本应用]",
                      style: TextStyle(fontSize: 11, color: Colors.blue)),
                ),
            ],
          ),
          subtitle: Text(isConnecting
              ? "正在连接..."
              : (dev.isConnected ? "已连接" : "点击尝试连接")),
          trailing: isConnecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text("${result.rssi} dBm"),
          onTap: isConnecting ? null : () => _connectToDevice(dev),
        );
      },
    );
  }

  Widget _buildLogView() {
    if (_logs.isEmpty) {
      return const Center(child: Text("暂无消息 / 日志"));
    }
    return ListView.builder(
      reverse: true,
      itemCount: _logs.length,
      itemBuilder: (context, index) {
        final item = _logs[index];
        final color = item.system
            ? Colors.grey
            : (item.incoming ? Colors.green.shade800 : Colors.blue.shade800);
        return Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          child: Text(item.text,
              style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontStyle:
                      item.system ? FontStyle.italic : FontStyle.normal)),
        );
      },
    );
  }

  Widget _buildMessageInputBar(bool canSend) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))
          ]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                  hintText:
                      canSend ? "输入要发送的信息..." : "尚无连接 (连接或等待对方连接)",
                  isDense: true,
                  border: const OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
              onPressed: canSend ? _sendMsg : null,
              child: const Text("发送")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }
}
