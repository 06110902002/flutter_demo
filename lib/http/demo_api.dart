/// @author: jiangjunhui
/// @date: 2025/1/24
library;




import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'core/my_request_options.dart';
import 'core/network_service.dart';
import 'model/login_model.dart';
import 'model/my_base_list_model.dart';
import 'model/my_base_model.dart';
import 'model/user_test.dart';
import 'model/userinfo_model.dart';
import 'package:flutter/material.dart';




import 'dart:convert';  /// json 转换相关

/// 测试json 与 model 之间的转换
void json2Model() {

  // JSON 字符串
  String jsonString = '''
  {
    "name": "张三",
    "email": "zhangsan@example.com",
    "age": 25,
    "created_at": "2023-10-01T10:00:00Z"
  }
  ''';

  // 反序列化：JSON → Dart 对象
  Map<String, dynamic> userMap = jsonDecode(jsonString);
  UserTest user = UserTest.fromJson(userMap);

  print('姓名: ${user.name}');
  print('邮箱: ${user.email}');
  print('年龄: ${user.age}');
  print('创建时间: ${user.createdAt}');

  // 序列化：Dart 对象 → JSON
  Map<String, dynamic> json = user.toJson();
  String jsonOutput = jsonEncode(json);
  print('JSON 输出: $jsonOutput');
}



/// 测试http 请求  参考文档：https://juejin.cn/post/7475651131449819136
/// 参考代码 https://github.com/SunshineBrother/flutter-tool/tree/master/flutter_module/lib/core
void _get(NetworkService networkService) async {
  print("19----------http get 请求测试");
  MyRequestOptions options = MyRequestOptions(url: "/userInfo");
  try {
    MyBaseModel<UserInfoModel> result = await networkService.get(
        options: options,
        fromJsonT: (json) =>
            UserInfoModel.fromJson(json as Map<String, dynamic>));
    if (result.isSucess()) {
      print('26--------User name: ${result.data?.name}');
      print('27---------User age: ${result.data?.age}');
    } else {
      print('29------请求错误message: ${result.message}===code:${result.code}');
    }
  } catch (e) {
    print('32----------NetworkServicePageState Error: $e');
  }
}

void _post(NetworkService networkService) async {
  print("38----------http post 请求测试");
  MyRequestOptions options = MyRequestOptions(url: "/login");
  try {
    MyBaseModel<LoginModel> result = await networkService.post(
        options: options,
        fromJsonT: (json) =>
            LoginModel.fromJson(json as Map<String, dynamic>));
    if (result.isSucess()) {
      print('44-----User userId: ${result.data?.userId}');
      print('45---------User token: ${result.data?.token}');
    } else {
      print('47-------NetworkServicePageState Request failed: ${result.message}');
    }
  } catch (e) {
    print('50---------NetworkServicePageState Error: $e');
  }
}

void testHttpRequest() {
  NetworkService networkService = NetworkService();
  _get(networkService);
  _post(networkService);

}

main() {
  json2Model();
  testHttpRequest();
  runApp(const httpTest());
}


class httpTest extends StatelessWidget
{
  const httpTest({super.key});

  @override
  Widget build(BuildContext context)
  {

    return MaterialApp(
        title: 'Flutter Demo',
        home: Scaffold(
          appBar: AppBar(
              title: Text(
                'Hello Flutter this is first demo',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
          ),

          body: Padding(
            padding: EdgeInsets.only(left: 10), // 只添加左边距 10
            child: Align(
              alignment: Alignment(-1.0, -1.0),
              child: Text('Hello World!'),
            ),

          ),
        ),
      // 将 FlutterEasyLoading 的初始化配置在 builder 属性中
      builder: EasyLoading.init(),
    );
  }
}



// 假设这是一个简单的数据模型
class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
    };
  }
}


// void main() async {
//   NetworkService networkService = NetworkService();
//
//   try {
//     // 发起 GET 请求获取用户信息
//     MyBaseModel<User> result = await networkService.get<User>(
//       '/user',
//       fromJsonT: (json) => User.fromJson(json as Map<String, dynamic>),
//     );
//
//     if (result.isSucess()) {
//       print('User name: ${result.data?.name}');
//       print('User age: ${result.data?.age}');
//     } else {
//       print('Request failed: ${result.message}');
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }


// // 发起 GET 请求获取用户列表信息
//     MyBaseListModel<User> result = await networkService.getList<User>(
//       '/users',
//       fromJsonT: (json) => User.fromJson(json as Map<String, dynamic>),
//     );
//
//
// //T 是基础类型
//  MyBaseModel<int> model = MyBaseModel.fromJson(
//     jsonMap,
//     (json) => json as int, // 直接将 JSON 值转换为 int
//   );
//
//
//   MyBaseModel<String> model = MyBaseModel.fromJson(
//     jsonMap,
//     (json) => json as String, // 直接将 JSON 值转换为 String
//   );
