
import 'package:json_annotation/json_annotation.dart';

import '../../jsonConverter/safe_convert_model.dart';
import '../../jsonConverter/safe_num_converter.dart';
part 'my_base_model.g.dart';

@JsonSerializable(genericArgumentFactories: true, converters: [SafeNumConverter()])
class MyBaseModel<T> extends SafeConvertModel {
  @JsonKey(name: 'code')
  num? code;
  @JsonKey(name: 'message')
  String? message;
  T? data;

  MyBaseModel({
    this.code,
    this.message,
    this.data,
  });

  factory MyBaseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$MyBaseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$MyBaseModelToJson(this, toJsonT);

  /// 是否成功
  bool isSucess() {
    bool result = this.code?.toInt() == 0;
    return result;
  }
}
