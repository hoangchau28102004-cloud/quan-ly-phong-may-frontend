class StudentModel {
  final int id;
  final String maSinhVien;
  final String hoTen;
  final String? email;
  final String? nienKhoa;

  StudentModel({
    required this.id,
    required this.maSinhVien,
    required this.hoTen,
    this.email,
    this.nienKhoa,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      maSinhVien: json['ma_sinh_vien'] ?? '',
      hoTen: json['ho_ten'] ?? '',
      email: json['email'],
      nienKhoa: json['nien_khoa'],
    );
  }
}