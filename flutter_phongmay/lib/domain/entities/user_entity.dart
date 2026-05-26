class UserEntity {
  final int id;
  final String taiKhoan;
  final String hoTen;
  final String? email;
  final int vaiTroId;
  final int? lopHocId;

  UserEntity({
    required this.id,
    required this.taiKhoan,
    required this.hoTen,
    this.email,
    required this.vaiTroId,
    this.lopHocId,
  });

  // Copy with for state management
  UserEntity copyWith({
    int? id,
    String? taiKhoan,
    String? hoTen,
    String? email,
    int? vaiTroId,
    int? lopHocId,
  }) {
    return UserEntity(
      id: id ?? this.id,
      taiKhoan: taiKhoan ?? this.taiKhoan,
      hoTen: hoTen ?? this.hoTen,
      email: email ?? this.email,
      vaiTroId: vaiTroId ?? this.vaiTroId,
      lopHocId: lopHocId ?? this.lopHocId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          taiKhoan == other.taiKhoan &&
          hoTen == other.hoTen;

  @override
  int get hashCode => id.hashCode ^ taiKhoan.hashCode ^ hoTen.hashCode;
}
