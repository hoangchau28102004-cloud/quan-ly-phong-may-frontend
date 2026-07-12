import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Để dùng kIsWeb
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class StudentDashboardViewModel extends ChangeNotifier {
  // Tự động nhận diện nền tảng
  final String _baseUrl = kIsWeb
      ? 'http://127.0.0.1:8001/api'
      : 'http://10.0.2.2:8001/api';

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

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/student-dashboard/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final data = body['data'];

        // Cập nhật vào các biến private cũ của bác
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

        debugPrint('✅ Data OK: $_coursesCount');
      } else {
        debugPrint('❌ Server trả về: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Lỗi: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 2. TẢI LỊCH HỌC
  Future<void> fetchStudentSchedules(int userId, String token) async {
    _isLoadingSchedule = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/schedule/student?ma_nguoi_dung=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
      final response = await http.post(
        Uri.parse('$_baseUrl/attendance/check-in-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'scheduleId': scheduleId,
          'qrCode': machineQrCode,
          'userId': userId,
        }),
      );

      // Trả về nguyên bộ thông điệp của Backend (gồm success, message và data)
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
      String token) async {
    try {
      // 1. Kiểm tra lại URL xem đã đúng /api/issues/report chưa (tùy file route của bác)
      final response = await http.post(
        Uri.parse('$_baseUrl/issues/report'), 
        headers: {
          'Content-Type': 'application/json', 
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          // 2. 🚀 MAP CHUẨN 100% VỚI REQ.BODY CỦA BACKEND
          'ma_nguoi_bao_cao': userId,
          'ma_may_tinh': machineId,
          'loai_su_co': issueType,
          'tieu_de': title,
          'mo_ta': description,
          'muc_do': 'normal', // Mặc định cho sinh viên
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return true; // Thành công mỹ mãn
      } else {
        // 🚀 VŨ KHÍ TỐI THƯỢNG: Bắt Backend phải khai ra nó đang khó chịu cái gì
        debugPrint('❌ Backend từ chối: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      // Bắt các lỗi crash mạng hoặc JSON sai định dạng
      debugPrint("🔥 Lỗi sập hàm call API: $e");
      return false;
    }
  }
}
