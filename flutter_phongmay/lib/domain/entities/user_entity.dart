class UserEntity {
  final int id;
  final String hoTen;
  final String? email;
  final String? taiKhoan;
  final String? soDienThoai;
  final int vaiTroId;
  final int? lopHocId;
  
  // --- BẮT BUỘC PHẢI CÓ 3 BIẾN NÀY ---
  final int trangThai; 
  final String? gioiTinh;
  final String? ngaySinh;

  UserEntity({
    required this.id,
    required this.hoTen,
    this.email,
    this.taiKhoan,
    this.soDienThoai,
    required this.vaiTroId,
    this.lopHocId,
    this.trangThai = 1, // Mặc định là 1
    this.gioiTinh,
    this.ngaySinh,
  });

  UserEntity copyWith({
    int? id,
    String? hoTen,
    String? email,
    String? taiKhoan,
    String? soDienThoai,
    int? vaiTroId,
    int? lopHocId,
    int? trangThai,
    String? gioiTinh,
    String? ngaySinh,
  }) {
    return UserEntity(
      id: id ?? this.id,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      taiKhoan: taiKhoan ?? this.taiKhoan,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      vaiTroId: vaiTroId ?? this.vaiTroId,
      lopHocId: lopHocId ?? this.lopHocId,
      trangThai: trangThai ?? this.trangThai,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      ngaySinh: ngaySinh ?? this.ngaySinh,
    );
  }
}