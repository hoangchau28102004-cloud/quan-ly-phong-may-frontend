import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class ImportViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // 1. Biến lưu danh sách phòng máy
  List<dynamic> _rooms = [];
  List<dynamic> get rooms => _rooms;

  // 2. THÊM BIẾN LƯU DANH SÁCH PHIẾU NHẬP VÀO ĐÂY (BẠN BỊ THIẾU CHỖ NÀY)
  List<dynamic> _receipts = [];
  List<dynamic> get receipts => _receipts;

  // HÀM LẤY DANH SÁCH PHÒNG TỪ API
  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners(); // Kích hoạt UI hiển thị Vòng xoay
    
    try {
      final response = await ApiService.get('/phong-may');
      final resData = ApiService.decodeBody(response);
      if (response.statusCode == 200 && resData != null && resData['success'] == true) {
        _rooms = resData['data'] ?? [];
      }
    } catch (e) {
      print('Lỗi gọi API danh sách phòng: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Tắt vòng xoay
    }
  }

  // HÀM TẠO PHIẾU NHẬP
  Future<bool> createImportReceipt(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.post('/phieu-nhap-may', data);
      final resData = ApiService.decodeBody(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = resData?['message'] ?? 'Lỗi từ Server (Mã lỗi: ${response.statusCode})';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Lỗi kết nối máy chủ: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // HÀM FETCH PHIẾU NHẬP (CÓ IN LOG DEBUG)
  Future<void> fetchReceipts() async {
  try {
    final response = await ApiService.get('/phieu-nhap-may');
    final resData = ApiService.decodeBody(response);
    
    if (response.statusCode == 200 && resData != null && resData['success'] == true) {
      _receipts = resData['data'] ?? [];
      // LOG DÒNG NÀY ĐỂ XEM DỮ LIỆU CÓ THẬT KHÔNG
      print('=== ĐÃ GÁN DỮ LIỆU VÀO _receipts: ${_receipts.length} PHẦN TỬ ===');
      notifyListeners(); 
    } else {
      print('=== API TRẢ VỀ LỖI HOẶC RỖNG ===');
    }
  } catch (e) {
    print('=== LỖI CỰC MẠNH: $e ===');
  }
}
}