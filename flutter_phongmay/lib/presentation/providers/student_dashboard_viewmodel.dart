import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/schedule_service.dart';
import 'package:flutter_phongmay/data/repositories/attendance_repository_impl.dart';
import 'package:flutter_phongmay/data/models/schedule_model.dart';

class StudentDashboardViewModel extends ChangeNotifier {
  final ScheduleService _scheduleService = ScheduleService();
  final AttendanceRepositoryImpl _attendanceRepo = AttendanceRepositoryImpl();

  bool loading = false;
  List<ScheduleItem> upcoming = [];
  List<dynamic> recentAttendance = [];
  List<dynamic> recentIncidents = [];
  int coursesCount = 0;

  Future<void> loadAll(int? nguoiDungId) async {
    loading = true;
    notifyListeners();
    try {
      // Fetch schedule (use tuanHoc=1 as fallback)
      final schedules = await _scheduleService.fetchScheduleList(
        1,
        nguoiDungId: nguoiDungId,
      );
      // Filter future dates (ngayHoc format yyyy-mm-dd)
      final today = DateTime.now().toIso8601String().split('T').first;
      upcoming = schedules
          .where((s) => s.ngayHoc.isNotEmpty && s.ngayHoc.compareTo(today) >= 0)
          .take(4)
          .toList();

      // Estimate courses count by unique course names in schedules
      final uniqueCourses = <String>{};
      for (var s in schedules) {
        uniqueCourses.add(s.tenMon);
      }
      coursesCount = uniqueCourses.length;

      // Fetch attendance and incidents via repository
      final att = await _attendanceRepo.getAttendanceHistory(nguoiDungId ?? 0);
      final inc = await _attendanceRepo.getIncidentHistory(nguoiDungId ?? 0);
      recentAttendance = att.take(4).toList();
      recentIncidents = inc.take(3).toList();
    } catch (_) {
      // ignore errors for now
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
