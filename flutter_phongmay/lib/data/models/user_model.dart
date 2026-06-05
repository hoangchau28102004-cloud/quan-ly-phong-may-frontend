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
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  UserEntity toEntity() {
    // Use toJson to obtain additional fields that may be present in the API response
    final Map<String, dynamic> json =
        (this as dynamic).toJson() as Map<String, dynamic>;
    return UserEntity(
      id: (json['id'] as num).toInt(),
      taiKhoan: json['tai_khoan'] as String,
      hoTen: json['ho_ten'] as String,
      trangThai: (json['trang_thai'] as int?) ?? 1,
      email: json['email'] as String?,
      soDienThoai:
          (json['so_dien_thoai'] as String?) ?? (json['phone'] as String?),
      vaiTroId: (json['vai_tro_id'] as num).toInt(),
      lopHocId: json['lop_hoc_id'] == null
          ? null
          : (json['lop_hoc_id'] as num).toInt(),
    );
  }
}
