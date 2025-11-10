// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_base_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyBaseListModel<T> _$MyBaseListModelFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => MyBaseListModel<T>(
  code: const SafeNumConverter().fromJson(json['code']),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)?.map(fromJsonT).toList(),
);

Map<String, dynamic> _$MyBaseListModelToJson<T>(
  MyBaseListModel<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'code': _$JsonConverterToJson<dynamic, num>(
    instance.code,
    const SafeNumConverter().toJson,
  ),
  'message': instance.message,
  'data': instance.data?.map(toJsonT).toList(),
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
