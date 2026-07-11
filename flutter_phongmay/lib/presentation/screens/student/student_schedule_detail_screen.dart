import 'package:flutter/material.dart';
import '../../../data/datasources/api_service.dart';
import 'student_qr_scanner_screen.dart';

class StudentScheduleDetailScreen extends StatefulWidget {
  final int scheduleId;

  const StudentScheduleDetailScreen({super.key, required this.scheduleId});

  @override
  State<StudentScheduleDetailScreen> createState() => _StudentScheduleDetailScreenState();
}

class _StudentScheduleDetailScreenState extends State<StudentScheduleDetailScreen> {
  Map<String, dynamic>? detailData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final response = await ApiService.get('/schedule/details/${widget.scheduleId}');
      final decoded = ApiService.decodeBody(response);
      
      if (decoded != null && decoded['success'] == true) {
        setState(() {
          detailData = decoded['data'];
        });
      } else {
        // Bắt lỗi khi Backend trả về false
        final msg = decoded?['message'] ?? 'Không tìm thấy dữ liệu từ Server';
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thất bại: $msg'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi kết nối: $e'), backgroundColor: Colors.red));
    } finally {
      // 🚀 BÍ QUYẾT Ở ĐÂY: Dù thành công hay thất bại, LUÔN LUÔN tắt vòng xoay loading
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Chi tiết buổi thực hành', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1E3A8A), // Màu xanh Navy chuẩn app bạn
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : detailData == null
              ? const Center(child: Text('Không tải được dữ liệu'))
              : _buildStudentView(),
      // Nút điểm danh cố định dưới cùng cho sinh viên
      bottomNavigationBar: detailData != null ? _buildBottomButton() : null,
    );
  }

  Widget _buildStudentView() {
    final siSo = detailData!['si_so_thuc_te'] ?? 0;
    final soMay = detailData!['so_may_tinh'] ?? 0;
    final isShortage = soMay < siSo; // Cảnh báo thiếu máy

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Thẻ thông tin Môn học
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 1)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        detailData!['ma_lop_hoc_phan'] ?? 'N/A',
                        style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Sắp diễn ra', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  detailData!['ten_mon'] ?? 'Đang cập nhật...',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                _buildInfoRow(Icons.room, 'Phòng máy', detailData!['ten_phong'] ?? 'N/A'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time_filled, 'Thời gian', '${detailData!['ngay_hoc_cu_the']} • Tiết ${detailData!['so_tiet_bat_dau']} - ${detailData!['so_tiet_ket_thuc']}'),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.person, 'Giảng viên', detailData!['ten_giang_vien'] ?? 'Đang cập nhật'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          const Text('TÌNH TRẠNG PHÒNG MÁY', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),

          // 2. Thống kê Sĩ số vs Số máy
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Sĩ số lớp',
                  value: '$siSo',
                  icon: Icons.groups_rounded,
                  color: Colors.blue.shade700,
                  bgColor: Colors.blue.shade50,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Số máy hoạt động',
                  value: '$soMay',
                  icon: Icons.computer,
                  color: isShortage ? Colors.red.shade700 : Colors.green.shade700,
                  bgColor: isShortage ? Colors.red.shade50 : Colors.green.shade50,
                ),
              ),
            ],
          ),
          
          // Cảnh báo nếu thiếu máy
          if (isShortage) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chú ý: Phòng hiện chỉ có $soMay máy hoạt động. Bạn nên đến sớm để chọn máy tốt nhé!',
                      style: TextStyle(color: Colors.red.shade800, fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$label: ',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              children: [
                TextSpan(text: value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // Nút Điểm danh máy chuẩn góc dưới màn hình
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StudentQRScannerScreen(scheduleId: widget.scheduleId),
              ),
            );
          },
          icon: const Icon(Icons.qr_code_scanner, size: 24),
          label: const Text('ĐIỂM DANH MÁY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A), // Màu xanh Navy
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}