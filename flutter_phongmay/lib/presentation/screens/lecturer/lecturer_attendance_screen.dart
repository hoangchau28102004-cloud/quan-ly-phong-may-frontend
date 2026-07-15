import 'package:flutter/material.dart';
// TODO: Sửa lại đường dẫn import ApiService cho khớp với dự án của bác
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
  bool _isLoading = true;
  bool _isLocked = false; // Cờ kiểm tra xem đã chốt điểm danh chưa
  List<dynamic> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendanceList();
  }

  // GỌI API LẤY DANH SÁCH & ĐỒNG BỘ TRẠNG THÁI QUÉT QR
  // 1. ÉP BUỘC khởi tạo là mảng rỗng (tuyệt đối không được để List<dynamic>? _students;)
  Future<void> _fetchAttendanceList() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/attendance/students/${widget.scheduleId}');
      final body = ApiService.decodeBody(res);
      
      if (body != null && body['success'] == true) {
        setState(() {
          // Lấy trạng thái khóa
          _isLocked = body['data']['is_locked'] ?? false;
          
          // 🚀 CHỖ NÀY QUAN TRỌNG: Phải trỏ thêm vào đuôi ['students']
          var listData = body['data']['students'];
          _students = (listData is List) ? listData : []; 
        });
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body?['message'] ?? 'Lỗi tải dữ liệu'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Lỗi tải danh sách: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // GỌI API LƯU ĐIỂM DANH
  Future<void> _saveAttendance() async {
    if (_isLocked) return; // Khóa rồi thì nghỉ lưu

    setState(() => _isLoading = true);
    try {
      final payload = {
        'schedule_id': widget.scheduleId,
        'danh_sach': _students.map((s) => {
          'ma_sinh_vien': s['ma_sinh_vien'],
          'trang_thai': s['trang_thai']
        }).toList()
      };

      final res = await ApiService.post('/attendance/save', payload);
      final body = ApiService.decodeBody(res);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Đã lưu và chốt điểm danh thành công!'), backgroundColor: Colors.green),
          );
          // Cập nhật giao diện thành "Chỉ xem"
          setState(() => _isLocked = true);
        }
      } else {
        throw Exception(body?['message'] ?? 'Lỗi lưu dữ liệu');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thất bại: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Các biến tính toán thống kê tự động
  int get _total => _students.length;
  int get _present => _students.where((s) => s['trang_thai'] == 'present').length;
  int get _absent => _students.where((s) => s['trang_thai'] == 'absent').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Điểm danh sinh viên', style: TextStyle(fontSize: 18)),
                if (_isLocked) 
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('(Đã chốt)', style: TextStyle(fontSize: 14, color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            Text('${widget.tenMon} - ${widget.maLop}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: const Color(0xFF193D87),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : _students.isEmpty 
          ? const Center(
              child: Text(
                'Lớp này hiện chưa có sinh viên.', 
                style: TextStyle(color: Colors.grey, fontSize: 16)
              )
            )
          : Column(
              children: [
                // Thống kê nhanh
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Tổng', '$_total', Colors.blue),
                      _buildStatItem('Có mặt', '$_present', Colors.green),
                      _buildStatItem('Vắng', '$_absent', Colors.red),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Danh sách sinh viên
                Expanded(
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      final isPresent = student['trang_thai'] == 'present';

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
                                    child: Text(
                                      student['ho_ten'][0].toUpperCase(), 
                                      style: const TextStyle(color: Color(0xFF193D87), fontWeight: FontWeight.bold)
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student['ho_ten'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(student['mssv'] ?? 'Không rõ MSSV', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Thanh Segment chọn trạng thái (Đã bỏ nút Trễ)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatusButton(
                                      isSelected: isPresent, 
                                      label: 'Có mặt', 
                                      activeColor: Colors.green,
                                      onTap: () {
                                        if (!_isLocked) setState(() => student['trang_thai'] = 'present');
                                      }
                                    )
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatusButton(
                                      isSelected: !isPresent, 
                                      label: 'Vắng', 
                                      activeColor: Colors.red,
                                      onTap: () {
                                        if (!_isLocked) setState(() => student['trang_thai'] = 'absent');
                                      }
                                    )
                                  ),
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
      // Ẩn nút lưu nếu đang loading hoặc đã bị khóa (Đã chốt)
      bottomNavigationBar: (_isLocked || _isLoading || _students.isEmpty) ? null : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _saveAttendance,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF193D87),
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

  Widget _buildStatusButton({required bool isSelected, required String label, required Color activeColor, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          // Nếu bị khóa mà không được chọn thì làm mờ đi
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.grey.shade100,
          border: Border.all(color: isSelected ? activeColor : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}