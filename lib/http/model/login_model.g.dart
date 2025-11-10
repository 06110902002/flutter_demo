// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) => LoginModel(
  (json['userId'] as num).toInt(),
  json['mobile'] as String,
  json['token'] as String,
  json['userName'] as String,
);

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'mobile': instance.mobile,
      'token': instance.token,
      'userName': instance.userName,
    };
