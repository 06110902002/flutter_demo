/// @author: jiangjunhui
/// @date: 2025/2/10
library;
import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';


@JsonSerializable()
class LoginModel extends Object {

  @JsonKey(name: 'userId')
  int userId;

  @JsonKey(name: 'mobile')
  String mobile;

  @JsonKey(name: 'token')
  String token;

  @JsonKey(name: 'userName')
  String userName;

  LoginModel(this.userId,this.mobile,this.token,this.userName,);

  factory LoginModel.fromJson(Map<String, dynamic> srcJson) => _$LoginModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);

}


