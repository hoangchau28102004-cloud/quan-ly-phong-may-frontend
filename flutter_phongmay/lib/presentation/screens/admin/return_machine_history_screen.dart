import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/core/constants/status_translations.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

const Color kAppBlue = Color(0xFF193D87);

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
    try {
      final res = await ApiService.get('/borrow-return/tra-may');
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          setState(() {
            _history = List<dynamic>.from(body['data'] ?? []);
          });
        }
      } else {
        // NẾU BACKEND LỖI, BÁO NGAY RA MÀN HÌNH!
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tải dữ liệu: ${res.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải lịch sử trả máy: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _cancelRequest(int id) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng hủy phiếu đang được cập nhật!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Lịch Sử Phiếu Trả Thiết Bị',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAppBlue))
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

    String status = (item['trang_thai'] ?? 'pending').toString().toLowerCase();
    bool canCancel = status == 'pending';

    Color statusColor = canCancel ? Colors.orange : Colors.green;
    String statusText = translateAppStatus(
      status,
      defaultLabel: canCancel ? 'Chờ duyệt' : 'Hoàn thành',
    );

    int itemId = int.tryParse(item['id'].toString()) ?? 0;

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
                    'Mã phiếu: ${item['ma_phieu_tra'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kAppBlue,
                    ),
                  ),
                ),
                Text(
                  statusText,
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
              'Phiếu mượn gốc:',
              item['ma_phieu_muon_goc']?.toString() ?? 'N/A',
            ),
            _buildInfoRow(
              Icons.devices,
              'Số lượng trả:',
              '${item['so_luong']} thiết bị',
            ),
            _buildInfoRow(
              Icons.note,
              'Ghi chú:',
              item['ghi_chu']?.toString().isNotEmpty == true
                  ? item['ghi_chu']
                  : 'Không có',
            ),

            if (canCancel) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 18),
                  label: const Text(
                    'Hủy phiếu',
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
            width: 110,
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
