import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/models/schedule_model.dart';
import 'package:flutter_phongmay/data/datasources/schedule_service.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  bool isLoading = false;
  List<ScheduleItem> weekSchedule = [];

  // --- CÁC BIẾN LƯU TRỮ LỊCH SỬ VÀ SỐ LƯỢNG BADGE ---
  List<dynamic> bookingHistory = [];
  int pendingCount = 0;
  int approvedCount = 0;
  String errorMessage = '';
  // --- HÀM LẤY LỊCH TUẦN ---
  Future<void> loadSchedule({
    int? tuanHoc,
    int? lopHocId,
    int? nguoiDungId,
    String? currentDate,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      String url = '/schedule/list?';
      if (tuanHoc != null) url += 'tuan_hoc=$tuanHoc&';
      if (lopHocId != null) url += 'lop_hoc_id=$lopHocId&';
      if (nguoiDungId != null) url += 'ma_nguoi_dung=$nguoiDungId&';
      if (currentDate != null) url += 'current_date=$currentDate&';

      final response = await ApiService.get(url);
      if (response.statusCode == 200) {
        final data = ApiService.decodeBody(response);
        if (data != null && data['success'] == true) {
          List listData = data['data'];
          weekSchedule = listData.map((e) => ScheduleItem.fromJson(e)).toList();
        } else {
          weekSchedule = [];
        }
      }
    } catch (e) {
      weekSchedule = [];
      debugPrint('Lỗi loadSchedule: $e');
    }

    isLoading = false;
    notifyListeners();
  }
  //  CHỈ DÀNH RIÊNG CHO SINH VIÊN LOAD LỊCH
  Future<void> loadStudentScheduleOnly() async {
    isLoading = true;
    notifyListeners();

    try {
      // ÉP BUỘC GỌI VÀO ĐÚNG API CỦA SINH VIÊN
      final response = await ApiService.get('/schedule/student');
      
      if (response.statusCode == 200) {
        final data = ApiService.decodeBody(response);
        if (data != null && data['success'] == true) {
          List listData = data['data'];
          weekSchedule = listData.map((e) => ScheduleItem.fromJson(e)).toList();
        } else {
          weekSchedule = [];
        }
      }
    } catch (e) {
      weekSchedule = [];
      debugPrint('Lỗi loadStudentScheduleOnly: $e');
    }

    isLoading = false;
    notifyListeners();
  }
  // --- HÀM LẤY LỊCH SỬ MƯỢN PHÒNG VÀ ĐẾM SỐ LƯỢNG ---
  Future<void> fetchBookingHistory(int nguoiDungId) async {
    try {
      // Gọi API lấy lịch sử theo ID người dùng
      final response = await ApiService.get('/schedule?nguoi_dung_id=$nguoiDungId');
      if (response.statusCode == 200) {
        final data = ApiService.decodeBody(response);
        if (data != null && data['success'] == true) {
          bookingHistory = data['data'] ?? [];
          
          // Lọc và đếm số lượng để hiển thị lên màn hình Profile
          pendingCount = bookingHistory.where((e) => e['trang_thai_duyet'] == 'pending').length;
          approvedCount = bookingHistory.where((e) => e['trang_thai_duyet'] == 'approved').length;
          
          notifyListeners(); // Cập nhật lại giao diện
        }
      }
    } catch (e) {
      debugPrint('Lỗi fetchBookingHistory: $e');
    }
  }
  Future<bool> addOfficialSchedule(Map<String, dynamic> scheduleData) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      // 🚨 Bắn API xuống Backend (Chắc chắn Backend của má phải có route POST /lich-su-dung-phong-may hoặc tương đương)
      // Nếu route Backend tên khác, má tự đổi lại chuỗi '/schedule' cho khớp nha!
      final response = await ApiService.post('/schedule', scheduleData);
      final resData = ApiService.decodeBody(response);

      // 🛑 KIỂM TRA NGHIÊM NGẶT STATUS CODE TỪ BACKEND
      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading = false;
        notifyListeners();
        
        // 🚀 Sau khi thêm thành công, gọi lại hàm loadSchedule để màn hình tự refresh
        // await loadSchedule(...); 
        
        return true; // THÀNH CÔNG THẬT SỰ
      } else {
        // Bắt tận tay câu chửi của MySQL từ Backend dội về
        errorMessage = resData?['message']?.toString() ?? 'Lỗi Database: Thiếu khóa ngoại (Tuần, Lớp, Phòng...) hoặc sai định dạng!';
        debugPrint('❌ [BACKEND CHỬI]: $errorMessage');
        
        isLoading = false;
        notifyListeners();
        return false; // BÁO LỖI ĐỂ UI KHÔNG HIỆN MÀU XANH NỮA
      }
    } catch (e) {
      errorMessage = 'Sập mạng hoặc Exception: $e';
      debugPrint('🔥 [SẬP MẠNG FLUTTER]: $e');
      
      isLoading = false;
      notifyListeners();
      return false; // CÓ LỖI LÀ PHẢI FALSE
    }
  }
  // --- HÀM GỬI YÊU CẦU MƯỢN PHÒNG ---
  Future<bool> submitRoomBooking(
    String ngayYeuCau,
    int nguoiDungId,
    int phongMayId,
    String maCa,
    int tietBatDau,
    int tietKetThuc,
    String mucDich,
    {String trangThai = 'pending'}
  ) async {
    isLoading = true;
    notifyListeners();

    bool success = await _service.bookRoom(
      ngayYeuCau,
      nguoiDungId,
      phongMayId,
      maCa,
      tietBatDau,
      tietKetThuc,
      mucDich,
      trangThai: trangThai,
    );

    isLoading = false;
    notifyListeners();
    return success;
  }
}