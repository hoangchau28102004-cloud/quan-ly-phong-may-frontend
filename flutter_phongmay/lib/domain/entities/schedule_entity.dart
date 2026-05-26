class ScheduleEntity {
  final int id;
  final DateTime ngayHoc;
  final int tuanHoc;
  final int thu;
  final int tietBatDau;
  final int tietKetThuc;
  final int phongMayId;
  final int lopHocPhanId;
  final int nguoiDungId;
  final int caHocId;
  final String tenMon;
  final String tenPhong;
  final String maLop;
  final String gioBatDau;
  final String gioKetThuc;
  final String tenGiangVien;

  ScheduleEntity({
    required this.id,
    required this.ngayHoc,
    required this.tuanHoc,
    required this.thu,
    required this.tietBatDau,
    required this.tietKetThuc,
    required this.phongMayId,
    required this.lopHocPhanId,
    required this.nguoiDungId,
    required this.caHocId,
    required this.tenMon,
    required this.tenPhong,
    required this.maLop,
    required this.gioBatDau,
    required this.gioKetThuc,
    required this.tenGiangVien,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
