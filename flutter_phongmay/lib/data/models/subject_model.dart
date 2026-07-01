class SubjectModel {
  final int id;
  final String maMonHoc;
  final String tenMon;
  final String loaiMon;
  final int soTinChi;
  final String? moTa;

  SubjectModel({
    required this.id,
    required this.maMonHoc,
    required this.tenMon,
    required this.loaiMon,
    required this.soTinChi,
    this.moTa,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? 0,
      maMonHoc: json['ma_mon_hoc'] ?? '',
      tenMon: json['ten_mon'] ?? '',
      loaiMon: json['loai_mon'] ?? 'Cơ sở',
      soTinChi: json['so_tin_chi'] ?? 0,
      moTa: json['mo_ta'],
    );
  }

  // --- ĐÂY CHÍNH LÀ CHỖ QUAN TRỌNG NHẤT ĐỂ BACKEND NHẬN ĐƯỢC DỮ LIỆU ---
  Map<String, dynamic> toJson() {
    return {
      'ma_mon_hoc': maMonHoc,
      'ten_mon': tenMon,
      'loai_mon': loaiMon,
      'so_tin_chi': soTinChi,
      'mo_ta': moTa,
    };
  }
}