class ClassModel {
  final int id;
  final String maLop;
  final String nienKhoa;
  final String chuyenNganh;
  final int? maGiangVien;
  final String? tenGiangVien; 
  final int soSinhVien; 

  ClassModel({
    required this.id,
    required this.maLop,
    required this.nienKhoa,
    required this.chuyenNganh,
    this.maGiangVien,
    this.tenGiangVien,
    required this.soSinhVien,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? 0,
      maLop: json['ma_lop'] ?? '',
      nienKhoa: json['nien_khoa'] ?? '',
      chuyenNganh: json['chuyen_nganh'] ?? '',
      maGiangVien: json['ma_giang_vien'],
      tenGiangVien: json['ten_giang_vien'] ?? 'Chưa phân công',
      soSinhVien: json['so_sinh_vien'] ?? 0, // Lưu ý: Cần thêm logic COUNT ở BE nếu muốn số này > 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_lop': maLop,
      'nien_khoa': nienKhoa,
      'chuyen_nganh': chuyenNganh,
      'ma_giang_vien': maGiangVien,
    };
  }
}