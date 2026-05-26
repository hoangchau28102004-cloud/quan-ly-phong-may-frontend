import 'package:flutter_phongmay/domain/repositories/attendance_repository.dart';

class RecordAttendanceUseCase {
  final AttendanceRepository attendanceRepository;

  RecordAttendanceUseCase(this.attendanceRepository);

  Future<bool> call(int mayTinhId, String ttDiemDanh, String ttMayTinh) async {
    if (mayTinhId <= 0) {
      throw Exception('ID máy tính không hợp lệ');
    }
    if (ttDiemDanh.isEmpty || ttMayTinh.isEmpty) {
      throw Exception('Trạng thái điểm danh hoặc máy tính không được để trống');
    }
    return await attendanceRepository.recordAttendance(
      mayTinhId,
      ttDiemDanh,
      ttMayTinh,
    );
  }
}
