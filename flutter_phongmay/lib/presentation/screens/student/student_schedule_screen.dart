import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/student_dashboard_viewmodel.dart';
import '../../providers/login_viewmodel.dart';
import 'student_schedule_detail_screen.dart';

class StudentScheduleScreen extends StatefulWidget {
  const StudentScheduleScreen({super.key});

  @override
  State<StudentScheduleScreen> createState() => _StudentScheduleScreenState();
}

class _StudentScheduleScreenState extends State<StudentScheduleScreen> {
  int _selectedDayIndex = 0;
  final List<String> _days = [
    'Tất cả',
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'CN',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginVm = context.read<LoginViewModel>();
      final userId = loginVm.currentUser?.id;
      final token = loginVm.token ?? '';
      if (userId != null) {
        context.read<StudentDashboardViewModel>().fetchStudentSchedules(
          userId,
          token,
        );
      }
    });
  }

  String _formatThu(dynamic thu) {
    if (thu?.toString() == '8') return 'Chủ Nhật';
    if (thu != null) return 'Thứ $thu';
    return 'Chưa rõ thứ';
  }

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

    final rawList = viewModel.filteredSchedules;

    final displayList = _selectedDayIndex == 0
        ? rawList
        : rawList.where((item) {
            final String thuStr = item['thu']?.toString() ?? '0';
            final int thuInt = int.tryParse(thuStr) ?? 0;
            return thuInt == (_selectedDayIndex + 1);
          }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          _buildTopBanner(userName, userEmail),
          _buildHorizontalCalendar(),
          Expanded(
            child: viewModel.isLoadingSchedule
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                  )
                : _buildScheduleList(displayList),
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

  Widget _buildHorizontalCalendar() {
    return Container(
      height: 46,
      margin: const EdgeInsets.only(top: 15, bottom: 5),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedDayIndex == index;
          return Padding(
            key: ValueKey(index),
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_days[index]),
              selected: isSelected,
              selectedColor: const Color(0xFF1E3A8A),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : Colors.grey.shade300,
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _selectedDayIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(List<dynamic> displayList) {
    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              _selectedDayIndex == 0
                  ? 'Hiện chưa có lịch thực hành nào'
                  : 'Bạn không có lịch học vào ${_days[_selectedDayIndex]}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];

        // 🚀 1. LÔ-GIC XỬ LÝ BADGE (NHÃN) THEO THỜI GIAN THỰC
        bool isCompleted = item['trang_thai'] == 'completed';
        String statusText = 'Lịch sắp tới';
        Color statusTextColor = Colors.orange.shade700;

        final rawDate = item['ngay_hoc']?.toString() ?? '';
        DateTime? classDate = DateTime.tryParse(rawDate);

        if (isCompleted) {
          statusText = 'Đã học xong';
          statusTextColor = Colors.grey.shade600;
        } else if (classDate != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final cDate = DateTime(
            classDate.year,
            classDate.month,
            classDate.day,
          );

          if (cDate.isBefore(today)) {
            // Lịch cũ (VD: 11/7 mà nay là 12/7) -> Ép thành Đã qua
            statusText = 'Đã qua';
            statusTextColor = Colors.grey.shade600;
          } else if (cDate.isAtSameMomentAs(today)) {
            // Lịch ngày hôm nay
            statusText = 'Hôm nay';
            statusTextColor = Colors.green.shade700;
          }
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (item['id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentScheduleDetailScreen(scheduleId: item['id']),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // Nếu nhãn là xám (Đã qua/Đã xong) thì khung tag cũng mờ đi
                          color: (statusTextColor == Colors.grey.shade600)
                              ? Colors.grey.shade100
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['loai_lich'] ?? 'Thực hành',
                          style: TextStyle(
                            color: (statusTextColor == Colors.grey.shade600)
                                ? Colors.grey.shade600
                                : const Color(0xFF1E3A8A),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // 🚀 2. GẮN NHÃN SAU KHI ĐÃ LỌC LOGIC
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${item['ten_mon'] ?? 'Môn học'} - ${item['ma_lhp_str'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 12),
                  _buildCardRow(
                    Icons.pin_drop_outlined,
                    item['ten_phong'] ?? 'Chưa xếp phòng',
                  ),
                  const SizedBox(height: 6),
                  _buildCardRow(
                    Icons.schedule_outlined,
                    '${_formatThu(item['thu'])} (${_formatNgayHoc(item['ngay_hoc'])}) • Tiết ${item['tiet_bat_dau'] ?? '?'} - ${item['tiet_ket_thuc'] ?? '?'}',
                  ),
                  const SizedBox(height: 6),
                  _buildCardRow(
                    Icons.account_box_outlined,
                    item['ten_giang_vien'] ?? 'Đang cập nhật',
                  ),
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
