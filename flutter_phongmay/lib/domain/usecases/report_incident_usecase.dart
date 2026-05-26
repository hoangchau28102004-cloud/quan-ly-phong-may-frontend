import 'package:flutter_phongmay/domain/repositories/attendance_repository.dart';

class ReportIncidentUseCase {
  final AttendanceRepository attendanceRepository;

  ReportIncidentUseCase(this.attendanceRepository);

  Future<bool> call(int mayTinhId, String moTa) async {
    if (mayTinhId <= 0) {
      throw Exception('ID máy tính không hợp lệ');
    }
    if (moTa.isEmpty) {
      throw Exception('Mô tả sự cố không được để trống');
    }
    return await attendanceRepository.reportIncident(mayTinhId, moTa);
  }
}
