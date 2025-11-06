/// @author: jiangjunhui
/// @date: 2025/2/11
library;
import 'package:logger/logger.dart';

class Log {
  static Logger? _logger;
  static bool _enabled = true;

  /// 初始化日志配置（可选调用，默认已配置基础参数）
  static void initialize({LogOptions? options}) {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: options?.methodCount ?? 0,
        errorMethodCount: options?.errorMethodCount ?? 8,
        lineLength: options?.lineLength ?? 120,
        colors: options?.colors ?? true,
        printEmojis: options?.printEmojis ?? true,
        printTime: options?.printTime ?? false,
      ),
      filter: ProductionFilter(),
    );
  }

  /// 日志开关控制
  static void enable() => _enabled = true;

  static void disable() => _enabled = false;

  /// 不同级别日志输出
  static void verbose(dynamic message,
      [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger?.v(message, error: error, stackTrace: stackTrace);
  }

  static void debug(dynamic message) {
    if (!_enabled) return;
    _logger?.d(message);
  }

  static void info(dynamic message) {
    if (!_enabled) return;
    _logger?.i(message);
  }

  static void warning(dynamic message) {
    if (!_enabled) return;
    _logger?.w(message);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enabled) return;
    _logger?.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message) {
    if (!_enabled) return;
    _logger?.wtf(message);
  }
}

/// 日志配置选项
class LogOptions {
  final int methodCount;
  final int errorMethodCount;
  final int lineLength;
  final bool colors;
  final bool printEmojis;
  final bool printTime;

  LogOptions({
    this.methodCount = 0,
    this.errorMethodCount = 8,
    this.lineLength = 120,
    this.colors = true,
    this.printEmojis = true,
    this.printTime = false,
  });
}

/// 使用示例
void main() {
  // 初始化日志配置（可选）
  Log.initialize(options: LogOptions(printTime: true));

  // 常规使用
  Log.debug('Debug message');
  Log.info('User logged in');
  Log.warning('Low memory');
  Log.error("error message");

  // 禁用日志
  Log.disable();
  Log.debug('This will not be printed');
}
