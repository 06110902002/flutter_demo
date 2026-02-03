/// Author: Rambo.Liu
/// Date: 2026/1/30 16:13
/// @Copyright by ZYQL Since 2025
/// Description: 数据模型，用来包装byte 数组
/// 整体格式为：
/// ┌────────┬──────────┬──────────────┐
/// │ 2字节  │ 2字节     │ N字节          │
/// │ 长度   │ 类型(type)│ payload       │
/// └────────┴──────────┴──────────────┘
///长度：payload 长度（uint16）
///类型：消息类型（uint16）
///payload：utf8 字符串（示例）
import 'dart:convert';
import 'dart:typed_data';

/// ===============================
/// Packet（业务层）
/// ===============================
class Packet {
  final int type;
  final Uint8List payload;

  Packet(this.type, this.payload);

  /// 兼容所有 Dart / Flutter 版本
  String payloadAsString() {
    try {
      return utf8.decode(payload.toList());
    } catch (_) {
      return '<binary>';
    }
  }

  @override
  String toString() {
    return 'Packet(type=$type, payload=${payloadAsString()})';
  }
}

/// ===============================
/// PacketCodec（编码）
/// ===============================
class PacketCodec {
  /// 2字节 length + 2字节 type + payload
  static Uint8List encode(int type, Uint8List payload) {
    final length = payload.length;
    final buffer = Uint8List(4 + length);
    final bd = ByteData.sublistView(buffer);

    bd.setUint16(0, length, Endian.big);
    bd.setUint16(2, type, Endian.big);
    buffer.setRange(4, 4 + length, payload);

    return buffer;
  }
}

/// ===============================
/// PacketParser（流式解析）
/// ===============================
class PacketParser {
  final List<int> _buffer = [];

  static const int _headerSize = 4;
  static const int _maxBufferSize = 64 * 1024;

  List<Packet> addData(Uint8List chunk) {
    _buffer.addAll(chunk);

    if (_buffer.length > _maxBufferSize) {
      _buffer.clear();
      throw Exception('Buffer overflow');
    }

    final packets = <Packet>[];

    while (true) {
      if (_buffer.length < _headerSize) break;

      final header = ByteData.sublistView(Uint8List.fromList(_buffer));

      final length = header.getUint16(0, Endian.big);
      final type = header.getUint16(2, Endian.big);

      final totalLength = _headerSize + length;
      if (_buffer.length < totalLength) break;

      final payload = Uint8List.fromList(
        _buffer.sublist(_headerSize, totalLength),
      );

      packets.add(Packet(type, payload));

      // 精确移除已消费数据
      _buffer.removeRange(0, totalLength);
    }

    return packets;
  }

  void reset() => _buffer.clear();
}

/// ===============================
/// 模拟 Client
/// ===============================
class MockClient {
  final void Function(Uint8List data) sendToServer;

  MockClient(this.sendToServer);

  void send() {
    final messages = ['Hello', 'Flutter', 'Byte Stream', '连续发送测试'];

    for (int i = 0; i < messages.length; i++) {
      final payload = Uint8List.fromList(utf8.encode(messages[i]));
      final packet = PacketCodec.encode(i + 1, payload);

      // 模拟网络拆包
      // sendToServer(packet.sublist(0, 3));
      // sendToServer(packet.sublist(3));

      sendToServer(packet);
    }
  }
}

/// ===============================
/// 模拟 Server
/// ===============================
class MockServer {
  final PacketParser _parser = PacketParser();

  void onReceive(Uint8List data) {
    final packets = _parser.addData(data);
    for (final packet in packets) {
      print('Server 收到: $packet');
    }
  }
}

/// ===============================
/// main（联调）
/// ===============================
void main() {
  final server = MockServer();

  final client = MockClient((data) => server.onReceive(data));

  client.send();
}
