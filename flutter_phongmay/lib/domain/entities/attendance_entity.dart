class AttendanceEntity {
  final int id;
  final String ttDiemDanh; // CO_MAT, VANG_MAT, TRE
  final String ttMayTinh; // BINH_THUONG, CO_LOI
  final DateTime thoiGianDd;
  final int nguoiDungId;
  final int lichPhongMayId;
  final int mayTinhId;

  AttendanceEntity({
    required this.id,
    required this.ttDiemDanh,
    required this.ttMayTinh,
    required this.thoiGianDd,
    required this.nguoiDungId,
    required this.lichPhongMayId,
    required this.mayTinhId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
