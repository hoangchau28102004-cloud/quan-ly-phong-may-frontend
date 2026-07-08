import 'package:flutter/material.dart';
import 'lecturer_attendance_screen.dart';
import 'report_issue_screen.dart';

class LecturerMachineDetailScreen extends StatelessWidget {
  final Map<String, dynamic> machineData;
  final String tenMon;
  final String maLop;
  final int scheduleId;

  const LecturerMachineDetailScreen({
    Key? key,
    required this.machineData,
    required this.tenMon,
    required this.maLop,
    required this.scheduleId,
  }) : super(key: key);

  void _goToAttendance(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LecturerAttendanceScreen(
          tenMon: tenMon,
          maLop: maLop,
          scheduleId: scheduleId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Xác nhận thiết bị'),
        backgroundColor: const Color(0xFF193D87),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thẻ hiển thị thông tin máy tính
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.computer, size: 60, color: Color(0xFF193D87)),
                    const SizedBox(height: 16),
                    Text(
                      machineData['ten_may'] ?? 'Máy Giảng Viên',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 30),
                    _buildRow('Mã máy:', machineData['ma_may'] ?? 'Đang cập nhật'),
                    _buildRow('Vị trí:', machineData['ten_phong'] ?? 'Đang cập nhật'),
                    _buildRow('Cấu hình:', '${machineData['bo_xu_ly'] ?? ''} - ${machineData['ram'] ?? ''}'),
                  ],
                ),
              ),
            ),
            
            const Spacer(), 

            // Nút BÁO CÁO SỰ CỐ (Được bọc trong await)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  // Mở màn báo lỗi và chờ Giảng viên thực hiện thao tác
                  await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const ReportIssueScreen())
                  );
                  
                  // Màn hình báo lỗi đóng lại -> Đi tiếp qua điểm danh!
                  if (context.mounted) {
                     _goToAttendance(context); 
                  }
                },
                icon: const Icon(Icons.report_problem, color: Colors.red),
                label: const Text('Báo cáo sự cố / Thiếu thiết bị', style: TextStyle(color: Colors.red, fontSize: 16)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nút BÌNH THƯỜNG (Bấm phát qua điểm danh luôn)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _goToAttendance(context),
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text('Máy tính hoạt động bình thường', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}