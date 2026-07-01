class TeacherModel {
  final int id;
  final String maGiangVien;
  final String hoTen;

  TeacherModel({
    required this.id,
    required this.maGiangVien,
    required this.hoTen,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      maGiangVien: json['ma_giang_vien'] ?? '',
      hoTen: json['ho_ten'] ?? '',
    );
  }
}