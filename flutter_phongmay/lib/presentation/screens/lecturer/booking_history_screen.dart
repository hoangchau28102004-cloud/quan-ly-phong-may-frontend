import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final user = context.read<LoginViewModel>().currentUser;
    if (user != null) {
      try {
        final resHistory = await ApiService.get(
          '/schedule?nguoi_dung_id=${user.id}',
        );
        if (resHistory.statusCode == 200) {
          final bodyHistory = ApiService.decodeBody(resHistory);
          if (bodyHistory != null && bodyHistory['success'] == true) {
            // Gán thẳng danh sách vào _history, load tất cả!
            _history = List<dynamic>.from(bodyHistory['data'] ?? []);
          }
        }
      } catch (e) {
        debugPrint('Lỗi tải lịch sử: $e');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- HÀM XÁC NHẬN HỦY ---
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Xác nhận hủy',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn hủy bỏ yêu cầu mượn phòng này không? Hành động này không thể hoàn tác.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteBooking(id); // Gọi hàm xóa
            },
            child: const Text(
              'Hủy yêu cầu',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM GỌI API HỦY XUỐNG BACKEND ---
  Future<void> _deleteBooking(int id) async {
    final res = await ApiService.delete('/schedule/$id');
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy yêu cầu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchData(); // Tải lại danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể hủy yêu cầu này.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Lịch Sử Mượn Phòng',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAppBlue))
          : _history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có lịch sử mượn phòng nào\nhoặc các lịch cũ đã được ẩn đi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return _buildHistoryCard(item);
              },
            ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    String status = item['trang_thai_duyet'] ?? 'pending';
    Color statusColor;
    String statusText;

    if (status == 'approved') {
      statusColor = Colors.green;
      statusText = 'Đã duyệt';
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusText = 'Từ chối';
    } else {
      statusColor = Colors.orange;
      statusText = 'Chờ duyệt';
    }

    // Format ngày hiển thị
    String ngayDat = item['ngay_dat'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(item['ngay_dat']))
        : 'Đang cập nhật';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
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
                    'Phòng: ${item['ten_phong'] ?? 'Chưa rõ'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kAppBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.calendar_today, 'Ngày mượn:', ngayDat),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian:',
              'Ca ${item['ma_ca']} (Tiết ${item['tiet_bat_dau']} - ${item['tiet_ket_thuc']})',
            ),
            _buildInfoRow(
              Icons.info_outline,
              'Mục đích:',
              item['muc_dich'] ?? 'Không có',
            ),

            // CHỈ HIỂN THỊ NÚT HỦY KHI TRẠNG THÁI LÀ PENDING
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmDelete(item['id']),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Hủy yêu cầu mượn phòng',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 85,
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
}
