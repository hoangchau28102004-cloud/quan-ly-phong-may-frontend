class ScheduleItem {
  final int thu; // <-- Thêm trường này để filter
  final String ngayHoc;
  final int? phongMayId;
  final String tenMon;
  final String tenPhong;
  final String maLop;
  final String gioBatDau;
  final String gioKetThuc;
  final String tenGiangVien;

  ScheduleItem({
    required this.thu,
    required this.ngayHoc,
    this.phongMayId,
    required this.tenMon,
    required this.tenPhong,
    required this.maLop,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.tenGiangVien,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      thu: json['thu'] ?? 2, // Map cột thu từ CSDL
      ngayHoc: json['ngay_hoc'].toString().split('T')[0],
      phongMayId: json['phong_may_id'] ?? json['phong_id'] ?? json['phongId'],
      tenMon: json['ten_mon'] ?? '',
      tenPhong: json['ten_phong'] ?? '',
      maLop: json['ma_lop'] ?? '',
      gioBatDau: json['gio_bat_dau'] ?? '',
      gioKetThuc: json['gio_ket_thuc'] ?? '',
      tenGiangVien: json['ten_giang_vien'] ?? '',
    );
  }
}
