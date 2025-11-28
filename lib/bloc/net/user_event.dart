// lib/user/bloc/user_event.dart
///第三步：定义 Event（用户操作）
abstract class UserEvent {}

class FetchUser extends UserEvent {
  final int userId;

  FetchUser(this.userId); // 带参数的构造函数
}