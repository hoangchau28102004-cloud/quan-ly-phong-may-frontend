import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class StudentDashboardViewModel extends ChangeNotifier {
  // STATE TỔNG QUAN
  bool _loading = false;
  int _coursesCount = 0;
  List<dynamic> _upcoming = [];
  List<dynamic> _recentAttendance = [];
  List<dynamic> _recentIncidents = [];

  bool get loading => _loading;
  int get coursesCount => _coursesCount;
  List<dynamic> get upcoming => _upcoming;
  List<dynamic> get recentAttendance => _recentAttendance;
  List<dynamic> get recentIncidents => _recentIncidents;

  // STATE LỊCH HỌC
  List<dynamic> _schedules = [];
  List<dynamic> _filteredSchedules = [];
  bool _isLoadingSchedule = false;
  int _selectedDayIndex = 0;

  List<dynamic> get filteredSchedules => _filteredSchedules;
  bool get isLoadingSchedule => _isLoadingSchedule;
  int get selectedDayIndex => _selectedDayIndex;
  bool _isSubmittingAttendance = false;
  bool get isSubmittingAttendance => _isSubmittingAttendance;

  final List<String> days = [
    'Tất cả',
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'CN',
  ];

  // 1. TẢI DATA TRANG CHỦ
  Future<void> loadAll(int userId, String token) async {
    _loading = true; // Vẫn dùng biến cũ có dấu gạch dưới
    notifyListeners();

    bool loadedFromDashboardApi = false;

    try {
      final response = await ApiService.get('/student-dashboard/$userId');
      final decoded = ApiService.decodeBody(response);

      if (response.statusCode == 200 &&
          decoded != null &&
          decoded['data'] != null) {
        final data = decoded['data'];

        _coursesCount = data['coursesCount'] ?? 0;
        _upcoming = data['upcoming'] != null
            ? List<dynamic>.from(data['upcoming'])
            : [];
        _recentAttendance = data['recentAttendance'] != null
            ? List<dynamic>.from(data['recentAttendance'])
            : [];
        _recentIncidents = data['recentIncidents'] != null
            ? List<dynamic>.from(data['recentIncidents'])
            : [];

        loadedFromDashboardApi = true;
        debugPrint('✅ student-dashboard API OK: $_coursesCount');
      } else {
        debugPrint(
          '❌ student-dashboard API trả về: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("❌ student-dashboard API lỗi: $e");
    }

    if (!loadedFromDashboardApi || _upcoming.isEmpty) {
      debugPrint(
        '⚠️ Fallback sang /schedule/student vì student-dashboard không có dữ liệu valid.',
      );
      final schedules = await fetchStudentSchedules(userId, token);
      if (schedules.isNotEmpty) {
        _upcoming = schedules;
        if (_coursesCount == 0) {
          _coursesCount = schedules.length;
        }
      }
    }

    _loading = false;
    notifyListeners();
  }

  // 2. TẢI LỊCH HỌC
  Future<List<dynamic>> fetchStudentSchedules(int userId, String token) async {
    _isLoadingSchedule = true;
    notifyListeners();

    try {
      final response = await ApiService.get(
        '/schedule/student?ma_nguoi_dung=$userId',
      );
      final decoded = ApiService.decodeBody(response);

      if (response.statusCode == 200 && decoded != null) {
        final data = decoded['data'];
        _schedules = data is List ? data : [];
        _filterSchedulesByDay();
        return _schedules;
      } else {
        debugPrint(
          '❌ Server trả về lịch học: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch học: $e");
    } finally {
      _isLoadingSchedule = false;
      notifyListeners();
    }

    return [];
  }

  void changeSelectedDay(int index) {
    _selectedDayIndex = index;
    _filterSchedulesByDay();
  }

  void _filterSchedulesByDay() {
    if (_selectedDayIndex == 0) {
      _filteredSchedules = List.from(_schedules);
    } else {
      String targetDay = days[_selectedDayIndex];
      _filteredSchedules = _schedules
          .where(
            (item) =>
                item['thu_trong_tuan'].toString().trim().toLowerCase() ==
                targetDay.trim().toLowerCase(),
          )
          .toList();
    }
    notifyListeners();
  }

  // 🚀 3. ĐIỂM DANH QUÉT QR (REAL API)
  Future<Map<String, dynamic>> checkInWithQRCode(
    String machineQrCode,
    int scheduleId,
    int userId,
    String token,
  ) async {
    _isSubmittingAttendance = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/attendance/check-in-qr', {
        'scheduleId': scheduleId,
        'qrCode': machineQrCode,
        'userId': userId,
      });

      return jsonDecode(response.body);
    } catch (e) {
      debugPrint("Lỗi call API điểm danh: $e");
      return {
        'success': false,
        'message': 'Lỗi kết nối hệ thống. Vui lòng thử lại!',
      };
    } finally {
      _isSubmittingAttendance = false;
      notifyListeners();
    }
  }

  // 3. GỬI BÁO CÁO SỰ CỐ
  Future<bool> submitIncidentReport(
    int userId, // Bắt buộc phải truyền ID của sinh viên (VD: Châu có ID là 37)
    int machineId,
    String issueType,
    String title,
    String description,
    String token,
  ) async {
    try {
      final response = await ApiService.post('/issues/report', {
        'ma_nguoi_bao_cao': userId,
        'ma_may_tinh': machineId,
        'loai_su_co': issueType,
        'tieu_de': title,
        'mo_ta': description,
        'muc_do': 'normal',
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        debugPrint(
          '❌ Backend từ chối: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Lỗi sập hàm call API: $e");
      return false;
    }
  }
}
