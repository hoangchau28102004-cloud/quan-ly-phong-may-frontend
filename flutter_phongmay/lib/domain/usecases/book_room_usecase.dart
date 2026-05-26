import 'package:flutter_phongmay/domain/repositories/schedule_repository.dart';

class BookRoomUseCase {
  final ScheduleRepository scheduleRepository;

  BookRoomUseCase(this.scheduleRepository);

  Future<bool> call(String ngayYeuCau, int nguoiDungId, int phongMayId) async {
    if (ngayYeuCau.isEmpty) {
      throw Exception('Ngày yêu cầu không được để trống');
    }
    if (nguoiDungId <= 0 || phongMayId <= 0) {
      throw Exception('Dữ liệu người dùng hoặc phòng không hợp lệ');
    }
    return await scheduleRepository.bookRoom(
      ngayYeuCau,
      nguoiDungId,
      phongMayId,
    );
  }
}
