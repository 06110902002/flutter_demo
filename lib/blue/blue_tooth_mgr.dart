import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ble_peripheral/ble_peripheral.dart' as bp;
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ble_protocol.dart';

/// 扫描回调
typedef OnScanListener = void Function(List<ScanResult> results);

/// 连接状态回调 (中心角色: 本机主动连接对方时)
typedef OnConnectListener =
    void Function(BluetoothConnectionState status, BluetoothDevice device);

/// 收到完整消息回调。[from] 为来源标识 (中心角色为对方 remoteId, 外围角色为发起写入的 deviceId)。
typedef OnMessageListener =
    void Function(String from, BleMessage message, bool asPeripheral);

/// MTU 变更回调
typedef OnMtuListener = void Function(String deviceId, int mtu);

/// 连接关系发生变化 (中心或外围任一角色) 时的通知回调。
typedef OnConnectionChanged = void Function();

/// 日志回调
typedef OnLog = void Function(String log);

/// ============================================================================
/// BLE 管理器 (双角色)
///
/// 每台手机同时扮演两个角色, 从而实现"互相搜索 + 互相连接 + 双向收发":
///   - 外围/服务端 (Peripheral, 基于 ble_peripheral):
///       建立 GATT Server, 暴露一个可写(write)+可通知(notify)的特征值, 并广播服务 UUID。
///   - 中心/客户端 (Central, 基于 flutter_blue_plus):
///       扫描含目标服务 UUID 的设备, 连接, 协商 MTU, 发现服务, 订阅 notify, 收发数据。
///
/// 数据链路:
///   中心 -> 外围: 中心 write 特征值   => 外围 onWriteRequest 收到
///   外围 -> 中心: 外围 updateCharacteristic(notify) => 中心 onValueReceived 收到
///
/// 所有业务数据都经过 [BleProtocolCodec] 分片/组帧, 经 [BleReassembler] 重组。
/// ============================================================================
class BlueToothMgr {
  static BlueToothMgr? _instance;

  BlueToothMgr._internal();

  static BlueToothMgr get instance {
    _instance ??= BlueToothMgr._internal();
    return _instance!;
  }

  // 两台设备必须使用相同 UUID 才能互相识别。
  final String serviceUuid = "bf27730d-860a-4e09-889c-2d8b6a9e0fe7";
  final String characteristicUuid = "bf27730e-860a-4e09-889c-2d8b6a9e0fe8";

  final int scanTimeOut = 15;
  final int desiredMtu = 512;

  // ---- 中心角色状态 ----
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _rwCharacteristic; // 兼具 write 与 notify
  int _centralMtu = 23; // 与对方(作为外围时)协商得到的 MTU
  final BleReassembler _centralReassembler = BleReassembler();
  StreamSubscription? _scanSub;
  StreamSubscription? _connSub;
  StreamSubscription? _notifySub;
  StreamSubscription? _mtuSub;

  // ---- 外围角色状态 ----
  bool _peripheralReady = false;
  bool _isAdvertising = false;
  String? _advError; // 最近一次广播错误 (来自状态回调)
  final BleReassembler _peripheralReassembler = BleReassembler();
  final Set<String> _subscribers = <String>{}; // 已订阅 notify 的中心设备
  final Set<String> _connectedCentrals = <String>{}; // 已连接到本机(外围)的中心
  final Map<String, int> _peripheralMtu = {}; // 各中心设备协商的 MTU

  // 原生通道: 读取本机蓝牙名称等。
  static const MethodChannel _nativeChannel =
      MethodChannel('com.example.flutter_ios_communication/native');

  // ---- 对外回调 ----
  OnMessageListener? onMessage;
  OnMtuListener? onMtu;
  OnConnectionChanged? onConnectionChanged;
  OnConnectionChanged? onScanStopped; // 扫描结束(超时/主动停止)时通知 UI
  OnLog? onLog;

  bool isScanning() => _isScanning;
  bool isAdvertising() => _isAdvertising;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  int get centralMtu => _centralMtu;

  /// 本机作为中心时连接的对端 id (无则 null)。
  String? get centralConnectedId => _connectedDevice?.remoteId.str;

  /// 本机作为外围时已连接的中心 id 列表。
  List<String> get peripheralConnectedIds =>
      _connectedCentrals.toList(growable: false);

  /// 只要任一角色存在连接即为 true。
  bool get isLinked =>
      _connectedDevice != null || _connectedCentrals.isNotEmpty;

  void _notifyConn() => onConnectionChanged?.call();

  void _log(String msg) {
    // ignore: avoid_print
    print("[BLE] $msg");
    onLog?.call(msg);
  }

  /// 读取本机蓝牙名称 (优先原生 BluetoothAdapter.getName)。失败时回退。
  Future<String> getLocalBluetoothName() async {
    try {
      final name = await _nativeChannel.invokeMethod<String>('getBluetoothName');
      if (name != null && name.trim().isNotEmpty) return name.trim();
    } catch (e) {
      _log("获取本机蓝牙名称失败: $e");
    }
    return "本机蓝牙";
  }

  // ==========================================================================
  // 权限与初始化
  // ==========================================================================

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    return statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.bluetoothConnect] == PermissionStatus.granted &&
        statuses[Permission.bluetoothAdvertise] == PermissionStatus.granted;
  }

  Future<bool> initBlueTooth() async {
    if (await FlutterBluePlus.isSupported == false) {
      _log("此设备不支持蓝牙");
      return false;
    }
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {}
    }
    try {
      await FlutterBluePlus.adapterState
          .firstWhere((s) => s == BluetoothAdapterState.on)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      _log("开启蓝牙超时");
      return false;
    }
    return true;
  }

  // ==========================================================================
  // 中心角色: 扫描
  // ==========================================================================

  /// 判断某扫描结果是否携带本应用的服务 UUID。
  bool matchesService(ScanResult r) =>
      r.advertisementData.serviceUuids.contains(Guid(serviceUuid));

  /// 开始扫描。
  /// [onlyMatching] 为 true 时只回调携带目标服务 UUID 的设备(软件过滤);
  ///   为 false 时回调全部设备(调试用, 可确认周围到底有没有广播)。
  /// 注意: 不使用 withServices 硬件过滤 —— 部分 Android 机型对 128 位 UUID
  ///       的硬件扫描过滤不可靠, 会导致明明在广播却扫不到。软件过滤更稳。
  void startScan({OnScanListener? onScan, bool onlyMatching = true}) async {
    if (_isScanning) return;
    _isScanning = true;

    await _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      if (onlyMatching) {
        onScan?.call(results.where(matchesService).toList());
      } else {
        onScan?.call(results);
      }
    });
    FlutterBluePlus.cancelWhenScanComplete(_scanSub!);

    try {
      await FlutterBluePlus.startScan(
        timeout: Duration(seconds: scanTimeOut),
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      _log("扫描启动失败: $e");
      _isScanning = false;
    }

    Future.delayed(Duration(seconds: scanTimeOut), () {
      if (_isScanning) {
        _isScanning = false;
        onScanStopped?.call();
      }
    });
  }

  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    _isScanning = false;
    onScanStopped?.call();
  }

  // ==========================================================================
  // 中心角色: 连接 + MTU协商 + 服务发现 + 订阅
  // ==========================================================================

  void connectToDevice(
    BluetoothDevice device, {
    OnConnectListener? connectListener,
  }) async {
    if (_isScanning) {
      await stopScan();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // 始终注册连接状态监听 (connectionState 会立即回放当前状态),
    // 保证已连接场景也能触发服务发现, 且断开时正确清理状态。
    await _connSub?.cancel();
    _connSub = device.connectionState.listen((state) async {
      connectListener?.call(state, device);
      if (state == BluetoothConnectionState.connected) {
        await _onCentralConnected(device);
      } else if (state == BluetoothConnectionState.disconnected) {
        if (_connectedDevice?.remoteId == device.remoteId) {
          _centralReassembler.clearDevice(device.remoteId.str);
          _connectedDevice = null;
          _rwCharacteristic = null;
          _centralMtu = 23;
          _discovering = false;
          _notifyConn();
        }
      }
    });

    // 已连接: 监听器会回放 connected 状态并触发发现流程, 无需再次 connect。
    if (device.isConnected) return;

    try {
      await device.connect(
        license: License.free,
        autoConnect: false,
        timeout: const Duration(seconds: 15),
      );
    } catch (e) {
      _log("连接异常: $e");
      connectListener?.call(BluetoothConnectionState.disconnected, device);
    }
  }

  bool _discovering = false;

  Future<void> _onCentralConnected(BluetoothDevice device) async {
    // 防止 connectionState 多次回放 connected 导致重复发现。
    if (_connectedDevice?.remoteId == device.remoteId &&
        _rwCharacteristic != null) {
      return;
    }
    if (_discovering) return;
    _discovering = true;
    _connectedDevice = device;
    _log("底层连接成功: ${device.remoteId}");
    _notifyConn();

    // 1) MTU 协商。
    // 注意: flutter_blue_plus 的 connect() 默认会自动请求一次 MTU(512),
    //      而 Android 每次连接只允许一次 MTU 交换。这里的 requestMtu 若因
    //      "已协商" 而抛异常也无妨 —— 随后统一以 device.mtuNow 为准读取实际值。
    try {
      await device.requestMtu(desiredMtu);
    } catch (e) {
      _log("requestMtu 异常(可能已自动协商): $e");
    }
    _centralMtu = device.mtuNow;
    _log("当前 MTU = $_centralMtu");
    onMtu?.call(device.remoteId.str, _centralMtu);

    // 监听后续 MTU 变化。
    await _mtuSub?.cancel();
    _mtuSub = device.mtu.listen((m) {
      _centralMtu = m;
      onMtu?.call(device.remoteId.str, m);
    });
    device.cancelWhenDisconnected(_mtuSub!);

    // 2) 服务发现, 定位可写+可通知特征值。
    try {
      // subscribeToServicesChanged: false —— 关键:
      // FBP 默认会在发现服务后自动订阅标准 GATT 服务的 Service Changed(0x2A05),
      // 而对端(ble_peripheral)的该特征通常没有可写的 CCCD(0x2902),
      // 会抛 GATT_ATTR_NOT_FOUND 并中断整个流程, 导致走不到我们自己的特征。
      final services =
          await device.discoverServices(subscribeToServicesChanged: false);
      for (final service in services) {
        if (service.uuid != Guid(serviceUuid)) continue;
        for (final c in service.characteristics) {
          if (c.uuid == Guid(characteristicUuid)) {
            _rwCharacteristic = c;
            _log("已找到通信特征值");

            // 3) 订阅 notify, 接收外围 -> 中心 的数据。
            if (c.properties.notify || c.properties.indicate) {
              try {
                await _notifySub?.cancel();
                _notifySub = c.onValueReceived.listen((value) {
                  _handleCentralIncoming(
                    device.remoteId.str,
                    Uint8List.fromList(value),
                  );
                });
                device.cancelWhenDisconnected(_notifySub!);
                await c.setNotifyValue(true);
                _log("已订阅 notify");
                // 应用层握手: 告诉对端(外围)本机已就绪, 便于两端状态同步。
                try {
                  await sendAsCentral(ProtocolType.control,
                      Uint8List.fromList([ControlCmd.hello]));
                } catch (_) {}
              } catch (e) {
                // 订阅失败不影响写入(中心->外围)。
                _log("订阅 notify 失败(仍可发送): $e");
              }
            }
          }
        }
      }
      if (_rwCharacteristic == null) {
        _log("未找到目标特征值, 请确认对方已开启广播(GATT服务)");
      }
    } catch (e) {
      _log("服务发现异常: $e");
    } finally {
      _discovering = false;
    }
  }

  void _handleCentralIncoming(String from, Uint8List raw) {
    final msg = _centralReassembler.addRaw(from, raw);
    if (msg == null) return;
    if (msg.protocolType == ProtocolType.control) {
      _handleControl(from, msg.data, asPeripheral: false);
      return;
    }
    onMessage?.call(from, msg, false);
  }

  /// 处理应用层连接控制 (HELLO/BYE)。
  void _handleControl(String from, Uint8List data, {required bool asPeripheral}) {
    if (data.isEmpty) return;
    final cmd = data[0];
    if (cmd == ControlCmd.hello) {
      _log("收到 HELLO ($from)");
      if (asPeripheral) _connectedCentrals.add(from);
      _notifyConn();
    } else if (cmd == ControlCmd.bye) {
      _log("收到 BYE ($from)");
      if (asPeripheral) {
        // 中心通知断开: 立即清理外围侧显示。
        _connectedCentrals.remove(from);
        _subscribers.remove(from);
        _peripheralReassembler.clearDevice(from);
        _notifyConn();
      } else {
        // 外围通知断开: 中心主动断开 BLE 链路(不再回发 BYE, 避免往返)。
        final d = _connectedDevice;
        if (d != null) {
          disconnectDevice(d, sendBye: false);
        }
      }
    }
  }

  /// 中心 -> 外围 发送 (自动分片, 顺序写入以保证分片有序)。
  Future<bool> sendAsCentral(int protocolType, Uint8List data) async {
    final c = _rwCharacteristic;
    if (c == null) {
      _log("发送失败: 尚未发现可写特征值");
      return false;
    }
    final frames = BleProtocolCodec.encode(protocolType, data, _centralMtu);
    final bool withoutResp =
        !c.properties.write && c.properties.writeWithoutResponse;
    try {
      for (final f in frames) {
        await c.write(f, withoutResponse: withoutResp);
      }
      _log("已发送 ${data.length}B, 分 ${frames.length} 帧 (MTU=$_centralMtu)");
      return true;
    } catch (e) {
      _log("发送异常: $e");
      return false;
    }
  }

  Future<bool> sendTextAsCentral(String text) =>
      sendAsCentral(ProtocolType.text, Uint8List.fromList(utf8.encode(text)));

  void disconnectDevice(BluetoothDevice device, {bool sendBye = true}) async {
    // 先通过数据通道通知对端断开, 使对端立即更新状态(不必等 BLE 链路超时)。
    if (sendBye && _rwCharacteristic != null) {
      try {
        await sendAsCentral(
            ProtocolType.control, Uint8List.fromList([ControlCmd.bye]));
        await Future.delayed(const Duration(milliseconds: 150));
      } catch (_) {}
    }
    try {
      await device.disconnect();
    } catch (_) {}
    _centralReassembler.clearDevice(device.remoteId.str);
    _connectedDevice = null;
    _rwCharacteristic = null;
    _centralMtu = 23;
    _notifyConn();
  }

  // ==========================================================================
  // 外围角色: GATT Server + 广播
  // ==========================================================================

  /// 初始化 GATT Server 并注册回调 (只需执行一次)。
  Future<bool> initPeripheral() async {
    if (_peripheralReady) return true;
    try {
      await bp.BlePeripheral.initialize();

      // 收到中心写入 (中心 -> 外围)。
      bp.BlePeripheral.setWriteRequestCallback(
        (String deviceId, String characteristicId, int offset,
            Uint8List? value) {
          if (value != null &&
              characteristicId.toLowerCase() ==
                  characteristicUuid.toLowerCase()) {
            final msg = _peripheralReassembler.addRaw(deviceId, value);
            if (msg != null) {
              if (msg.protocolType == ProtocolType.control) {
                _handleControl(deviceId, msg.data, asPeripheral: true);
              } else {
                onMessage?.call(deviceId, msg, true);
              }
            }
          }
          // 返回 null 表示写入成功。
          return null;
        },
      );

      // 订阅状态变化: 记录哪些中心订阅了 notify。
      bp.BlePeripheral.setCharacteristicSubscriptionChangeCallback(
        (String deviceId, String characteristicId, bool isSubscribed,
            String? name) {
          if (isSubscribed) {
            _subscribers.add(deviceId);
          } else {
            _subscribers.remove(deviceId);
          }
          _log("订阅变化: $deviceId -> $isSubscribed");
        },
      );

      // MTU 变化 (中心与本机作为外围时协商的 MTU)。
      bp.BlePeripheral.setMtuChangeCallback((String deviceId, int mtu) {
        _peripheralMtu[deviceId] = mtu;
        _log("外围侧 MTU: $deviceId = $mtu");
        onMtu?.call(deviceId, mtu);
      });

      // 连接状态。
      bp.BlePeripheral.setConnectionStateChangeCallback(
        (String deviceId, bool connected) {
          if (connected) {
            _connectedCentrals.add(deviceId);
          } else {
            _connectedCentrals.remove(deviceId);
            _subscribers.remove(deviceId);
            _peripheralMtu.remove(deviceId);
            _peripheralReassembler.clearDevice(deviceId);
          }
          _log("外围侧连接: $deviceId -> $connected");
          _notifyConn();
        },
      );

      // 广播状态 (关键): Android 上广播失败(如 DATA_TOO_LARGE)通过此回调上报,
      // 而不是抛异常。据此判断广播是否真正生效。
      bp.BlePeripheral.setAdvertisingStatusUpdateCallback(
        (bool advertising, String? error) {
          _isAdvertising = advertising;
          _advError = error;
          _log("广播状态: advertising=$advertising"
              "${(error != null && error.isNotEmpty) ? ', error=$error' : ''}");
        },
      );

      // 注册服务 + 特征值 (write + writeWithoutResponse + notify + read)。
      await bp.BlePeripheral.addService(
        bp.BleService(
          uuid: serviceUuid,
          primary: true,
          characteristics: [
            bp.BleCharacteristic(
              uuid: characteristicUuid,
              properties: [
                bp.CharacteristicProperties.read.index,
                bp.CharacteristicProperties.write.index,
                bp.CharacteristicProperties.writeWithoutResponse.index,
                bp.CharacteristicProperties.notify.index,
              ],
              permissions: [
                bp.AttributePermissions.readable.index,
                bp.AttributePermissions.writeable.index,
              ],
              value: null,
            ),
          ],
        ),
      );

      _peripheralReady = true;
      _log("GATT Server 就绪");
      return true;
    } catch (e) {
      _log("初始化外围失败: $e");
      return false;
    }
  }

  /// 开启广播 (会先确保 GATT Server 已建立)。
  /// Android 广播包只有 31 字节: 128位服务UUID(18B)+Flags(3B) 已占 21B,
  /// 再加设备名极易超限导致广播失败。因此优先保证服务UUID被广播,
  /// 若带名称启动后未真正生效, 则去掉名称仅广播服务UUID重试。
  Future<void> startAdvertising(String name) async {
    final ok = await initPeripheral();
    if (!ok) return;

    _advError = null;
    _isAdvertising = false;

    // 名称尽量短, 降低超限概率。
    final String shortName = name.length > 8 ? name.substring(0, 8) : name;

    // 第一次: 带名称。
    try {
      await bp.BlePeripheral.stopAdvertising();
    } catch (_) {}
    try {
      await bp.BlePeripheral.startAdvertising(
        services: [serviceUuid],
        localName: shortName,
      );
      _log("请求广播(含名称): $shortName");
    } catch (e) {
      _log("广播启动异常: $e");
    }

    // 等待状态回调确认是否真正生效。
    await Future.delayed(const Duration(milliseconds: 900));

    // 第二次(回退): 未生效则去掉名称, 仅广播服务UUID (保证 UUID 一定在广播包内)。
    if (!_isAdvertising) {
      _log("广播未生效${_advError != null ? '($_advError)' : ''}, 去掉名称重试...");
      try {
        await bp.BlePeripheral.stopAdvertising();
      } catch (_) {}
      try {
        await bp.BlePeripheral.startAdvertising(services: [serviceUuid]);
        _log("请求广播(仅服务UUID)");
      } catch (e) {
        _log("回退广播异常: $e");
      }
      await Future.delayed(const Duration(milliseconds: 900));
    }

    if (_isAdvertising) {
      _log("广播已生效");
    } else {
      _log("广播仍未生效, 请检查蓝牙/权限或换机型测试");
    }
  }

  Future<void> stopAdvertising() async {
    try {
      await bp.BlePeripheral.stopAdvertising();
    } catch (_) {}
    _isAdvertising = false;
    _log("广播已停止");
  }

  /// 外围 -> 中心 发送 (通过 notify, 自动分片)。
  /// [deviceId] 为空时向所有已订阅的中心发送。
  Future<bool> sendAsPeripheral(int protocolType, Uint8List data,
      {String? deviceId}) async {
    if (_subscribers.isEmpty) {
      _log("发送失败: 暂无中心订阅 notify");
      return false;
    }
    final targets = deviceId != null ? [deviceId] : _subscribers.toList();
    try {
      for (final dev in targets) {
        final mtu = _peripheralMtu[dev] ?? 23;
        final frames = BleProtocolCodec.encode(protocolType, data, mtu);
        for (final f in frames) {
          await bp.BlePeripheral.updateCharacteristic(
            characteristicId: characteristicUuid,
            value: f,
            deviceId: dev,
          );
          // notify 无流控, 分片间稍作间隔避免丢帧。
          await Future.delayed(const Duration(milliseconds: 15));
        }
        _log("外围已发送 ${data.length}B -> $dev (MTU=$mtu)");
      }
      return true;
    } catch (e) {
      _log("外围发送异常: $e");
      return false;
    }
  }

  Future<bool> sendTextAsPeripheral(String text, {String? deviceId}) =>
      sendAsPeripheral(ProtocolType.text,
          Uint8List.fromList(utf8.encode(text)),
          deviceId: deviceId);

  bool get hasSubscribers => _subscribers.isNotEmpty;

  /// 外围侧主动断开: 通过 notify 通知所有中心 BYE, 中心收到后会断开 BLE 链路。
  /// 同时立即清理本机(外围)显示状态。
  Future<void> disconnectAsPeripheral() async {
    try {
      await sendAsPeripheral(
          ProtocolType.control, Uint8List.fromList([ControlCmd.bye]));
    } catch (_) {}
    _connectedCentrals.clear();
    _notifyConn();
  }

  void dispose() {
    _scanSub?.cancel();
    _connSub?.cancel();
    _notifySub?.cancel();
    _mtuSub?.cancel();
  }
}
