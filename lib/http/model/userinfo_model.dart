/// @author: jiangjunhui
/// @date: 2025/2/10
library;
import 'package:json_annotation/json_annotation.dart';
part 'userinfo_model.g.dart';


@JsonSerializable()
class UserInfoModel extends Object {

  @JsonKey(name: 'id')
  int id;

  @JsonKey(name: 'localTime')
  String localTime;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'age')
  int age;

  UserInfoModel(this.id,this.localTime,this.name,this.age,);

  factory UserInfoModel.fromJson(Map<String, dynamic> srcJson) => _$UserInfoModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserInfoModelToJson(this);

}


