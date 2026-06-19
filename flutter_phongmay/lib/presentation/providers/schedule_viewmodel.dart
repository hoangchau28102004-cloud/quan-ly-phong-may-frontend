import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/models/schedule_model.dart';
import 'package:flutter_phongmay/data/datasources/schedule_service.dart';

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
  // Gửi yêu cầu mượn phòng
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
