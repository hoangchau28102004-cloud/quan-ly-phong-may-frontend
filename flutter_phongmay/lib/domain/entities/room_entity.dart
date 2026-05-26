class RoomEntity {
  final int id;
  final String tenPhong;
  final String trangThai; // HOAT_DONG, BAO_TRI, KHOA

  RoomEntity({
    required this.id,
    required this.tenPhong,
    required this.trangThai,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
