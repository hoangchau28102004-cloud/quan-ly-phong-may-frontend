import 'package:flutter/material.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleViewModel extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();

  bool isLoading = false;
  List<ScheduleItem> weekSchedule = [];

  // Lấy lịch tuần
  Future<void> loadSchedule(
    int tuanHoc, {
    int? lopHocId,
    int? nguoiDungId,
  }) async {
    isLoading = true;
    notifyListeners();

    weekSchedule = await _service.fetchScheduleList(
      tuanHoc,
      lopHocId: lopHocId,
      nguoiDungId: nguoiDungId,
    );

    isLoading = false;
    notifyListeners();
  }

  // Gửi yêu cầu mượn phòng
  Future<bool> submitRoomBooking(
    String ngayYeuCau,
    int nguoiDungId,
    int phongMayId,
  ) async {
    isLoading = true;
    notifyListeners();

    bool success = await _service.bookRoom(ngayYeuCau, nguoiDungId, phongMayId);

    isLoading = false;
    notifyListeners();
    return success;
  }
}
