class IncidentEntity {
  final int id;
  final String moTa;
  final String trangThai; // CHO_XU_LY, DANG_XU_LY, DA_XU_LY
  final int mayTinhId;
  final int nguoiDungId;

  IncidentEntity({
    required this.id,
    required this.moTa,
    required this.trangThai,
    required this.mayTinhId,
    required this.nguoiDungId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncidentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
