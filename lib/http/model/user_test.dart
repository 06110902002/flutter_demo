import 'package:json_annotation/json_annotation.dart';

part 'user_test.g.dart';

@JsonSerializable()
class UserTest {
  final String name;
  final String email;
  final int? age; // 可空字段

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(ignore: true)
  final String temporaryCode; // 忽略的字段

  UserTest({
    required this.name,
    required this.email,
    this.age,
    required this.createdAt,
    this.temporaryCode = '',
  });

  // 从 JSON 创建 User 实例
  /// 使用 flutter pub run build_runner build  自动创建 _$UserFromJson 方法
  /// # 一次性生成
  // flutter pub run build_runner build
  //
  // # 监听文件变化自动生成
  // flutter pub run build_runner watch
  //
  // # 如果遇到冲突，使用 --delete-conflicting-outputs
  // flutter pub run build_runner build --delete-conflicting-outputs
  factory UserTest.fromJson(Map<String, dynamic> json) => _$UserTestFromJson(json);

  // 将 User 实例转换为 JSON
  Map<String, dynamic> toJson() => _$UserTestToJson(this);
}
