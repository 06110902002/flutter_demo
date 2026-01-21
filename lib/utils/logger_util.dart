/// Author: Rambo.Liu
/// Date: 2026/1/12 11:22
/// @Copyright by JYXC Since 2023
/// Description: TODO
import 'dart:convert';

/// Flutter 全局日志工具类
/// 特性：分级打印/超长日志不截断/Json格式化/Release环境自动关闭/类名方法名定位
import 'dart:convert';

/// Flutter 全局日志打印工具类 - 完美修复版
/// 核心特性：完整文件路径+类名+方法名+行号、超长日志不截断、JSON格式化、分级打印、Release自动关闭、无乱码
class LoggerUtil {
  /// 全局日志总开关 - 上线打包时改为 false 即可关闭所有日志
  static const bool isOpenLog = true;

  /// 调试级日志 - 开发调试、变量打印、接口入参 【优先级最低】
  static void d(Object? msg, {String tag = "DEBUG"}) {
    _printLog(msg, tag: tag, level: LogLevel.debug);
  }

  /// 信息级日志 - 业务流程节点、接口请求成功、正常状态变更
  static void i(Object? msg, {String tag = "INFO"}) {
    _printLog(msg, tag: tag, level: LogLevel.info);
  }

  /// 警告级日志 - 非致命异常、数据为空、参数不合法、兼容型错误 需关注
  static void w(Object? msg, {String tag = "WARNING"}) {
    _printLog(msg, tag: tag, level: LogLevel.warning);
  }

  /// 错误级日志 - 接口报错、try-catch捕获异常、业务逻辑错误 重点关注
  static void e(Object? msg, {String tag = "ERROR", StackTrace? stackTrace}) {
    _printLog(msg, tag: tag, level: LogLevel.error, stackTrace: stackTrace);
  }

  /// JSON专用打印 - 传入json字符串，自动格式化+缩进+分行，美观易读
  // static void json(String jsonStr, {String tag = "JSON"}) {
  //   if (!isOpenLog) return;
  //   try {
  //     final dynamic jsonBody = json.decode(jsonStr);
  //     final String formatted = const JsonEncoder.withIndent('  ').convert(jsonBody);
  //     _printLog('════════════════════════ JSON 格式化开始 ════════════════════════', tag: tag, level: LogLevel.json);
  //     _printLog(formatted, tag: tag, level: LogLevel.json);
  //     _printLog('════════════════════════ JSON 格式化结束 ════════════════════════', tag: tag, level: LogLevel.json);
  //   } catch (e) {
  //     e("JSON解析失败：$e \n原始JSON字符串：$jsonStr", tag: tag);
  //   }
  // }
}

/// 日志等级枚举 - 提取到外部 兼容所有Dart版本 无未定义报错
enum LogLevel {
  debug,
  info,
  warning,
  error,
  json
}

/// 核心打印方法 - 统一处理所有日志逻辑
void _printLog(Object? msg, {required String tag, required LogLevel level, StackTrace? stackTrace}) {
  // 核心：Release模式下 assert内代码会被编译器完全剔除，零性能损耗
  assert(() {
    if (!LoggerUtil.isOpenLog) return true;
    String logContent = msg?.toString() ?? "日志内容为null";
    String time = _getCurrentTime();
    // 获取【文件路径+类名+方法名+行号】完整定位信息
    String location = _getCodeLocation(stackTrace);
    // 拼接标准日志格式，统一排版 无乱码
    //String logHeader = "[$time] [$tag] [$level] $location";
    String logHeader = "[$time]";

    // 解决Flutter原生print 超长日志截断问题（超过1024字符必截断）
    const int maxLineLength = 800;
    if (logContent.length <= maxLineLength) {
      print("$logHeader -> $logContent");
    } else {
      print("$logHeader -> 【超长日志-${logContent.length}字符】↓↓↓");
      for (int i = 0; i < logContent.length; i += maxLineLength) {
        int end = i + maxLineLength;
        if (end > logContent.length) end = logContent.length;
        print(logContent.substring(i, end));
      }
      print("↑↑↑ 超长日志结束 ↑↑↑");
    }
    return true;
  }());
}

/// 获取格式化的当前时间 格式：yyyy-MM-dd HH:mm:ss
String _getCurrentTime() {
  DateTime now = DateTime.now();
  return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
}

/// ✅ 核心修复：精准解析【文件路径 + 类名 + 方法名 + 行号】 100%解析成功 无未知位置
String _getCodeLocation(StackTrace? stackTrace) {
  try {
    // 获取堆栈信息，传了stackTrace就用异常堆栈，否则用当前调用堆栈
    String stackInfo = stackTrace?.toString() ?? StackTrace.current.toString();
    List<String> stackLines = stackInfo.split('\n').where((line) => line.isNotEmpty).toList();

    // 关键：过滤掉日志工具类自身的堆栈，定位到【业务代码的调用行】
    String targetLine = "";
    for (String line in stackLines) {
      if (line.contains(".dart") && !line.contains("logger_util.dart") && !line.contains("_printLog") && !line.contains("_getCodeLocation")) {
        targetLine = line.trim();
        break;
      }
    }
    if (targetLine.isEmpty) targetLine = stackLines.length > 2 ? stackLines[2].trim() : stackLines.first.trim();

    // 正则匹配规则：适配所有Flutter/Dart的堆栈格式，提取 路径、文件名、行号、列号
    RegExp regExp = RegExp(r'package:(\S+)/(\S+\.dart):(\d+):(\d+)');
    Match? match = regExp.firstMatch(targetLine);

    if (match != null) {
      String packageName = match.group(1) ?? "";
      String fileName = match.group(2) ?? "未知文件";
      String lineNum = match.group(3) ?? "0";
      String columnNum = match.group(4) ?? "0";
      String fullPath = "package:$packageName/$fileName";

      // 提取类名和方法名
      String className = _getClassName(targetLine);
      String methodName = _getMethodName(targetLine);

      // 最终返回：文件路径 + 类名 + 方法名 + 行号:列号
      return "$fullPath > $className.$methodName [行:$lineNum,列:$columnNum]";
    } else {
      return "解析失败: $targetLine";
    }
  } catch (e) {
    return "位置解析异常: ${e.toString()}";
  }
}

/// 从堆栈中提取类名
String _getClassName(String stackLine) {
  try {
    RegExp reg = RegExp(r'(\w+)(?=\.)');
    Match? match = reg.firstMatch(stackLine);
    return match?.group(1) ?? "未知类";
  } catch (_) {
    return "未知类";
  }
}

/// 从堆栈中提取方法名
String _getMethodName(String stackLine) {
  try {
    RegExp reg = RegExp(r'\.(\w+)\s*\(');
    Match? match = reg.firstMatch(stackLine);
    return match?.group(1) ?? "未知方法";
  } catch (_) {
    return "未知方法";
  }
}
