import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/domain/entities/attendance_entity.dart';
import 'package:flutter_phongmay/domain/entities/incident_entity.dart';
import 'package:flutter_phongmay/domain/repositories/attendance_repository.dart';
import 'dart:convert';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl();

  @override
  Future<bool> recordAttendance(
    int mayTinhId,
    String ttDiemDanh,
    String ttMayTinh,
  ) async {
    try {
      final response = await ApiService.post('/diem-danh', {
        'may_tinh_id': mayTinhId,
        'tt_diem_danh': ttDiemDanh,
        'tt_may_tinh': ttMayTinh,
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> reportIncident(int mayTinhId, String moTa) async {
    try {
      final response = await ApiService.post('/bao-cao-su-co', {
        'may_tinh_id': mayTinhId,
        'mo_ta': moTa,
        'trang_thai': 'CHO_XU_LY',
      });
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory(int nguoiDungId) async {
    // TODO: Implement getAttendanceHistory
    return [];
  }

  @override
  Future<List<IncidentEntity>> getIncidentHistory(int nguoiDungId) async {
    try {
      final response = await ApiService.get('/bao-cao-su-co/ca-nhan');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> incidents = data['data'] ?? [];
        return incidents.map((incident) {
          return IncidentEntity(
            id: incident['id'] ?? 0,
            moTa: incident['mo_ta'] ?? '',
            trangThai: incident['trang_thai'] ?? 'CHO_XU_LY',
            mayTinhId: incident['may_tinh_id'] ?? 0,
            nguoiDungId: incident['nguoi_dung_id'] ?? 0,
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
