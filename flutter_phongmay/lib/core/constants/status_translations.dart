String translateAppStatus(String? status, {String defaultLabel = 'Chưa rõ'}) {
  if (status == null) return defaultLabel;

  final lower = status.toString().trim().toLowerCase();
  if (lower.isEmpty) return defaultLabel;

  switch (lower) {
    case 'active':
      return 'Đang hoạt động';
    case 'borrowed':
      return 'Đang mượn';
    case 'returned':
      return 'Đã trả';
    case 'maintenance':
      return 'Bảo trì';
    case 'pending':
      return 'Chờ duyệt';
    case 'approved':
      return 'Đã duyệt';
    case 'rejected':
      return 'Từ chối';
    case 'open':
      return 'Đang mở';
    case 'closed':
      return 'Đã khắc phục';
    case 'in_progress':
      return 'Đang sửa chữa';
    case 'completed':
      return 'Hoàn thành';
    case 'inactive':
      return 'Đã kết thúc';
    case 'confirmed':
      return 'Đã xác nhận';
    case 'high':
      return 'Cao';
    case 'normal':
      return 'Bình thường';
    case 'low':
      return 'Thấp';
    case 'đang mượn':
      return 'Đang mượn';
    case 'đã trả':
      return 'Đã trả';
    case 'đã duyệt':
      return 'Đã duyệt';
    case 'từ chối':
      return 'Từ chối';
    case 'chờ duyệt':
      return 'Chờ duyệt';
    case 'đang mở':
      return 'Đang mở';
    case 'đã khắc phục':
      return 'Đã khắc phục';
    case 'đang sửa chữa':
      return 'Đang sửa chữa';
    case 'hoàn thành':
      return 'Hoàn thành';
    case 'đã kết thúc':
      return 'Đã kết thúc';
    case 'đang hoạt động':
      return 'Đang hoạt động';
    case 'bảo trì':
      return 'Bảo trì';
    default:
      return status.toString();
  }
}
