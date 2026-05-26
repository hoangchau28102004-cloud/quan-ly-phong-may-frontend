// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: (json['id'] as num).toInt(),
  taiKhoan: json['tai_khoan'] as String,
  hoTen: json['ho_ten'] as String,
  vaiTroId: (json['vai_tro_id'] as num).toInt(),
  lopHocId: (json['lop_hoc_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tai_khoan': instance.taiKhoan,
      'ho_ten': instance.hoTen,
      'vai_tro_id': instance.vaiTroId,
      'lop_hoc_id': instance.lopHocId,
    };
