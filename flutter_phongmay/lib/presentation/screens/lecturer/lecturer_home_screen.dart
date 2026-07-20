import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/notification_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/room_booking_screen.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/lecturer_profile_screen.dart';
import 'package:flutter_phongmay/presentation/screens/shared/notification_screen.dart';
import 'package:intl/intl.dart';
import 'lecturer_qr_scanner_screen.dart';
// 🚀 QUAN TRỌNG: Thêm import màn hình Điểm danh để khi bấm "Xem lịch sử" nó biết đường chạy qua
import 'lecturer_attendance_screen.dart';

const Color kAppBlue = Color(0xFF193D87);

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  int _selectedIndex = 0;
  int _selectedDayIndex = 0;
  final List<String> _days = [
    'Tất cả',
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginViewModel>().currentUser;
      if (user != null) {
        context.read<ScheduleViewModel>().loadSchedule(
          nguoiDungId: user.id,
          currentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
        context.read<NotificationViewModel>().loadNotifications(user.id);
      }
    });
  }

  void _onBottomNavTapped(int index) {
    // Make bottom navigation behave like tabs (no push/pop). This mirrors StudentLayout behavior.
    setState(() => _selectedIndex = index);
  }

  Widget _buildNotificationNavIcon(BuildContext context, bool active) {
    final unreadCount = context.watch<NotificationViewModel>().unreadCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.notifications : Icons.notifications_none_outlined),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<LoginViewModel>().currentUser;
    final scheduleVM = context.watch<ScheduleViewModel>();

    final filteredSchedule = _selectedDayIndex == 0
        ? scheduleVM.weekSchedule
        : scheduleVM.weekSchedule
              .where((item) => item.thu == _selectedDayIndex + 1)
              .toList();

    Widget bodyContent;

    // Decide which screen to show based on selected bottom tab
    if (_selectedIndex == 0) {
      bodyContent = SafeArea(
        top: false,
        child: Column(
          children: [
            // --- HEADER THÔNG TIN GIẢNG VIÊN ---
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: kAppBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.person, size: 35, color: kAppBlue),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.hoTen ?? 'Giảng viên',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? 'Chưa cập nhật email',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- THANH CHỌN THỨ TRONG TUẦN ---
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedDayIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kAppBlue : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: kAppBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          _days[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- DANH SÁCH LỊCH DẠY THEO THỨ ---
            Expanded(
              child: scheduleVM.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kAppBlue),
                    )
                  : filteredSchedule.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedDayIndex == 0
                                ? 'Thầy/Cô chưa có lịch dạy trong tuần này'
                                : 'Thầy/Cô không có lịch dạy vào ${_days[_selectedDayIndex]}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredSchedule.length,
                      itemBuilder: (context, index) {
                        return _buildTeacherClassCard(filteredSchedule[index]);
                      },
                    ),
            ),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      bodyContent = const RoomBookingScreen();
    } else if (_selectedIndex == 2) {
      bodyContent = const NotificationScreen();
    } else {
      bodyContent = const TeacherProfileScreen();
    }

    final unreadCount = context.watch<NotificationViewModel>().unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: kAppBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Lịch dạy',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Mượn phòng',
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationNavIcon(context, false),
            activeIcon: _buildNotificationNavIcon(context, true),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD HIỂN THỊ LỚP HỌC CHI TIẾT ---
  Widget _buildTeacherClassCard(item) {
    String thuStr = item.thu == 8 ? 'Chủ Nhật' : 'Thứ ${item.thu}';
    int tietBatDau =
        int.tryParse(item.gioBatDau.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;

    String caHoc = 'Sáng';
    Color badgeColor = Colors.green;

    if (tietBatDau >= 11) {
      caHoc = 'Tối';
      badgeColor = Colors.indigo;
    } else if (tietBatDau >= 6) {
      caHoc = 'Chiều';
      badgeColor = Colors.orange;
    }

    // 🚀 LÔ-GIC XỬ LÝ 3 MỐC THỜI GIAN
    final apiDate = DateTime.tryParse(item.ngayHoc) ?? DateTime.now();
    final scheduleDate = DateTime(apiDate.year, apiDate.month, apiDate.day);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isFuture = scheduleDate.isAfter(today);
    final isPast = scheduleDate.isBefore(today);
    final isToday = scheduleDate.isAtSameMomentAs(today);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _showClassDetails(context, item, thuStr, caHoc, badgeColor);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.tenMon,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAppBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ca $caHoc',
                      style: TextStyle(
                        color: badgeColor.withOpacity(0.9),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(Icons.room, 'Phòng:', item.tenPhong),
              _buildInfoRow(Icons.groups, 'Lớp:', item.maLop),
              _buildInfoRow(
                Icons.access_time,
                'Thời gian:',
                '${item.gioBatDau} - ${item.gioKetThuc}',
              ),
              _buildInfoRow(
                Icons.date_range,
                'Ngày:',
                '${item.ngayHoc} ($thuStr)',
              ),
              const SizedBox(height: 16),

              // 🚀 NÚT ĐIỂM DANH THÔNG MINH
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: isFuture
                      ? null // Tương lai: KHÓA NÚT
                      : () {
                          if (isToday) {
                            // Hôm nay: Chuyển sang màn hình Quét QR
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LecturerQRScannerScreen(
                                  tenMon: item.tenMon,
                                  maLop: item.maLop,
                                  scheduleId: item.id ?? 0,
                                  expectedRoomName: item.tenPhong,
                                ),
                              ),
                            );
                          } else if (isPast) {
                            // Quá khứ: Đi thẳng vào màn điểm danh để xem lịch sử
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LecturerAttendanceScreen(
                                  tenMon: item.tenMon,
                                  maLop: item.maLop,
                                  scheduleId: item.id ?? 0,
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPast ? Colors.teal.shade600 : kAppBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isFuture
                        ? 'Chưa đến thời gian'
                        : (isToday
                              ? 'Điểm Danh Sinh Viên'
                              : 'Xem lịch sử điểm danh'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassDetails(
    BuildContext context,
    dynamic item,
    String thuStr,
    String caHoc,
    Color badgeColor,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chi Tiết Lớp Học',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kAppBlue,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.book, 'Môn học:', item.tenMon),
              _buildDetailRow(Icons.room, 'Phòng máy:', item.tenPhong),
              _buildDetailRow(Icons.groups, 'Lớp học:', item.maLop),
              _buildDetailRow(
                Icons.wb_sunny,
                'Ca học:',
                'Ca $caHoc',
                valueColor: badgeColor,
              ),
              _buildDetailRow(
                Icons.access_time,
                'Thời gian:',
                '${item.gioBatDau} - ${item.gioKetThuc}',
              ),
              _buildDetailRow(
                Icons.date_range,
                'Ngày dạy:',
                '${item.ngayHoc} ($thuStr)',
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
