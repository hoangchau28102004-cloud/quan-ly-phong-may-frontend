// import 'package:flutter/foundation.dart'; // Thêm thư viện này để dùng debugPrint
// import 'package:flutter/material.dart';
// import 'package:flutter_phongmay/data/datasources/api_service.dart';

// class ImportViewModel extends ChangeNotifier {
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   String _errorMessage = '';
//   String get errorMessage => _errorMessage;

//   // 1. Biến lưu danh sách phòng máy
//   List<dynamic> _rooms = [];
//   List<dynamic> get rooms => _rooms;

//   // 2. BIẾN LƯU DANH SÁCH PHIẾU NHẬP
//   List<dynamic> _receipts = [];
//   List<dynamic> get receipts => _receipts;

//   // HÀM LẤY DANH SÁCH PHÒNG TỪ API
//   Future<void> fetchRooms() async {
//     _isLoading = true;
//     notifyListeners(); // Kích hoạt UI hiển thị Vòng xoay

//     try {
//       final response = await ApiService.get('/phong-may');
//       final resData = ApiService.decodeBody(response);
//       if (response.statusCode == 200 && resData != null && resData['success'] == true) {
//         _rooms = resData['data'] ?? [];
//       }
//     } catch (e) {
//       // ĐÃ SỬA: Dùng debugPrint thay cho print để tuân thủ rule của Flutter Linter
//       debugPrint('Lỗi gọi API danh sách phòng: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners(); // Tắt vòng xoay
//     }
//   }

//   // HÀM TẠO PHIẾU NHẬP VÀ BẮT LỖI DATABASE TRÙNG MÁY
//   Future<bool> createImportReceipt(Map<String, dynamic> data) async {
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();

//     try {
//       final response = await ApiService.post('/phieu-nhap-may', data);
//       final resData = ApiService.decodeBody(response);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         _isLoading = false;
//         notifyListeners();
//         return true;
//       } else {
//         // 🚀 CÁCH XỬ LÝ LỖI TRÙNG TÊN MÁY TỪ BACKEND DỘI VỀ
//         String errorMsg = resData?['message']?.toString() ?? '';

//         if (errorMsg.contains('may_tinh_ma_phong_ten_may_unique') ||
//             errorMsg.contains('Duplicate entry')) {
//           _errorMessage = 'Tên máy bị trùng lặp trong phòng này! Vui lòng đổi tên máy để tránh nhầm lẫn.';
//         } else {
//           _errorMessage = errorMsg.isNotEmpty ? errorMsg : 'Lỗi từ Server (Mã lỗi: ${response.statusCode})';
//         }

//         _isLoading = false;
//         notifyListeners();
//         return false;
//       }
//     } catch (e) {
//       // 🚀 BẮT CẢ LỖI EXCEPTION ĐỂ ĐẢM BẢO APP KHÔNG BAO GIỜ CRASH
//       String errorStr = e.toString();
//       if (errorStr.contains('may_tinh_ma_phong_ten_may_unique') ||
//           errorStr.contains('Duplicate entry')) {
//         _errorMessage = 'Tên máy bị trùng lặp trong phòng này! Vui lòng đổi tên máy để tránh nhầm lẫn.';
//       } else {
//         _errorMessage = 'Lỗi kết nối máy chủ: $errorStr';
//       }

//       _isLoading = false;
//       notifyListeners();
//       return false;
//     }
//   }

//   // HÀM FETCH PHIẾU NHẬP (CÓ IN LOG DEBUG)
//   Future<void> fetchReceipts() async {
//     try {
//       final response = await ApiService.get('/phieu-nhap-may');
//       final resData = ApiService.decodeBody(response);

//       if (response.statusCode == 200 && resData != null && resData['success'] == true) {
//         _receipts = resData['data'] ?? [];
//         // ĐÃ SỬA: Dùng debugPrint thay cho print
//         debugPrint('=== ĐÃ GÁN DỮ LIỆU VÀO _receipts: ${_receipts.length} PHẦN TỬ ===');
//         notifyListeners();
//       } else {
//         debugPrint('=== API TRẢ VỀ LỖI HOẶC RỖNG ===');
//       }
//     } catch (e) {
//       debugPrint('=== LỖI CỰC MẠNH: $e ===');
//     }
//   }

//   List<Map<String, dynamic>> generateSmartMachineList({
//     required String maPhieuNhap,
//     required int soLuong,
//   }) {
//     List<Map<String, dynamic>> listMay = [];

//     for (int i = 1; i <= soLuong; i++) {
//       String stt = i.toString().padLeft(3, '0'); // Ví dụ: 001, 002...

//       listMay.add({
//         'ma_may': 'MT-$maPhieuNhap-$stt',

//         'ten_may': 'Máy $stt ($maPhieuNhap)',

//         'trang_thai': 'active'
//       });
//     }
//     return listMay;
//   }
// }
import 'package:flutter/foundation.dart'; // Dùng debugPrint
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

  // 2. BIẾN LƯU DANH SÁCH PHIẾU NHẬP
  List<dynamic> _receipts = [];
  List<dynamic> get receipts => _receipts;

  // HÀM LẤY DANH SÁCH PHÒNG TỪ API
  Future<void> fetchRooms() async {
    _isLoading = true;
    notifyListeners(); // Kích hoạt UI hiển thị Vòng xoay

    try {
      final response = await ApiService.get('/phong-may');
      final resData = ApiService.decodeBody(response);
      if (response.statusCode == 200 &&
          resData != null &&
          resData['success'] == true) {
        _rooms = resData['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Lỗi gọi API danh sách phòng: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Tắt vòng xoay
    }
  }

  // HÀM TẠO PHIẾU NHẬP VÀ BẮT LỖI DATABASE
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
        // Xử lý lỗi từ Backend dội về
        String errorMsg = resData?['message']?.toString() ?? '';

        if (errorMsg.contains('may_tinh_ma_phong_ten_may_unique') ||
            errorMsg.contains('Duplicate entry')) {
          _errorMessage = 'Lỗi dữ liệu: Tên máy bị trùng lặp trong phòng này!';
        } else {
          _errorMessage = errorMsg.isNotEmpty
              ? errorMsg
              : 'Lỗi từ Server (Mã lỗi: ${response.statusCode})';
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Đảm bảo app không crash khi gặp exception
      debugPrint('🔥 LỖI SẬP MẠNG FLUTTER: $e');
      String errorStr = e.toString();
      if (errorStr.contains('may_tinh_ma_phong_ten_may_unique') ||
          errorStr.contains('Duplicate entry')) {
        _errorMessage = 'Lỗi dữ liệu: Tên máy bị trùng lặp trong phòng này!';
      } else {
        _errorMessage = 'Lỗi kết nối máy chủ: $errorStr';
      }

      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // HÀM FETCH PHIẾU NHẬP
  Future<void> fetchReceipts() async {
    try {
      final response = await ApiService.get('/phieu-nhap-may');
      final resData = ApiService.decodeBody(response);

      if (response.statusCode == 200 &&
          resData != null &&
          resData['success'] == true) {
        _receipts = resData['data'] ?? [];
        debugPrint(
          '=== ĐÃ GÁN DỮ LIỆU VÀO _receipts: ${_receipts.length} PHẦN TỬ ===',
        );
        notifyListeners();
      } else {
        debugPrint('=== API TRẢ VỀ LỖI HOẶC RỖNG ===');
      }
    } catch (e) {
      debugPrint('=== LỖI CỰC MẠNH: $e ===');
    }
  }

  // ====================================================================
  // 🚀 TẠO DANH SÁCH MÁY TÍNH (Để Backend sinh tên/mã máy nhằm tránh xung đột)
  // ====================================================================
  List<Map<String, dynamic>> generateSmartMachineList({required int soLuong}) {
    List<Map<String, dynamic>> listMay = [];

    for (int i = 0; i < soLuong; i++) {
      listMay.add({
        // Để trống tên máy và mã máy, Backend sẽ tự động sinh và nối tiếp
        'ma_may': '',
        'ten_may': '',
        'trang_thai': 'active',
      });
    }
    return listMay;
  }
}
