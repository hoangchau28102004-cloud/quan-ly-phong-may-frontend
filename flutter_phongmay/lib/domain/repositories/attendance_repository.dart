import 'package:flutter_phongmay/domain/entities/attendance_entity.dart';
import 'package:flutter_phongmay/domain/entities/incident_entity.dart';

abstract class AttendanceRepository {
  Future<bool> recordAttendance(
    int mayTinhId,
    String ttDiemDanh,
    String ttMayTinh,
  );

  Future<bool> reportIncident(int mayTinhId, String moTa);

  Future<List<AttendanceEntity>> getAttendanceHistory(int nguoiDungId);
  Future<List<IncidentEntity>> getIncidentHistory(int nguoiDungId);
}
