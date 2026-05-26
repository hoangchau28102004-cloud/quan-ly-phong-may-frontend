import 'package:freezed_annotation/freezed_annotation.dart';

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
