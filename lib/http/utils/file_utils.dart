/// @author: jiangjunhui
/// @date: 2025/1/23
library;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../page_frame_work/log/log.dart';

class FileUtils {
  static const Custom_Cached_File_Key = "Custom_Cached_File_Key";
  FileUtils._privateConstructor();
  static final FileUtils _instance = FileUtils._privateConstructor();
  factory FileUtils() {
    return _instance;
  }

  /// 写入文件
  Future<void> writeFile({required String fileName,required String content, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName, moduleName: moduleName);
      Log.debug("文件地址：${file.path}");
      // 等待写入操作完成
      await file.writeAsString(content);
    } on PlatformException catch (e) {
      Log.debug('写入文件时发生平台异常: ${e.message}');
      rethrow;
    } on FileSystemException catch (e) {
      Log.debug('文件系统写入出错: ${e.message}');
      rethrow;
    } catch (e) {
      Log.debug('文件写入失败: $e');
      rethrow;
    }
  }
  // 追加内容到文件
  Future<void> appendToFile({required String fileName,required String content, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName, moduleName: moduleName);
      // 以追加模式写入内容
      await file.writeAsString(content, mode: FileMode.append);
      Log.debug('内容已成功追加到文件: ${file.path}');
    } on PlatformException catch (e) {
      Log.debug('追加内容时发生平台异常: ${e.message}');
      rethrow;
    } on FileSystemException catch (e) {
      Log.debug('文件系统操作出错: ${e.message}');
      rethrow;
    } catch (e) {
      Log.debug('追加内容到文件时出现未知错误: $e');
      rethrow;
    }
  }

  /// 读取文件
  Future<String?> getFile({required String fileName, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName, moduleName: moduleName);
      Log.debug("读取文件路径：${file.path}");
      String contents = await file.readAsString();
      return contents;
    } on PlatformException catch (e) {
      Log.debug('读取文件时发生平台异常: ${e.message}');
      return null;
    } on FileSystemException catch (e) {
      Log.debug('文件系统读取出错: ${e.message}');
      return null;
    } catch (e) {
      Log.debug('文件读取失败: $e');
      return null;
    }
  }

  /// 移除指定文件
  Future<bool> removeFilePath({required String fileName, String? moduleName}) async {
    try {
      final file = await _localFile(fileName: fileName,moduleName: moduleName);
      // 检查文件是否存在
      if (await file.exists()) {
        // 移除文件
        await file.delete();
        Log.debug('文件删除成功: ${file.path}');
        return true;
      } else {
        Log.debug('文件不存在，无需删除: ${file.path}');
        return false;
      }
    } on PlatformException catch (e) {
      Log.debug('删除文件时发生平台异常: ${e.message}');
      return false;
    } on FileSystemException catch (e) {
      Log.debug('文件系统删除出错: ${e.message}');
      return false;
    } catch (e) {
      Log.debug('移除文件时出现未知错误: $e');
      return false;
    }
  }

  /// moduleName 创建子文件夹
  Future<File> _localFile({required String fileName, String? moduleName}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      String fullPath;
      Directory dir;
      if (moduleName != null) {
        fullPath = '$path/$Custom_Cached_File_Key/$moduleName/$fileName';
        dir = Directory('$path/$Custom_Cached_File_Key/$moduleName');
      } else {
        fullPath = '$path/$Custom_Cached_File_Key/$fileName';
        dir = Directory('$path/$Custom_Cached_File_Key');
      }


      if (!await dir.exists()) {
        await dir.create(recursive: true);
        if (!await dir.exists()) {
          throw FileSystemException('无法创建目录: ${dir.path}');
        }
      }

      return File(fullPath);
    } on PlatformException catch (e) {
      print('获取应用程序文档目录时发生平台异常: ${e.message}');
      rethrow;
    } on FileSystemException catch (e) {
      print('文件系统操作出错: ${e.message}');
      rethrow;
    } catch (e) {
      print('发生未知错误: $e');
      rethrow;
    }
  }
}
