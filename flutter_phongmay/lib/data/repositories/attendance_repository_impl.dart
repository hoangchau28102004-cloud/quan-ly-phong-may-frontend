import 'dart:convert';

import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/domain/entities/attendance_entity.dart';
import 'package:flutter_phongmay/domain/entities/incident_entity.dart';
import 'package:flutter_phongmay/domain/repositories/attendance_repository.dart';

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
        'ma_may_tinh': mayTinhId,
        'tt_diem_danh': ttDiemDanh,
        'tt_may_tinh': ttMayTinh,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> reportIncident(int mayTinhId, String moTa) async {
    try {
      final response = await ApiService.post('/bao-cao-su-co', {
        'ma_may_tinh': mayTinhId,
        'mo_ta': moTa,
        'trang_thai': 'CHO_XU_LY',
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<AttendanceEntity>> getAttendanceHistory(int nguoiDungId) async {
    try {
      final response = await ApiService.get('/diem-danh/ca-nhan');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((e) {
          final map = Map<String, dynamic>.from(e);
          return AttendanceEntity(
            id: map['id'] ?? 0,
            ttDiemDanh: map['tt_diem_danh'] ?? '',
            ttMayTinh: map['tt_may_tinh'] ?? '',
            thoiGianDd:
                DateTime.tryParse(map['thoi_gian_dd'] ?? '') ?? DateTime.now(),
            nguoiDungId: map['nguoi_dung_id'] ?? 0,
            lichPhongMayId: map['lich_phong_may_id'] ?? 0,
            mayTinhId: map['ma_may_tinh'] ?? map['may_tinh_id'] ?? 0,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<IncidentEntity>> getIncidentHistory(int nguoiDungId) async {
    try {
      final response = await ApiService.get('/bao-cao-su-co/ca-nhan');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> incidents = data['data'] ?? [];
        return incidents.map((incident) {
          final map = Map<String, dynamic>.from(incident);
          return IncidentEntity(
            id: map['id'] ?? 0,
            moTa: map['mo_ta'] ?? '',
            trangThai: map['trang_thai'] ?? 'CHO_XU_LY',
            mayTinhId: map['ma_may_tinh'] ?? map['may_tinh_id'] ?? 0,
            nguoiDungId: map['nguoi_dung_id'] ?? 0,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
