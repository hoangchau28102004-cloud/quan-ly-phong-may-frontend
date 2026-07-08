import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

String _parseNgayHoc(dynamic json) => json?.toString().split('T')[0] ?? '';

@freezed
abstract class ScheduleItem with _$ScheduleItem {
  const factory ScheduleItem({
    int? id,
    required int thu,
    @JsonKey(name: 'ngay_hoc', fromJson: _parseNgayHoc) required String ngayHoc,
    @JsonKey(name: 'phong_may_id') int? phongMayId,
    
    // 🚀 BỎ chữ 'required' và THÊM '@Default('')' cho các biến dễ bị null từ Server
    @Default('') @JsonKey(name: 'ten_mon') String tenMon,
    @Default('') @JsonKey(name: 'ten_phong') String tenPhong,
    @Default('') @JsonKey(name: 'ma_lop') String maLop,
    @Default('') @JsonKey(name: 'gio_bat_dau') String gioBatDau,
    @Default('') @JsonKey(name: 'gio_ket_thuc') String gioKetThuc,
    @Default('') @JsonKey(name: 'ten_giang_vien') String tenGiangVien,
  }) = _ScheduleItem;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemFromJson(json);
}