import 'package:flutter_phongmay/domain/repositories/schedule_repository.dart';

class BookRoomUseCase {
  final ScheduleRepository scheduleRepository;

  BookRoomUseCase(this.scheduleRepository);

  Future<bool> call(
    String ngayYeuCau, 
    int nguoiDungId, 
    int phongMayId,
    String maCa,
    int tietBatDau,
    int tietKetThuc,
    String mucDich,
  ) async {
    if (ngayYeuCau.isEmpty) {
      throw Exception('Ngày yêu cầu không được để trống');
    }
    if (nguoiDungId <= 0 || phongMayId <= 0) {
      throw Exception('Dữ liệu người dùng hoặc phòng không hợp lệ');
    }
    if (tietBatDau > tietKetThuc) {
      throw Exception('Tiết bắt đầu không được lớn hơn tiết kết thúc');
    }
    
    return await scheduleRepository.bookRoom(
      ngayYeuCau,
      nguoiDungId,
      phongMayId,
      maCa,
      tietBatDau,
      tietKetThuc,
      mucDich,
    );
  }
} 