import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_phongmay/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required int id,
    @JsonKey(name: 'tai_khoan') required String taiKhoan,
    @JsonKey(name: 'ho_ten') required String hoTen,
    @JsonKey(name: 'vai_tro_id') required int vaiTroId,
    @JsonKey(name: 'lop_hoc_id') int? lopHocId,
    
    // --- KHAI BÁO THÊM CÁC TRƯỜNG CÒN THIẾU Ở ĐÂY ---
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'so_dien_thoai') String? soDienThoai,
    @JsonKey(name: 'trang_thai') int? trangThai,
    @JsonKey(name: 'gioi_tinh') String? gioiTinh,
    @JsonKey(name: 'ngay_sinh') String? ngaySinh,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  UserEntity toEntity() {
    // Không cần ép kiểu dynamic nữa vì các trường đã có sẵn trong class
    return UserEntity(
      id: id,
      taiKhoan: taiKhoan,
      hoTen: hoTen,
      trangThai: trangThai ?? 1,
      email: email,
      soDienThoai: soDienThoai,
      vaiTroId: vaiTroId,
      lopHocId: lopHocId,
      gioiTinh: gioiTinh,
      ngaySinh: ngaySinh,
    );
  }
}