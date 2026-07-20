class NotificationEntity {
  final int id;
  final int? maNguoiDung;
  final String tieuDe;
  final String noiDung;
  final String loaiThongBao;
  final bool daDoc;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    this.maNguoiDung,
    required this.tieuDe,
    required this.noiDung,
    required this.loaiThongBao,
    required this.daDoc,
    required this.createdAt,
  });
}