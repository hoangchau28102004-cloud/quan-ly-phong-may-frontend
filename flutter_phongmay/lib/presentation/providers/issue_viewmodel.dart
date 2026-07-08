import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class IssueViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<dynamic> computers = [];

  // Tải danh sách máy của phòng được chọn
  Future<void> fetchComputers(int maPhong) async {
    isLoading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/issues/computers?ma_phong=$maPhong');
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          computers = body['data'] ?? [];
        }
      }
    } catch (e) {
      debugPrint('Lỗi fetchComputers: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // Gửi form báo lỗi lên hệ thống
  Future<bool> sendIssueReport({
    required int maNguoiBaoCao,
    required String maMayTinh, // QUAN TRỌNG: Ép kiểu thành String
    required String loaiSuCo,
    required String tieuDe,
    required String moTa,
    required String mucDo,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      // Đảm bảo trỏ đúng endpoint là /bao-cao-su-co
      final res = await ApiService.post('/bao-cao-su-co', {
        'ma_nguoi_bao_cao': maNguoiBaoCao,
        'ma_may_tinh': maMayTinh, // Truyền thẳng chuỗi quét được xuống đây
        'loai_su_co': loaiSuCo,
        'tieu_de': tieuDe,
        'mo_ta': moTa,
        'muc_do': mucDo,
      });
      isLoading = false;
      notifyListeners();
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('Lỗi sendIssueReport: $e');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}