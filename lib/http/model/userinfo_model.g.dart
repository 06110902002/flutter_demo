// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userinfo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserInfoModel _$UserInfoModelFromJson(Map<String, dynamic> json) =>
    UserInfoModel(
      (json['id'] as num).toInt(),
      json['localTime'] as String,
      json['name'] as String,
      (json['age'] as num).toInt(),
    );

Map<String, dynamic> _$UserInfoModelToJson(UserInfoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'localTime': instance.localTime,
      'name': instance.name,
      'age': instance.age,
    };
