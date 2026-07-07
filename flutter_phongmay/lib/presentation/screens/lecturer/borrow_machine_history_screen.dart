import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class BorrowMachineHistoryScreen extends StatefulWidget {
  const BorrowMachineHistoryScreen({super.key});

  @override
  State<BorrowMachineHistoryScreen> createState() =>
      _BorrowMachineHistoryScreenState();
}

class _BorrowMachineHistoryScreenState
    extends State<BorrowMachineHistoryScreen> {
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
        final res = await ApiService.get(
          '/borrow-machine/history?nguoi_dung_id=${user.id}',
        );
        if (res.statusCode == 200) {
          final body = ApiService.decodeBody(res);
          if (body != null && body['success'] == true) {
            _history = List<dynamic>.from(body['data'] ?? []);
          }
        }
      } catch (e) {
        debugPrint('Lỗi tải lịch sử mượn máy: $e');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Bảng hỏi xác nhận Hủy
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Xác nhận hủy',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn hủy bỏ yêu cầu mượn thiết bị này không?',
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
              _deleteRequest(id);
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

  // Gọi API Xóa
  Future<void> _deleteRequest(int id) async {
    final res = await ApiService.delete('/borrow-machine/$id');
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã hủy yêu cầu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchData();
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
          'Lịch Sử Mượn Thiết Bị',
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
                    'Bạn chưa có yêu cầu mượn máy nào.',
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
    String status = item['trang_thai'] ?? 'Chờ duyệt';
    Color statusColor;

    if (status == 'Đã duyệt') {
      statusColor = Colors.green;
    } else if (status == 'Từ chối') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    String ngayMuon = item['ngay_muon'] != null
        ? DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(DateTime.parse(item['ngay_muon']).toLocal())
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
                    'Mã phiếu: ${item['ma_phieu_muon'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
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
                    status,
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
            _buildInfoRow(Icons.calendar_today, 'Ngày gửi:', ngayMuon),
            _buildInfoRow(
              Icons.devices,
              'Số lượng:',
              '${item['so_luong']} thiết bị',
            ),
            _buildInfoRow(
              Icons.help_outline,
              'Lý do:',
              item['ly_do_muon'] ?? 'Không có',
            ),

            // CHỈ HIỂN THỊ NÚT HỦY KHI ĐANG CHỜ DUYỆT
            if (status == 'Chờ duyệt') ...[
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
                    'Hủy yêu cầu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
