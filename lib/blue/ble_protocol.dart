import 'dart:typed_data';

/// ============================================================================
/// BLE 自定义传输协议 (帧格式 / 分片 / 重组)
///
/// 帧结构 (每个 BLE 数据包 = 1 帧):
///   字节        含义
///   [0..1]     协议类型 (2 字节, 大端序)。用于区分业务类型, 也作为重组分组的 key。
///   [2]        本帧负载长度 (1 字节, 0~255)。即本帧 payload 的字节数。
///   [3]        分片标志: 0x00=不分片(单帧完整消息)  0x01=分片(多帧消息中的一片)
///   [4]        分片位置标志:
///                0x10 = 第一个分片 (首片)
///                0x00 = 中间分片
///                0x01 = 最后一个分片 (末片)
///                0x11 = 完整帧 (未分片时使用, 高低半字节均置位, 表示既是首也是尾)
///   [5..]      负载数据 (payload)
///
/// 说明:
///  - 头部固定 5 字节, 包含在每个 BLE 数据包内。
///  - 单个 BLE 包最大可写字节数 = MTU - 3 (ATT 头占 3 字节)。
///  - 因此每帧负载最大值 = min(MTU - 3 - 5, 255)。超过则自动分片。
///  - 位置标志采用半字节语义: 高半字节=是否首片, 低半字节=是否末片,
///    正好解释了 0x10 / 0x00 / 0x01 / 0x11 这几个取值。
/// ============================================================================

/// 头部长度 (字节)
const int kHeaderLength = 5;

/// ATT 协议开销 (字节)。单包最大负载 = MTU - kAttOverhead
const int kAttOverhead = 3;

/// 单帧负载理论上限 (受 [2] 长度字段 1 字节限制)
const int kMaxFragmentPayload = 255;

/// 分片标志
class FragFlag {
  static const int none = 0x00; // 不分片
  static const int frag = 0x01; // 分片
}

/// 分片位置标志
class FragPos {
  static const int first = 0x10; // 首片
  static const int middle = 0x00; // 中间片
  static const int last = 0x01; // 末片
  static const int complete = 0x11; // 未分片的完整帧
}

/// 常用协议类型 (可自行扩展)
class ProtocolType {
  static const int text = 0x0001; // 文本消息
  static const int bytes = 0x0002; // 原始字节
  static const int heartbeat = 0x0003; // 心跳
  static const int control = 0x00FF; // 连接控制 (HELLO/BYE), 用于两端状态同步
}

/// 连接控制子命令 (control 协议的负载首字节)
class ControlCmd {
  static const int hello = 0x01; // 应用层已就绪/上线
  static const int bye = 0x02; // 主动断开通知
}

/// 解析后的单帧
class BleFrame {
  final int protocolType; // 协议类型 (0~65535)
  final int payloadLength; // 本帧负载长度
  final int fragFlag; // 分片标志
  final int position; // 分片位置标志
  final Uint8List payload; // 负载

  BleFrame({
    required this.protocolType,
    required this.payloadLength,
    required this.fragFlag,
    required this.position,
    required this.payload,
  });

  bool get isFragmented => fragFlag == FragFlag.frag;
  bool get isFirst => position == FragPos.first || position == FragPos.complete;
  bool get isLast => position == FragPos.last || position == FragPos.complete;

  @override
  String toString() =>
      'BleFrame(type=0x${protocolType.toRadixString(16).padLeft(4, '0')}, '
      'len=$payloadLength, frag=$fragFlag, pos=0x${position.toRadixString(16).padLeft(2, '0')}, '
      'payload=${payload.length}B)';
}

/// 协议编解码器
class BleProtocolCodec {
  /// 根据当前 MTU 计算单帧最大负载字节数。
  static int maxPayloadForMtu(int mtu) {
    // 单包最大字节 = mtu - ATT开销; 再减去头部, 且不超过 255 (长度字段限制)。
    final usable = mtu - kAttOverhead - kHeaderLength;
    final capped = usable > kMaxFragmentPayload ? kMaxFragmentPayload : usable;
    // 兜底: 即便 MTU 很小也至少允许 1 字节负载, 防止死循环。
    return capped < 1 ? 1 : capped;
  }

  /// 将一条完整消息编码为一个或多个可直接写入 BLE 的帧。
  ///
  /// [protocolType] 业务协议类型 (2 字节)。
  /// [data]         完整负载。
  /// [mtu]          当前协商得到的 MTU。
  static List<Uint8List> encode(int protocolType, Uint8List data, int mtu) {
    final int maxPayload = maxPayloadForMtu(mtu);
    final List<Uint8List> frames = [];

    // 不需要分片: 单帧完整消息。
    if (data.length <= maxPayload) {
      frames.add(_buildFrame(
        protocolType: protocolType,
        fragFlag: FragFlag.none,
        position: FragPos.complete,
        payload: data,
      ));
      return frames;
    }

    // 需要分片。
    int offset = 0;
    while (offset < data.length) {
      final int end = (offset + maxPayload) > data.length
          ? data.length
          : (offset + maxPayload);
      final Uint8List chunk = Uint8List.sublistView(data, offset, end);

      int position;
      if (offset == 0) {
        position = FragPos.first; // 首片
      } else if (end >= data.length) {
        position = FragPos.last; // 末片
      } else {
        position = FragPos.middle; // 中间片
      }

      frames.add(_buildFrame(
        protocolType: protocolType,
        fragFlag: FragFlag.frag,
        position: position,
        payload: chunk,
      ));

      offset = end;
    }
    return frames;
  }

  /// 组装单帧字节 (头部 + 负载)。
  static Uint8List _buildFrame({
    required int protocolType,
    required int fragFlag,
    required int position,
    required Uint8List payload,
  }) {
    assert(payload.length <= kMaxFragmentPayload,
        '单帧负载不能超过 $kMaxFragmentPayload 字节');
    final Uint8List frame = Uint8List(kHeaderLength + payload.length);
    frame[0] = (protocolType >> 8) & 0xFF; // 协议类型高字节
    frame[1] = protocolType & 0xFF; // 协议类型低字节
    frame[2] = payload.length & 0xFF; // 本帧负载长度
    frame[3] = fragFlag & 0xFF; // 分片标志
    frame[4] = position & 0xFF; // 分片位置标志
    frame.setRange(kHeaderLength, frame.length, payload);
    return frame;
  }

  /// 解析单帧。数据不完整或非法时返回 null。
  static BleFrame? decode(Uint8List raw) {
    if (raw.length < kHeaderLength) return null;
    final int protocolType = (raw[0] << 8) | raw[1];
    final int payloadLength = raw[2];
    final int fragFlag = raw[3];
    final int position = raw[4];

    // 实际负载 = 除去头部的剩余部分, 但以长度字段为准 (防止填充干扰)。
    final int available = raw.length - kHeaderLength;
    final int useLen = payloadLength <= available ? payloadLength : available;
    final Uint8List payload =
        Uint8List.sublistView(raw, kHeaderLength, kHeaderLength + useLen);

    return BleFrame(
      protocolType: protocolType,
      payloadLength: payloadLength,
      fragFlag: fragFlag,
      position: position,
      payload: payload,
    );
  }
}

/// 完整消息 (重组后)
class BleMessage {
  final int protocolType;
  final Uint8List data;

  BleMessage(this.protocolType, this.data);
}

/// 分片重组器。
///
/// 按 (发送方 deviceId + 协议类型) 分组缓存分片, 收到末片后拼接为完整消息。
/// 收到不分片的完整帧时立即返回。
class BleReassembler {
  // key: "$deviceId#$protocolType"  ->  已收到的分片负载列表
  final Map<String, List<int>> _buffers = {};

  String _key(String deviceId, int protocolType) => '$deviceId#$protocolType';

  /// 喂入一帧原始字节, 若组成完整消息则返回, 否则返回 null。
  BleMessage? addRaw(String deviceId, Uint8List raw) {
    final frame = BleProtocolCodec.decode(raw);
    if (frame == null) return null;
    return addFrame(deviceId, frame);
  }

  /// 喂入一个已解析的帧。
  BleMessage? addFrame(String deviceId, BleFrame frame) {
    // 不分片: 直接就是完整消息。
    if (!frame.isFragmented) {
      return BleMessage(frame.protocolType, Uint8List.fromList(frame.payload));
    }

    final key = _key(deviceId, frame.protocolType);

    // 首片: 新建缓冲 (若已有残留则丢弃重来)。
    if (frame.position == FragPos.first) {
      _buffers[key] = <int>[]..addAll(frame.payload);
      return null;
    }

    // 中间/末片: 追加。若无首片缓冲 (丢包), 忽略以避免脏数据。
    final buf = _buffers[key];
    if (buf == null) {
      return null;
    }
    buf.addAll(frame.payload);

    // 末片: 组装完整消息并清理缓冲。
    if (frame.position == FragPos.last) {
      _buffers.remove(key);
      return BleMessage(frame.protocolType, Uint8List.fromList(buf));
    }

    // 中间片: 继续等待。
    return null;
  }

  /// 清空某设备的所有缓存 (如断开连接时)。
  void clearDevice(String deviceId) {
    _buffers.removeWhere((k, _) => k.startsWith('$deviceId#'));
  }

  void clearAll() => _buffers.clear();
}
