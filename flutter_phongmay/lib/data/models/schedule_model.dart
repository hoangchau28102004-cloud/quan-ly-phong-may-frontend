import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

String _parseNgayHoc(dynamic json) => json?.toString().split('T')[0] ?? '';

@freezed
abstract class ScheduleItem with _$ScheduleItem {
  const factory ScheduleItem({
    required int thu,
    @JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc) required String ngayHoc,
    @JsonKey(name: 'phong_may_id') int? phongMayId,
    @JsonKey(name: 'ten_mon') required String tenMon,
    @JsonKey(name: 'ten_phong') required String tenPhong,
    @JsonKey(name: 'ma_lop') required String maLop,
    @JsonKey(name: 'gio_bat_dau') required String gioBatDau,
    @JsonKey(name: 'gio_ket_thuc') required String gioKetThuc,
    @JsonKey(name: 'ten_giang_vien') required String tenGiangVien,
  }) = _ScheduleItem;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemFromJson(json);
}
