/// Author: Rambo.Liu
/// Date: 2026/1/30 16:18
/// @Copyright by ZYQL Since 2025
/// Description: TODO
import 'dart:convert';
import 'dart:typed_data';

import 'package:test_flutter/byte/packet.dart';

class PacketParser {
  final List<int> _buffer = [];

  /// 网络每来一段数据，就喂给 parser
  List<Packet> addData(Uint8List chunk) {
    _buffer.addAll(chunk);

    final packets = <Packet>[];

    while (true) {
      // 至少要有 4 字节头
      if (_buffer.length < 4) break;

      final byteData = ByteData.sublistView(Uint8List.fromList(_buffer));

      final payloadLength = byteData.getUint16(0, Endian.big);
      final type = byteData.getUint16(2, Endian.big);

      final totalLength = 4 + payloadLength;

      // 半包：数据不够
      if (_buffer.length < totalLength) break;

      // 取 payload
      final payloadBytes = _buffer.sublist(4, totalLength);
      final payload = utf8.decode(payloadBytes);

      packets.add(Packet(type, payload as Uint8List));

      // 移除已解析的数据
      _buffer.removeRange(0, totalLength);
    }

    return packets;
  }
}
