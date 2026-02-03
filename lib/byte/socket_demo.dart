/// Author: Rambo.Liu
/// Date: 2026/2/2 09:50
/// @Copyright by ZYQL Since 2025
/// Description: Socket + byte 传输测试
/// 配套的C++ 服务端代码为
//
// Created by rambo.liu on 2026/2/2.
//

// #include <arpa/inet.h>
// #include <cstring>
// #include <iostream>
// #include <unistd.h>
// #include <vector>
//
// constexpr int PORT = 12580;
//
// int main() {
// int server_fd = socket(AF_INET, SOCK_STREAM, 0);
// if (server_fd < 0) {
// perror("socket");
// return 1;
// }
//
// sockaddr_in addr{};
// addr.sin_family = AF_INET;
// addr.sin_port = htons(PORT);
// addr.sin_addr.s_addr = INADDR_ANY;
//
// if (bind(server_fd, (sockaddr*)&addr, sizeof(addr)) < 0) {
// perror("bind");
// return 1;
// }
//
// listen(server_fd, 1);
// std::cout << "C++ Server listening on port " << PORT << std::endl;
//
// int client_fd = accept(server_fd, nullptr, nullptr);
// std::cout << "Client connected" << std::endl;
//
// std::vector<uint8_t> buffer;
//
// while (true) {
// uint8_t temp[1024];
// int n = recv(client_fd, temp, sizeof(temp), 0);
// if (n <= 0) break;
//
// buffer.insert(buffer.end(), temp, temp + n);
//
// while (buffer.size() >= 4) {
// uint16_t length =
// (buffer[0] << 8) | buffer[1];
// uint16_t type =
// (buffer[2] << 8) | buffer[3];
//
// if (buffer.size() < 4 + length) break;
// // 将客户端发来的任何类型的消息（int short double string 都转换为string 进行打印，如果发现客户端发送int
// 这里打印出现乱码，需要修改此处代码 ）
// std::string payload(
// buffer.begin() + 4,
// buffer.begin() + 4 + length
// );
//
// std::cout << "Server 收到:"
// << " type=" << type
// << " payload=" << payload
// << std::endl;
//
// // ===== 回包 =====
// std::string reply = "Hello from C++ Server";
// uint16_t replyLen = reply.size();
//
// std::vector<uint8_t> sendBuf(4 + replyLen);
// sendBuf[0] = replyLen >> 8;
// sendBuf[1] = replyLen & 0xFF;
// sendBuf[2] = type >> 8;
// sendBuf[3] = type & 0xFF;
// memcpy(sendBuf.data() + 4,
// reply.data(), replyLen);
//
// send(client_fd, sendBuf.data(), sendBuf.size(), 0);
//
// buffer.erase(buffer.begin(),
// buffer.begin() + 4 + length);
// }
// }
//
// close(client_fd);
// close(server_fd);
// return 0;
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// 字节转换工具类，提供基础数据类型与 [Uint8List] 之间的转换。
///
/// 此类无法被实例化或继承。
abstract final class BytesUtils {
  /// 私有构造函数，防止该类被实例化。
  const BytesUtils._();

  /// ===============================
  /// int (32-bit) → byte[]
  /// ===============================
  /// 将一个32位整数转换为长度为4的 [Uint8List]。
  ///
  /// [value] 要转换的整数。
  /// [endian] 字节序，默认为大端序 [Endian.big]。
  /// 返回转换后的字节数组。
  static Uint8List int32ToBytes(int value, {Endian endian = Endian.big}) {
    final byteData = ByteData(4);
    byteData.setInt32(0, value, endian);
    return byteData.buffer.asUint8List();
  }

  /// ===============================
  /// byte[] → int (32-bit)
  /// ===============================
  /// 将一个长度至少为4的 [Uint8List] 转换为32位整数。
  ///
  /// [bytes] 要转换的字节数组。
  /// [endian] 字节序，默认为大端序 [Endian.big]。
  /// 返回转换后的整数。
  static int bytesToInt32(Uint8List bytes, {Endian endian = Endian.big}) {
    final byteData = ByteData.sublistView(bytes);
    return byteData.getInt32(0, endian);
  }

  /// ===============================
  /// short (16-bit) → byte[]
  /// ===============================
  /// 将一个16位整数（short）转换为长度为2的 [Uint8List]。
  ///
  /// [value] 要转换的整数。
  /// [endian] 字节序，默认为大端序 [Endian.big]。
  /// 返回转换后的字节数组。
  static Uint8List int16ToBytes(int value, {Endian endian = Endian.big}) {
    final byteData = ByteData(2);
    byteData.setInt16(0, value, endian);
    return byteData.buffer.asUint8List();
  }

  /// ===============================
  /// byte[] → short (16-bit)
  /// ===============================
  /// 将一个长度至少为2的 [Uint8List] 转换为16位整数（short）。
  ///
  /// [bytes] 要转换的字节数组。
  /// [endian] 字节序，默认为大端序 [Endian.big]。
  /// 返回转换后的整数。
  static int bytesToInt16(Uint8List bytes, {Endian endian = Endian.big}) {
    final byteData = ByteData.sublistView(bytes);
    return byteData.getInt16(0, endian);
  }

  /// ===============================
  /// String → byte[]
  /// ===============================
  /// 使用 UTF-8 编码将 [String] 转换为 [Uint8List]。
  ///
  /// [value] 要转换的字符串。
  /// 返回转换后的字节数组。
  static Uint8List stringToBytes(String value) {
    return utf8.encode(value);
  }

  /// ===============================
  /// byte[] → String
  /// ===============================
  /// 使用 UTF-8 解码将 [Uint8List] 转换为 [String]。
  ///
  /// [bytes] 要转换的字节数组。
  /// 返回转换后的字符串。
  static String bytesToString(Uint8List bytes) {
    return utf8.decode(bytes);
  }
}

/// 代表一个网络数据包。
class Packet {
  /// 数据包类型，用于区分不同种类的消息。
  final int type;

  /// 数据包的有效载荷（具体内容）。
  final Uint8List payload;

  /// 创建一个 [Packet] 实例。
  ///
  /// [type] 是数据包类型。
  /// [payload] 是数据包内容。
  Packet(this.type, this.payload);

  /// 将 [payload] 按 UTF-8 编码解码成字符串。
  /// 如果 payload 不是有效的 UTF-8 数据，则可能会抛出异常。
  String payloadAsString() => utf8.decode(payload);

  @override
  String toString() {
    // 尝试解码为字符串，如果失败则显示原始字节
    try {
      return 'Packet(type=$type, payload=${payloadAsString()})';
    } catch (_) {
      return 'Packet(type=$type, payload=${payload.toString()})';
    }
  }
}

/// 数据包编解码器，用于 [Packet] 和字节流之间的转换。
class PacketCodec {
  /// 协议头的大小（字节）。
  /// 2字节包长 + 2字节类型。
  static const int headerSize = 4;

  /// 编码一个 [Packet] 为 [Uint8List] 以便在网络中传输。
  ///
  /// 协议格式: 2字节内容长度 + 2字节类型 + N字节内容。
  /// 所有多字节整数均使用大端字节序 (network byte order)。
  ///
  /// [type] 是数据包类型。
  /// [payload] 是要编码的数据包内容。
  ///
  /// 返回编码后的 [Uint8List]。
  static Uint8List encode(int type, Uint8List payload) {
    final length = payload.length;
    final buffer = Uint8List(headerSize + length);
    final byteData = ByteData.view(buffer.buffer);

    // 使用大端字节序以兼容常见的网络协议和C++服务器
    byteData.setUint16(0, length, Endian.big);
    byteData.setUint16(2, type, Endian.big);
    buffer.setRange(headerSize, buffer.length, payload);

    return buffer;
  }
}

/// 一个将原始字节流 ([Uint8List]) 解析为 [Packet] 流的 [StreamTransformer]。
///
/// 这个转换器能够正确处理TCP流中的粘包和分包问题。
class PacketStreamTransformer extends StreamTransformerBase<Uint8List, Packet> {
  // 使用 BytesBuilder 来高效地累积传入的字节块。
  final _builder = BytesBuilder(copy: false);

  @override
  Stream<Packet> bind(Stream<Uint8List> stream) {
    final controller = StreamController<Packet>();

    stream.listen(
      (chunk) {
        // 将新的数据块添加到 builder 中
        _builder.add(chunk);
        final buffer = _builder.toBytes();
        int offset = 0;

        while (true) {
          // 检查剩余字节是否足够读取一个完整的协议头
          if (buffer.length - offset < PacketCodec.headerSize) {
            break;
          }

          // 读取协议头
          final headerView = ByteData.sublistView(
            buffer,
            offset,
            offset + PacketCodec.headerSize,
          );
          final length = headerView.getUint16(0, Endian.big);
          final type = headerView.getUint16(2, Endian.big);
          final totalPacketLength = PacketCodec.headerSize + length;

          // 检查剩余字节是否足够读取一个完整的数据包
          if (buffer.length - offset < totalPacketLength) {
            break;
          }

          // 提取并创建一个 payload 的拷贝。
          // 必须进行拷贝，因为 `buffer` 很快会被回收。
          final payload = buffer.sublist(
            offset + PacketCodec.headerSize,
            offset + totalPacketLength,
          );
          controller.add(Packet(type, payload));

          // 移动偏移量，指向下一个数据包的起始位置
          offset += totalPacketLength;
        }

        // 如果解析出任何数据包，就从 builder 中移除已处理的字节
        if (offset > 0) {
          final remaining = buffer.sublist(offset);
          _builder.clear();
          _builder.add(remaining);
        }
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    return controller.stream;
  }
}

/// 使用 [Packet] 与 Socket 服务器通信的高级客户端。
///
/// 负责处理连接、断开、发送和接收数据包的完整生命周期。
///
/// ### 用法示例:
/// ```dart
/// final client = SocketClient(host: '127.0.0.1', port: 12345);
/// client.onConnect = () => print('已连接!');
/// client.onPacket = (packet) => print('收到包: $packet');
/// await client.connect();
/// client.send(type: 1, text: '你好');
/// client.close();
/// ```
class SocketClient {
  /// 服务器主机名或IP地址。
  final String host;

  /// 服务器端口号。
  final int port;

  Socket? _socket;
  StreamSubscription? _subscription;

  /// 当客户端成功连接到服务器时调用。
  void Function()? onConnect;

  /// 当从服务器收到一个完整的包时调用。
  ///
  /// [packet] 是接收并解析成功的 [Packet] 对象。
  void Function(Packet packet)? onPacket;

  /// 当 Socket 连接正常关闭时调用。
  void Function()? onDisconnect;

  /// 当发生 Socket 错误或连接意外断开时调用。
  ///
  /// [error] 是抛出的错误对象。
  /// [stackTrace] 是错误发生时的堆栈跟踪。
  void Function(dynamic error, StackTrace stackTrace)? onError;

  /// 创建一个 [SocketClient] 实例。
  ///
  /// [host] 是要连接的服务器主机名或 IP 地址。
  /// [port] 是要连接的服务器端口号。
  SocketClient({required this.host, required this.port});

  /// 连接到 Socket 服务器。
  ///
  /// 此方法会尝试建立一个 TCP 连接，并设置监听器来处理传入的数据。
  /// 如果连接已经建立，则此方法不执行任何操作。
  ///
  /// 如果连接失败，则会调用 [onError] 回调并重新抛出异常，以便调用者可以处理连接失败的情况。
  Future<void> connect() async {
    if (_socket != null) {
      print("客户端已经连接，请勿重复连接。");
      return;
    }

    try {
      _socket = await Socket.connect(host, port);
      onConnect?.call();

      _subscription = _socket!
          .transform(PacketStreamTransformer())
          .listen(
            (packet) => onPacket?.call(packet),
            onError: (e, s) {
              onError?.call(e, s);
              close(); // 发生错误时主动关闭资源
            },
            onDone: () {
              onDisconnect?.call();
              _socket = null; // 标记为已断开
            },
            cancelOnError: true, // 确保 onError 后流会关闭
          );
    } catch (e, s) {
      onError?.call(e, s);
      close();
      // 重新抛出异常，以便 `await client.connect()` 的调用方可以捕获它。
      rethrow;
    }
  }

  /// 向服务器发送一个包。
  ///
  /// 数据将根据提供的 [type] 和内容（[text] 或 [bytes]）被编码成一个 [Packet]。
  /// [text] 和 [bytes] 至少需要提供一个。如果都提供，则优先使用 [bytes]。
  ///
  /// [type] 是要发送的数据包类型。
  /// [text] 是要发送的字符串内容。它将被自动编码为 UTF-8 字节。
  /// [bytes] 是要发送的原始字节数据。
  void send({required int type, String? text, Uint8List? bytes}) {
    if (_socket == null) {
      throw StateError('客户端尚未连接，请先调用 connect()。');
    }
    if (text == null && bytes == null) {
      throw ArgumentError('必须提供 text 或 bytes 至少一个作为发送内容。');
    }

    // 如果 bytes 为 null，则使用 text；否则优先使用 bytes。
    final payload = bytes ?? Uint8List.fromList(utf8.encode(text!));
    final packetData = PacketCodec.encode(type, payload);
    _socket!.add(packetData);
  }

  /// 关闭到服务器的连接。
  ///
  /// 这将取消数据流监听并立即销毁 socket，释放所有相关资源。
  /// [onDisconnect] 回调将被触发。
  void close() {
    _subscription?.cancel();
    _socket?.destroy(); // destroy() 会立即关闭 socket，不同于 close()，它不会等待数据发送完毕
    _subscription = null;
    _socket = null;
  }
}

/// ===============================
/// 示例用法
/// ===============================
Future<void> main() async {
  final client = SocketClient(host: '10.31.7.13', port: 12580);
  Timer? stressTestTimer;
  int sendCounter = 0;

  // 1. 设置回调函数
  client.onConnect = () {
    print('Flutter 已连接服务端');

    // 连接成功后，启动一个定时器来周期性地发送包
    stressTestTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      // 根据计数器交替发送不同类型的数据包
      if (sendCounter % 2 == 0) {
        // 发送字符串
        client.send(type: sendCounter, text: 'Hello from Flutter (text)');
      } else {
        // 发送 Uint8List 字节数组，服务端将按 int32 解析
        final bytes = BytesUtils.stringToBytes('Hello from Flutter (bytes)');
        client.send(type: sendCounter, bytes: bytes);
      }
      sendCounter++;
    });
  };

  client.onPacket = (packet) {
    print('Flutter 收到回包: $packet');
  };

  client.onDisconnect = () {
    print('Socket 连接已断开');
    stressTestTimer?.cancel();
  };

  client.onError = (e, s) {
    print('Socket 错误: $e');
    stressTestTimer?.cancel();
  };

  // 2. 连接到服务器
  try {
    await client.connect();
  } catch (e) {
    print("连接失败，程序退出: $e");
    return;
  }

  // 3. 让客户端运行 60 秒
  await Future.delayed(const Duration(seconds: 60));

  // 4. 关闭客户端
  print('Flutter socket 即将关闭');
  client.close();
}
