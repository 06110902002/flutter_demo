import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class CustomHttpClientAdapter implements HttpClientAdapter {
  final HttpClientAdapter _defaultAdapter = IOHttpClientAdapter();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future? cancelFuture,
  ) async {
    final timings = <String, num>{};

    // 记录开始时间
    final startTime = DateTime.now();

    // DNS解析开始时间
    final dnsStartTime = DateTime.now();

    // 创建HttpClient
    final httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    // 解析DNS
    final uri = options.uri;
    final addresses = await InternetAddress.lookup(uri.host);
    // DNS解析结束时间
    final dnsEndTime = DateTime.now();
    final dnsTime = dnsEndTime.difference(dnsStartTime).inMilliseconds;

    // TCP连接开始时间
    final tcpStartTime = DateTime.now();
    final socket = await Socket.connect(
      addresses.first,
      uri.port,
      timeout: const Duration(seconds: 10),
    );
    // TCP连接结束时间
    final tcpEndTime = DateTime.now();
    final tcpTime = tcpEndTime.difference(tcpStartTime).inMilliseconds;

    // SSL握手开始时间（如果是HTTPS）
    final sslStartTime = DateTime.now();
    SecureSocket? secureSocket;
    if (uri.scheme == 'https') {
      secureSocket = await SecureSocket.secure(
        socket,
        host: uri.host,
        onBadCertificate: (cert) => true,
      );
    }
    // SSL握手结束时间
    final sslEndTime = DateTime.now();
    final sslTime = sslEndTime.difference(sslStartTime).inMilliseconds;
    // 首包时间开始记录
    final firstPacketStartTime = DateTime.now();
    // 使用默认适配器发送请求
    final response = await _defaultAdapter.fetch(
      options,
      requestStream,
      cancelFuture,
    );
    // 首包时间结束记录
    final firstPacketEndTime = DateTime.now();
    final firstPacketTime =
        firstPacketEndTime.difference(firstPacketStartTime).inMilliseconds;
    // 总耗时
    final totalTime = DateTime.now().difference(startTime).inMilliseconds;

    // 打印统计信息
    timings['dns'] = dnsTime;
    timings['tcp'] = tcpTime;
    timings['ssl'] = sslTime;
    timings['first_packet'] = firstPacketTime;
    timings['totalTime'] = totalTime;

    // print('DNS解析耗时: $dnsTime ms');
    // print('TCP三次握手耗时: $tcpTime ms');
    // print('SSL握手耗时: $sslTime ms');
    // print('首包时间: $firstPacketTime ms');
    // print('总耗时: $totalTime ms');

    // 将耗时数据存入请求配置的 extra 字段
    options.extra.addAll(timings);
    return response;
  }

  @override
  void close({bool force = false}) {
    _defaultAdapter.close(force: force);
  }
}
