import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/schedule_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _selectedIndex = 0;
  int _selectedDayIndex = 2; // Mặc định là Thứ 4 (Index 2)
  final List<String> _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    // Gọi API lấy dữ liệu ngay khi vừa mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<LoginViewModel>().currentUser;
      if (user != null) {
        // Sinh viên load lịch theo lopHocId (Giả sử load Tuần 1)
        context.read<ScheduleViewModel>().loadSchedule(1, lopHocId: user.lopHocId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<LoginViewModel>().currentUser;
    final scheduleVM = context.watch<ScheduleViewModel>();

    // LOGIC FILTER TẠI ĐÂY:
    // Lọc danh sách lịch dựa vào thứ. (Index 0 = Thứ 2, Index 1 = Thứ 3,...)
    int thuCanTim = _selectedDayIndex + 2; 
    final todaySchedule = scheduleVM.weekSchedule.where((item) => item.thu == thuCanTim).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- Header Profile ---
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF0B132B), 
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.person_outline, size: 30, color: Colors.black54),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.hoTen ?? 'Sinh viên', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('MSSV: ${user?.taiKhoan ?? "N/A"}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),

            // --- Thanh chọn Thứ ---
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), color: Colors.grey[100],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(_days.length, (index) {
                    bool isSelected = _selectedDayIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0B132B) : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(_days[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // --- Danh sách môn học (Đã Filter) ---
            Expanded(
              child: scheduleVM.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : todaySchedule.isEmpty 
                  ? const Center(child: Text('Hôm nay bạn không có lịch thực hành.', style: TextStyle(fontSize: 16, color: Colors.black54)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: todaySchedule.length,
                      itemBuilder: (context, index) {
                        final item = todaySchedule[index];
                        return _buildStudentClassCard(
                          title: item.tenMon,
                          room: 'Phòng ${item.tenPhong}',
                          time: '${item.gioBatDau} - ${item.gioKetThuc}',
                          instructor: item.tenGiangVien,
                          pcStatus: 'Sẵn sàng', // Tạm thời để mặc định, chức năng quét QR cập nhật sau
                          statusColor: Colors.green,
                          statusBg: Colors.green.shade50,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: kAppBlue, unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Thiết bị'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }

  Widget _buildStudentClassCard({required String title, required String room, required String time, required String instructor, required String pcStatus, required Color statusColor, required Color statusBg}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            _buildInfoRow('Phòng:', room), _buildInfoRow('Thời gian:', time), _buildInfoRow('Giảng viên:', instructor),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 100, child: Text('Tình trạng PC:', style: TextStyle(fontWeight: FontWeight.bold))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)), child: Text(pcStatus, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(children: [SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))), Text(value, style: const TextStyle(color: Colors.black54))]),
    );
  }
}