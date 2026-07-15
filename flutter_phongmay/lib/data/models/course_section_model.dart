class CourseSectionModel {
  final int id;
  final String maLopHocPhan;
  final int? maLop;
  final String? tenLop;
  final int? maMon;
  final String? tenMon;
  final int? maNamHoc;
  final String? tenNamHoc;
  final int? maPhong;
  final String? tenPhong;
  final int? maGiangVien; // <--- Đã thêm biến lưu Mã GV
  final String? tenGiangVien;
  final int soSinhVien;
  final int siSoToiDa;
  final String trangThai;
  final String? ghiChu;

  CourseSectionModel({
    required this.id,
    required this.maLopHocPhan,
    this.maLop,
    this.tenLop,
    this.maMon,
    this.tenMon,
    this.maNamHoc,
    this.tenNamHoc,
    this.maPhong,
    this.tenPhong,
    this.maGiangVien,
    this.tenGiangVien,
    required this.soSinhVien,
    required this.siSoToiDa,
    required this.trangThai,
    this.ghiChu,
  });

  factory CourseSectionModel.fromJson(Map<String, dynamic> json) {
    return CourseSectionModel(
      id: json['id'] ?? 0,
      maLopHocPhan: json['ma_lop_hoc_phan'] ?? '',
      maLop: json['ma_lop'],
      tenLop: json['ten_lop'],
      maMon: json['ma_mon'],
      tenMon: json['ten_mon'],
      maNamHoc: json['ma_nam_hoc'],
      tenNamHoc: json['ten_nam_hoc'] ?? json['nam_hoc'],
      maPhong: json['ma_phong'],
      tenPhong: json['ten_phong'],
      maGiangVien: json['ma_giang_vien'], // <--- Lấy mã GV từ DB
      tenGiangVien: json['ten_giang_vien'],
      soSinhVien: json['so_sinh_vien'] ?? 0,
      siSoToiDa: json['si_so_toi_da'] ?? 40,
      trangThai: json['trang_thai'] ?? 'Hoạt động',
      ghiChu: json['ghi_chu'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_lop_hoc_phan': maLopHocPhan,
      'ma_lop': maLop,
      'ma_mon': maMon,
      'ma_nam_hoc': maNamHoc,
      'ma_phong': maPhong,
      'ma_giang_vien': maGiangVien,
      'si_so_toi_da': siSoToiDa,
      'trang_thai': trangThai,
      'ghi_chu': ghiChu,
    };
  }
}
