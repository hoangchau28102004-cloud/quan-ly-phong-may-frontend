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

  // --- HÀM GỬI YÊU CẦU MƯỢN PHÒNG ---
  Future<bool> submitRoomBooking(
    String ngayYeuCau,
    int nguoiDungId,
    int phongMayId,
    String maCa,
    int tietBatDau,
    int tietKetThuc,
    String mucDich,
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
    );

    isLoading = false;
    notifyListeners();
    return success;
  }
}