import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

const Color kAppGreen = Color(0xFF2E7D32);

class ReturnMachineHistoryScreen extends StatefulWidget {
  const ReturnMachineHistoryScreen({super.key});

  @override
  State<ReturnMachineHistoryScreen> createState() =>
      _ReturnMachineHistoryScreenState();
}

class _ReturnMachineHistoryScreenState
    extends State<ReturnMachineHistoryScreen> {
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
          '/tra-thiet-bi/history?nguoi_dung_id=${user.id}',
        );
        if (res.statusCode == 200) {
          final body = ApiService.decodeBody(res);
          if (body != null && body['success'] == true) {
            _history = List<dynamic>.from(body['data'] ?? []);
          }
        }
      } catch (e) {
        debugPrint('Lỗi tải lịch sử trả máy: $e');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _cancelRequest(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy yêu cầu trả máy này không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hủy yêu cầu',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.delete('/tra-thiet-bi/$id');
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hủy phiếu trả thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchData();
      } else {
        throw Exception('Lỗi Server');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể hủy phiếu này!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayHistory = _history;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Lịch Sử Trả Thiết Bị',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppGreen,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAppGreen))
          : _history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) =>
                  _buildHistoryCard(_history[index]),
            ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    String ngayTra = item['thoi_gian_tra'] != null
        ? DateFormat(
            'dd/MM/yyyy HH:mm',
          ).format(DateTime.parse(item['thoi_gian_tra']).toLocal())
        : 'Không rõ';

    // Dữ liệu từ database trả về là 'pending' hoặc 'confirmed'
    String status = (item['trang_thai'] ?? 'pending').toString().toLowerCase();
    bool canCancel = status == 'pending'; // Chỉ cho phép hủy nếu là 'pending'

    // --- SỬA CHỖ NÀY ĐỂ HIỂN THỊ TIẾNG VIỆT ---
    Color statusColor = canCancel ? Colors.orange : Colors.green;
    String statusText = canCancel ? 'Chờ duyệt' : 'Đã duyệt';

    int itemId = item['id'] is int
        ? item['id']
        : int.tryParse(item['id'].toString()) ?? 0;

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
                    'Mã: ${item['ma_phieu_tra'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kAppGreen,
                    ),
                  ),
                ),
                Text(
                  statusText, // Gắn biến tiếng Việt vào đây
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.calendar_today, 'Ngày trả:', ngayTra),
            _buildInfoRow(
              Icons.receipt_long,
              'Phiếu mượn:',
              item['ma_phieu_muon_goc']?.toString() ?? 'Trả tự do',
            ),
            _buildInfoRow(
              Icons.devices,
              'Số lượng:',
              '${item['so_luong']} thiết bị',
            ),
            _buildInfoRow(
              Icons.note,
              'Ghi chú:',
              item['ghi_chu']?.toString().isNotEmpty == true
                  ? item['ghi_chu']
                  : 'Không có',
            ),

            // NÚT HỦY
            if (canCancel) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                  label: const Text(
                    'Hủy yêu cầu',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () => _cancelRequest(itemId),
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
            width: 100,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Bạn chưa có phiếu trả thiết bị nào.',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
