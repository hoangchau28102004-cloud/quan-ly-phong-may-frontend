class EquipmentEntity {
  final int id;
  final String tenTb;
  final String donViTinh;
  final String? thongSoKyThuat;
  final int? namTrangBi;
  final int soLuongCon;
  final int? phongMayId;

  EquipmentEntity({
    required this.id,
    required this.tenTb,
    required this.donViTinh,
    this.thongSoKyThuat,
    this.namTrangBi,
    required this.soLuongCon,
    this.phongMayId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquipmentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
