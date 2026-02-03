/// Author: Rambo.Liu
/// Date: 2026/1/30 16:04
/// @Copyright by ZYQL Since 2025
/// Description: 字节数组的使用
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:test_flutter/byte/packet.dart';

void main() {
  runApp(const ByteDemoApp());
}

class ByteDemoApp extends StatelessWidget {
  const ByteDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ByteDemoPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ByteDemoPage extends StatefulWidget {
  const ByteDemoPage({super.key});

  @override
  State<ByteDemoPage> createState() => _ByteDemoPageState();
}

class _ByteDemoPageState extends State<ByteDemoPage> {
  /// 示例数据
  final int sourceInt = 123456789;
  final String sourceString = 'Hello Flutter 字节处理 🚀';

  late Uint8List intBytes;
  late int restoredInt;

  late Uint8List stringBytes;
  late String restoredString;
  int count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    /// int ↔ byte
    intBytes = intToBytes(sourceInt);
    restoredInt = bytesToInt(intBytes);

    /// string ↔ byte
    stringBytes = stringToBytes(sourceString);
    restoredString = bytesToString(stringBytes);
  }

  /// ===============================
  /// int → byte[]
  /// ===============================
  Uint8List intToBytes(int value) {
    final byteData = ByteData(4); // int32
    byteData.setInt32(0, value, Endian.big);
    return byteData.buffer.asUint8List();
  }

  /// ===============================
  /// byte[] → int
  /// ===============================
  int bytesToInt(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    return byteData.getInt32(0, Endian.big);
  }

  /// ===============================
  /// String → byte[]
  /// ===============================
  Uint8List stringToBytes(String value) {
    return Uint8List.fromList(utf8.encode(value));
  }

  /// ===============================
  /// byte[] → String
  /// ===============================
  String bytesToString(Uint8List bytes) {
    return utf8.decode(bytes);
  }

  /// 模拟网络数据，组装字节数组
  Uint8List buildPacket(int type, String payload) {
    final payloadBytes = utf8.encode(payload);
    //整体数据长度= 4 字节头 + payload
    final byteData = ByteData(4 + payloadBytes.length);

    // 2 字节长度 + 2 字节类型 + payload
    byteData.setUint16(0, payloadBytes.length, Endian.big);
    byteData.setUint16(2, type, Endian.big);

    byteData.buffer.asUint8List().setRange(
      4,
      4 + payloadBytes.length,
      payloadBytes,
    );

    return byteData.buffer.asUint8List();
  }

  void testPacket() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      Uint8List testData = buildPacket(count++, "this is test data");
      PacketParser parser = PacketParser();
      List<Packet> packets = parser.addData(testData);
      print("154-----解析数据 = $packets");
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// ===============================
  /// UI
  /// ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter 字节处理 Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _section(
              title: '① int ↔ byte[]',
              content:
                  '''
原始 int:
$sourceInt

转成 byte[]:
${intBytes.toString()}

还原后的 int:
$restoredInt
''',
            ),
            const SizedBox(height: 20),
            _section(
              title: '② String ↔ byte[]',
              content:
                  '''
原始 String:
$sourceString

转成 byte[]:
${stringBytes.toString()}

还原后的 String:
$restoredString
''',
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    testPacket();
                  },
                  child: Text("网络数据解析"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
