// File: lib/features/student/student_home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/schedule_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../scanner/scan_action_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final Color primaryNavy = const Color(0xFF1D357A);
  bool _isLoading = true;
  List<dynamic> _schedules = [];
  String _selectedDay = 'Thứ 4'; // Mặc định hiển thị ngày hiện tại

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  /// Lấy danh sách lịch thực hành theo ngày (query `thu`).
  /// Endpoint: GET /lich-phong-may?thu=...
  /// Kết quả được gán vào `_schedules` để hiển thị trên giao diện.
  Future<void> _fetchSchedules() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(
        '/lich-phong-may?thu=$_selectedDay',
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _schedules = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Lịch Thực Hành Phòng Máy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryNavy,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: Column(
        children: [
          // Bộ lọc thứ trong tuần vuông vức dạng khối cuộn ngang
          Container(
            height: 60,
            color: primaryNavy,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7']
                  .map((day) {
                    final isSelected = _selectedDay == day;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedDay = day);
                        _fetchSchedules();
                      },
                      child: Container(
                        width: 75,
                        alignment: Alignment.center,
                        color: isSelected ? Colors.white : Colors.transparent,
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected ? primaryNavy : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
          ),

          // Danh sách ca học
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _schedules.isEmpty
                ? const Center(
                    child: Text('Không có ca thực hành vào ngày này'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final item = _schedules[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: ListTile(
                          title: Text(
                            item['ten_mon'] ?? 'Môn thực hành',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              'Phòng: ${item['ten_phong']} | Tiết: ${item['tiet_bat_dau']}-${item['tiet_ket_thuc']}',
                            ),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'detail') {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Chi tiết ca học'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Môn: ${item['ten_mon']}'),
                                        Text('Phòng: ${item['ten_phong']}'),
                                        Text(
                                          'Tiết: ${item['tiet_bat_dau']}-${item['tiet_ket_thuc']}',
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  ),
                                );
                              } else if (value == 'book') {
                                final loginVM = context.read<LoginViewModel>();
                                final scheduleVM = context
                                    .read<ScheduleViewModel>();
                                final user = loginVM.currentUser;

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Vui lòng đăng nhập để mượn phòng',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Cố gắng lấy id phòng nếu API trả về các khóa khác nhau
                                final roomId =
                                    item['phong_may_id'] ??
                                    item['phong_id'] ??
                                    item['phongId'];
                                if (roomId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Không có ID phòng để gửi yêu cầu',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                // Chọn ngày mượn bằng DatePicker
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (picked == null) return;

                                final dateStr = picked.toIso8601String().split(
                                  'T',
                                )[0];
                                final success = await scheduleVM
                                    .submitRoomBooking(
                                      dateStr,
                                      user.id,
                                      roomId,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Yêu cầu mượn phòng gửi thành công'
                                          : 'Gửi yêu cầu thất bại',
                                    ),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'detail',
                                child: Text('Chi tiết'),
                              ),
                              PopupMenuItem(
                                value: 'book',
                                child: Text('Yêu cầu mượn phòng'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // NÚT QUÉT QR NỔI TO VUÔNG VỨC - Điểm bắt đầu quy trình điểm danh
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          backgroundColor: primaryNavy,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          onPressed: () async {
            // Mở trình quét camera (Lấy file từ Tuần 2)
            final navigator = Navigator.of(context);
            final String? qrResult =
                await navigator.pushNamed('/scanner') as String?;
            if (qrResult != null && qrResult.isNotEmpty) {
              // Chuyển tiếp sang xử lý thông tin máy
              if (!mounted) return;
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => ScanActionScreen(qrData: qrResult),
                ),
              );
            }
          },
          child: const Icon(
            Icons.qr_code_scanner,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
