class UserModel {
  final int id;
  final String taiKhoan;
  final String hoTen;
  final int vaiTroId;
  final int? lopHocId;

  UserModel({
    required this.id,
    required this.taiKhoan,
    required this.hoTen,
    required this.vaiTroId,
    this.lopHocId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      taiKhoan: json['tai_khoan'],
      hoTen: json['ho_ten'],
      vaiTroId: json['vai_tro_id'],
      lopHocId: json['lop_hoc_id'],
    );
  }
}
