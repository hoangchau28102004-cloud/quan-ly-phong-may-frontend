import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb

class StudentDashboardViewModel extends ChangeNotifier {
  // Tự động nhận diện nền tảng
  final String _baseUrl = kIsWeb ? 'http://127.0.0.1:8001/api' : 'http://10.0.2.2:8001/api';
  
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

  final List<String> days = ['Tất cả', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'CN'];

  // 1. TẢI DATA TRANG CHỦ
  Future<void> loadAll(int userId, String token) async {
    _loading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/academic/student-dashboard/$userId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        _coursesCount = data['coursesCount'] ?? 0;
        _upcoming = data['upcoming'] ?? [];
        _recentAttendance = data['recentAttendance'] ?? [];
        _recentIncidents = data['recentIncidents'] ?? [];
      }
    } catch (e) {
      debugPrint("Lỗi load Dashboard: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 2. TẢI LỊCH HỌC
  Future<void> fetchStudentSchedules(int userId,String token) async {
    _isLoadingSchedule = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/schedule/student?ma_nguoi_dung=$userId'), 
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _schedules = jsonDecode(response.body)['data'] ?? [];
        _filterSchedulesByDay();
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch học: $e");
    } finally {
      _isLoadingSchedule = false;
      notifyListeners();
    }
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
      _filteredSchedules = _schedules.where((item) => 
        item['thu_trong_tuan'].toString().trim().toLowerCase() == targetDay.trim().toLowerCase()
      ).toList();
    }
    notifyListeners();
  }
  // 🚀 3. ĐIỂM DANH QUÉT QR (REAL API)
 Future<Map<String, dynamic>> checkInWithQRCode(String machineQrCode, int scheduleId, int userId, String token) async {
    _isSubmittingAttendance = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/attendance/check-in-qr'), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({'scheduleId': scheduleId, 'qrCode': machineQrCode, 'userId': userId}),
      );

      // Trả về nguyên bộ thông điệp của Backend (gồm success, message và data)
      return jsonDecode(response.body); 
      
    } catch (e) {
      debugPrint("Lỗi call API điểm danh: $e");
      return {'success': false, 'message': 'Lỗi kết nối hệ thống. Vui lòng thử lại!'};
    } finally {
      _isSubmittingAttendance = false;
      notifyListeners();
    }
  }
  // 3. GỬI BÁO CÁO SỰ CỐ
  Future<bool> submitIncidentReport(String machineId, String issueType, String title, String description, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/maintenance/report'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'machineId': machineId,
          'issueType': issueType,
          'title': title,
          'description': description,
        }),
      );
      final data = jsonDecode(response.body);
      return response.statusCode == 200 && data['success'] == true;
    } catch (e) {
      debugPrint("Lỗi call API Báo cáo sự cố: $e");
      return false;
    }
  }
}

  