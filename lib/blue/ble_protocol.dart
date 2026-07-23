import 'dart:typed_data';

/// ============================================================================
/// BLE 自定义传输协议 (位级紧凑打包, 提高 MTU 利用率)
///
/// 按位 (MSB 优先) 顺序排列, 负载紧跟头部末位继续打包 (不做字节对齐):
///
///   分片时头部 (13 bit):
///     协议类型(2bit) + 数据长度(8bit) + 分片标志(1bit=1) + 分片位置(2bit) + 负载(N*8bit)
///   不分片头部 (11 bit):
///     协议类型(2bit) + 数据长度(8bit) + 分片标志(1bit=0) + 负载(N*8bit)
///
/// 字节视角 (与需求描述一致):
///   字节1: [协议类型:2][数据长度高6位:6]
///   字节2: [数据长度低2位:2][分片标志:1] 之后:
///            - 分片(标志=1): [分片位置:2] 再从第6位开始是负载
///            - 不分片(标志=0): 从第4位开始就是负载
///
/// 说明:
///  - 协议类型只有 2bit => 仅支持 4 种协议。
///  - 数据长度 8bit => 每帧负载最多 255 字节。
///  - 分片位置: 0b10=首片, 0b00=中间片, 0b01=末片。
///  - 负载按字节 (8bit) 依次打包, 末尾不足 8bit 用 0 补齐。
/// ============================================================================

/// ATT 协议开销 (字节)。单包最大字节 = MTU - kAttOverhead
const int kAttOverhead = 3;

/// 每帧负载理论上限 (受 8bit 长度字段限制)
const int kMaxFragmentPayload = 255;

/// 分片标志
class FragFlag {
  static const int none = 0x00; // 不分片
  static const int frag = 0x01; // 分片
}

/// 分片位置标志 (2bit 值)
class FragPos {
  static const int first = 0x02; // 0b10 首片
  static const int middle = 0x00; // 0b00 中间片
  static const int last = 0x01; // 0b01 末片
  static const int none = -1; // 不分片时无此字段 (哨兵值)
}

/// 协议类型 (仅 2bit, 0~3, 共 4 种)
class ProtocolType {
  static const int text = 0x00; // 0b00 文本消息
  static const int bytes = 0x01; // 0b01 原始字节
  static const int control = 0x02; // 0b10 连接控制 (HELLO/BYE)
  static const int heartbeat = 0x03; // 0b11 心跳/保留
}

/// 连接控制子命令 (control 协议负载首字节)
class ControlCmd {
  static const int hello = 0x01; // 应用层已就绪/上线
  static const int bye = 0x02; // 主动断开通知
}

/// ---------------------------------------------------------------------------
/// 位写入器 (MSB 优先)
/// ---------------------------------------------------------------------------
class _BitWriter {
  final List<int> _bytes = [];
  int _cur = 0; // 当前未满字节
  int _nbits = 0; // 当前字节已填位数 (0..7)

  /// 写入 [value] 的低 [bits] 位, 高位在前。
  void writeBits(int value, int bits) {
    for (int i = bits - 1; i >= 0; i--) {
      final bit = (value >> i) & 1;
      _cur = (_cur << 1) | bit;
      _nbits++;
      if (_nbits == 8) {
        _bytes.add(_cur & 0xFF);
        _cur = 0;
        _nbits = 0;
      }
    }
  }

  void writeByte(int b) => writeBits(b & 0xFF, 8);

  Uint8List toBytes() {
    final out = List<int>.from(_bytes);
    if (_nbits > 0) {
      // 末尾不足 8bit, 右侧补 0。
      out.add((_cur << (8 - _nbits)) & 0xFF);
    }
    return Uint8List.fromList(out);
  }
}

/// ---------------------------------------------------------------------------
/// 位读取器 (MSB 优先)
/// ---------------------------------------------------------------------------
class _BitReader {
  final Uint8List _data;
  int _pos = 0; // 已读位数

  _BitReader(this._data);

  int get remainingBits => _data.length * 8 - _pos;

  int readBits(int bits) {
    int v = 0;
    for (int i = 0; i < bits; i++) {
      final byteIndex = _pos >> 3;
      final bitIndex = 7 - (_pos & 7); // MSB 优先
      final bit =
          byteIndex < _data.length ? (_data[byteIndex] >> bitIndex) & 1 : 0;
      v = (v << 1) | bit;
      _pos++;
    }
    return v;
  }
}

/// 解析后的单帧
class BleFrame {
  final int protocolType; // 协议类型 (0~3)
  final int payloadLength; // 本帧负载长度 (字节)
  final int fragFlag; // 分片标志
  final int position; // 分片位置 (FragPos), 不分片为 FragPos.none
  final Uint8List payload; // 负载

  BleFrame({
    required this.protocolType,
    required this.payloadLength,
    required this.fragFlag,
    required this.position,
    required this.payload,
  });

  bool get isFragmented => fragFlag == FragFlag.frag;
  bool get isFirst => position == FragPos.first;
  bool get isLast => position == FragPos.last;

  @override
  String toString() =>
      'BleFrame(type=$protocolType, len=$payloadLength, frag=$fragFlag, '
      'pos=$position, payload=${payload.length}B)';
}

/// 协议编解码器
class BleProtocolCodec {
  /// 根据当前 MTU 计算单帧最大负载字节数。
  /// 单包最大字节 = mtu - ATT开销; 头部约 2 字节(11~13bit), 故负载 <= mtu-3-2 = mtu-5。
  /// 再受 8bit 长度字段限制, 不超过 255。
  static int maxPayloadForMtu(int mtu) {
    final usable = mtu - kAttOverhead - 2;
    final capped = usable > kMaxFragmentPayload ? kMaxFragmentPayload : usable;
    return capped < 1 ? 1 : capped;
  }

  /// 将一条完整消息编码为一个或多个可直接写入 BLE 的帧。
  static List<Uint8List> encode(int protocolType, Uint8List data, int mtu) {
    final int maxPayload = maxPayloadForMtu(mtu);
    final List<Uint8List> frames = [];

    // 不需要分片: 单帧完整消息。
    if (data.length <= maxPayload) {
      frames.add(_buildFrame(
        protocolType: protocolType,
        fragFlag: FragFlag.none,
        position: FragPos.none,
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
        position = FragPos.first;
      } else if (end >= data.length) {
        position = FragPos.last;
      } else {
        position = FragPos.middle;
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

  /// 按位打包单帧 (头部 + 负载), 末尾补 0 对齐到字节。
  static Uint8List _buildFrame({
    required int protocolType,
    required int fragFlag,
    required int position,
    required Uint8List payload,
  }) {
    assert(payload.length <= kMaxFragmentPayload,
        '单帧负载不能超过 $kMaxFragmentPayload 字节');
    final w = _BitWriter();
    w.writeBits(protocolType & 0x03, 2); // 协议类型 2bit
    w.writeBits(payload.length & 0xFF, 8); // 数据长度 8bit
    w.writeBits(fragFlag & 0x01, 1); // 分片标志 1bit
    if (fragFlag == FragFlag.frag) {
      w.writeBits(position & 0x03, 2); // 分片位置 2bit
    }
    for (final b in payload) {
      w.writeByte(b); // 负载逐字节
    }
    return w.toBytes();
  }

  /// 解析单帧。数据不足时返回 null。
  static BleFrame? decode(Uint8List raw) {
    // 至少需要不分片头部 11bit => 2 字节。
    if (raw.length < 2) return null;
    final r = _BitReader(raw);
    final int type = r.readBits(2);
    final int len = r.readBits(8);
    final int fragFlag = r.readBits(1);

    int position = FragPos.none;
    if (fragFlag == FragFlag.frag) {
      position = r.readBits(2);
    }

    // 读取 len 字节负载 (受剩余可读位限制)。
    final int availBytes = r.remainingBits ~/ 8;
    final int useLen = len <= availBytes ? len : availBytes;
    final Uint8List payload = Uint8List(useLen);
    for (int i = 0; i < useLen; i++) {
      payload[i] = r.readBits(8);
    }

    return BleFrame(
      protocolType: type,
      payloadLength: len,
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
  final Map<String, List<int>> _buffers = {};

  String _key(String deviceId, int protocolType) => '$deviceId#$protocolType';

  BleMessage? addRaw(String deviceId, Uint8List raw) {
    final frame = BleProtocolCodec.decode(raw);
    if (frame == null) return null;
    return addFrame(deviceId, frame);
  }

  BleMessage? addFrame(String deviceId, BleFrame frame) {
    // 不分片: 直接是完整消息。
    if (!frame.isFragmented) {
      return BleMessage(frame.protocolType, Uint8List.fromList(frame.payload));
    }

    final key = _key(deviceId, frame.protocolType);

    // 首片: 新建缓冲。
    if (frame.position == FragPos.first) {
      _buffers[key] = <int>[]..addAll(frame.payload);
      return null;
    }

    // 中间/末片: 追加 (无首片缓冲则丢弃, 防脏数据)。
    final buf = _buffers[key];
    if (buf == null) return null;
    buf.addAll(frame.payload);

    // 末片: 组装完整消息。
    if (frame.position == FragPos.last) {
      _buffers.remove(key);
      return BleMessage(frame.protocolType, Uint8List.fromList(buf));
    }
    return null;
  }

  void clearDevice(String deviceId) {
    _buffers.removeWhere((k, _) => k.startsWith('$deviceId#'));
  }

  void clearAll() => _buffers.clear();
}
