import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:intl/intl.dart';
import '../../providers/student_dashboard_viewmodel.dart';
import '../../providers/login_viewmodel.dart'; 
import 'student_qr_scanner_screen.dart';
// 🚀 ĐÃ THÊM: Import màn hình chi tiết lịch học của sinh viên
import 'student_schedule_detail_screen.dart'; 

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({Key? key}) : super(key: key);

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginVm = context.read<LoginViewModel>();
      final userId = loginVm.currentUser?.id;
      final token = loginVm.token ?? '';
      if (userId != null) {
        context.read<StudentDashboardViewModel>().fetchStudentSchedules(userId, token);
      } else {
        debugPrint("Chưa lấy được ID Sinh viên!");
      }
    });
  }

  // Helper hàm đổi số "thu" từ API thành chuỗi hiển thị Tiếng Việt
  String _formatThu(dynamic thu) {
    if (thu == 8) return 'Chủ Nhật';
    if (thu != null) return 'Thứ $thu';
    return 'Chưa rõ thứ';
  }

  // Helper định dạng ngày hiển thị dd/MM/yyyy cho dễ nhìn
  String _formatNgayHoc(String? ngayHocRaw) {
    if (ngayHocRaw == null || ngayHocRaw.isEmpty) return 'Chưa xếp ngày';
    try {
      final parsedDate = DateTime.parse(ngayHocRaw);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return ngayHocRaw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();
    final loginVm = context.watch<LoginViewModel>();
    final userName = loginVm.currentUser?.hoTen ?? 'Sinh viên';
    final userEmail = loginVm.currentUser?.email ?? 'sv@caothang.edu.vn';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (viewModel.filteredSchedules.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không có buổi học nào kích hoạt để điểm danh!')),
            );
            return;
          }
          final currentScheduleId = viewModel.filteredSchedules.first['id'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentQRScannerScreen(scheduleId: currentScheduleId),
            ),
          );
        },
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Điểm danh máy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildTopBanner(userName, userEmail),
          _buildHorizontalCalendar(viewModel),
          Expanded(
            child: viewModel.isLoadingSchedule
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
                : _buildScheduleList(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner(String name, String email) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF1E3A8A),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCalendar(StudentDashboardViewModel viewModel) {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 15, bottom: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.days.length,
        itemBuilder: (context, index) {
          bool isSelected = viewModel.selectedDayIndex == index;
          return Padding(
            key: ValueKey(index),
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(viewModel.days[index]),
              selected: isSelected,
              selectedColor: const Color(0xFF1E3A8A),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300),
              ),
              onSelected: (_) => viewModel.changeSelectedDay(index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(StudentDashboardViewModel viewModel) {
    if (viewModel.filteredSchedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Hôm nay bạn không có lịch thực hành nào', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.filteredSchedules.length,
      itemBuilder: (context, index) {
        final item = viewModel.filteredSchedules[index];
        bool isDone = item['trang_thai'] == 'completed';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            // 🚀 ĐÃ FIX: Chuyển hướng sang màn hình Chi tiết lịch thực hành của sinh viên
            onTap: () {
              if (item['id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentScheduleDetailScreen(scheduleId: item['id']),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDone ? Colors.grey.shade100 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['loai_lich'] ?? 'Thực hành',
                          style: TextStyle(color: isDone ? Colors.grey : const Color(0xFF1E3A8A), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        isDone ? 'Đã học xong' : 'Lịch sắp tới',
                        style: TextStyle(color: isDone ? Colors.grey : Colors.orange.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${item['ten_mon'] ?? 'Môn học'} - ${item['ma_lhp_str'] ?? ''}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 12),
                  _buildCardRow(Icons.pin_drop_outlined, item['ten_phong'] ?? 'Chưa xếp phòng'),
                  const SizedBox(height: 6),
                  // 🚀 ĐÃ FIX KEY JSON: Map chuẩn xác theo 'thu', 'ngay_hoc', 'tiet_bat_dau', 'tiet_ket_thuc' từ API
                  _buildCardRow(
                    Icons.schedule_outlined, 
                    '${_formatThu(item['thu'])} (${_formatNgayHoc(item['ngay_hoc'])}) • Tiết ${item['tiet_bat_dau'] ?? '?'} - ${item['tiet_ket_thuc'] ?? '?'}',
                  ),
                  const SizedBox(height: 6),
                  _buildCardRow(Icons.account_box_outlined, item['ten_giang_vien'] ?? 'Đang cập nhật'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value, 
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}