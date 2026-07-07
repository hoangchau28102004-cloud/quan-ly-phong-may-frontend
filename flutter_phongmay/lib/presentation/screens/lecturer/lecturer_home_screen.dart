import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/room_booking_screen.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/lecturer_profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/qr_scanner_screen.dart';

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
          currentDate: DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime.now()), // Tự động lấy ngày hôm nay
        );
      }
    });
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
      // VỊ TRÍ SỐ 2: QUÉT QR
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerScreen()),
      );
    } else if (index == 2) {
      // VỊ TRÍ SỐ 3: MƯỢN PHÒNG
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoomBookingScreen()),
      );
    } else if (index == 3) {
      // VỊ TRÍ SỐ 4: CÁ NHÂN
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TeacherProfileScreen()),
      );
    } else {
      // VỊ TRÍ SỐ 1: LỊCH DẠY
      setState(() => _selectedIndex = index);
    }
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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER THÔNG TIN GIẢNG VIÊN ---
            Container(
              padding: const EdgeInsets.all(20),
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
                        final item = filteredSchedule[index];
                        return _buildTeacherClassCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: kAppBlue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          // Index 0: Lịch dạy
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Lịch dạy',
          ),
          // Index 1: Quét QR (Đã thêm vào đây)
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            activeIcon: Icon(Icons.qr_code),
            label: 'Quét QR',
          ),
          // Index 2: Mượn phòng
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Mượn phòng',
          ),
          // Index 3: Cá nhân
          BottomNavigationBarItem(
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip
          .antiAlias, // Cắt viền để hiệu ứng InkWell không tràn ra ngoài góc bo tròn
      child: InkWell(
        onTap: () {
          // Hiển thị Bottom Sheet khi bấm vào Card
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
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAppBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Tính năng điểm danh sinh viên đang phát triển!',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Điểm Danh Sinh Viên',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  // --- HÀM HIỂN THỊ BOTTOM SHEET (CHI TIẾT LỚP HỌC) ---
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
            mainAxisSize: MainAxisSize.min, // Giữ chiều cao vừa đủ cho nội dung
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

  // --- HÀM HELPER ĐỂ VẼ DÒNG THÔNG TIN Ở NGOÀI CARD ---
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

  // --- HÀM HELPER ĐỂ VẼ DÒNG THÔNG TIN Ở TRONG BOTTOM SHEET ---
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
