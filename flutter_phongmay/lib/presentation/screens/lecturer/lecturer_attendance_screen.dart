import 'package:flutter/material.dart';
import '../../../data/datasources/api_service.dart';

class LecturerAttendanceScreen extends StatefulWidget {
  final String tenMon;
  final String maLop;
  final int scheduleId;

  const LecturerAttendanceScreen({
    Key? key,
    required this.tenMon,
    required this.maLop,
    required this.scheduleId,
  }) : super(key: key);

  @override
  State<LecturerAttendanceScreen> createState() => _LecturerAttendanceScreenState();
}

class _LecturerAttendanceScreenState extends State<LecturerAttendanceScreen> {
  List<dynamic> students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRealStudents();
  }

  // 🚀 Gọi API Lấy danh sách sinh viên thật từ DB
  Future<void> _loadRealStudents() async {
    try {
      final response = await ApiService.get('/attendance/students/${widget.scheduleId}');
      final decoded = ApiService.decodeBody(response);

      if (decoded != null && decoded['success'] == true) {
        if (mounted) {
          setState(() {
            students = decoded['data'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception(decoded?['message'] ?? "Không thể tải danh sách lớp");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _saveAttendance() {
    int present = students.where((s) => s['status'] == 'present').length;
    int late = students.where((s) => s['status'] == 'late').length;
    int absent = students.where((s) => s['status'] == 'absent').length;

    // TODO: Ở bước sau, ta sẽ gọi API POST để lưu data này xuống DB.
    // Hiện tại in thông báo thành công.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã điểm danh! (Có mặt: $present, Trễ: $late, Vắng: $absent)'), 
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // Trở về màn hình lịch
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Điểm danh sinh viên', style: TextStyle(fontSize: 18)),
            Text('${widget.tenMon} - ${widget.maLop}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF193D87),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF193D87)))
        : students.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('Lớp này hiện chưa có sinh viên.', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                ],
              ),
            )
          : Column(
        children: [
          // Thống kê nhanh
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Tổng', students.length.toString(), Colors.blue),
                _buildStatItem('Có mặt', students.where((s) => s['status'] == 'present').length.toString(), Colors.green),
                _buildStatItem('Vắng', students.where((s) => s['status'] == 'absent').length.toString(), Colors.red),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Danh sách sinh viên
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                // Lấy chữ cái đầu tiên của tên làm Avatar
                String avatarLetter = (student['hoTen'] != null && student['hoTen'].isNotEmpty) 
                    ? student['hoTen'][0].toUpperCase() 
                    : 'S';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              child: Text(avatarLetter, style: const TextStyle(color: Color(0xFF193D87), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student['hoTen'] ?? 'Không rõ tên', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(student['maSV'] ?? 'Không rõ mã', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Thanh Segment chọn trạng thái
                        Row(
                          children: [
                            Expanded(child: _buildStatusButton(index, 'present', 'Có mặt', Colors.green)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatusButton(index, 'late', 'Trễ', Colors.orange)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildStatusButton(index, 'absent', 'Vắng', Colors.red)),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            // Nếu đang loading hoặc list rỗng thì vô hiệu hóa nút
            onPressed: (_isLoading || students.isEmpty) ? null : _saveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF193D87),
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('LƯU ĐIỂM DANH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusButton(int index, String statusValue, String label, Color activeColor) {
    bool isSelected = students[index]['status'] == statusValue;
    return InkWell(
      onTap: () {
        setState(() {
          students[index]['status'] = statusValue;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(color: isSelected ? activeColor : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}