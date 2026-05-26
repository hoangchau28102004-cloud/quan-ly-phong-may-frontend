// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleItem _$ScheduleItemFromJson(Map<String, dynamic> json) =>
    _ScheduleItem(
      thu: (json['thu'] as num).toInt(),
      ngayHoc: _parseNgayHoc(json['ngay_hoc']),
      phongMayId: (json['phong_may_id'] as num?)?.toInt(),
      tenMon: json['ten_mon'] as String,
      tenPhong: json['ten_phong'] as String,
      maLop: json['ma_lop'] as String,
      gioBatDau: json['gio_bat_dau'] as String,
      gioKetThuc: json['gio_ket_thuc'] as String,
      tenGiangVien: json['ten_giang_vien'] as String,
    );

Map<String, dynamic> _$ScheduleItemToJson(_ScheduleItem instance) =>
    <String, dynamic>{
      'thu': instance.thu,
      'ngay_hoc': instance.ngayHoc,
      'phong_may_id': instance.phongMayId,
      'ten_mon': instance.tenMon,
      'ten_phong': instance.tenPhong,
      'ma_lop': instance.maLop,
      'gio_bat_dau': instance.gioBatDau,
      'gio_ket_thuc': instance.gioKetThuc,
      'ten_giang_vien': instance.tenGiangVien,
    };
