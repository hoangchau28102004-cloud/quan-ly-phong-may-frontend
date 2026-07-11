import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MaintenanceLogTab extends StatefulWidget {
  final List<dynamic> logs; // Nhận data real từ màn hình chính
  final List<dynamic> tickets; 
  final VoidCallback reloadCallback; 

  const MaintenanceLogTab({
    super.key,
    required this.logs,
    required this.tickets,
    required this.reloadCallback,
  });

  @override
  State<MaintenanceLogTab> createState() => _MaintenanceLogTabState();
}

class _MaintenanceLogTabState extends State<MaintenanceLogTab> {
  final Color primaryNavy = const Color(0xFF193D87);

  // Parse thời gian chuẩn
  String _formatDate(dynamic dateString) {
    if (dateString == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateString.toString()).toLocal();
      return DateFormat('HH:mm dd/MM/yyyy').format(dt);
    } catch (e) {
      return dateString.toString();
    }
  }

  // Parse chi phí
  String _formatCost(dynamic cost) {
    if (cost == null) return '0';
    final parsed = double.tryParse(cost.toString()) ?? 0.0;
    return NumberFormat.currency(locale: 'vi', symbol: '').format(parsed).trim();
  }

  @override
  Widget build(BuildContext context) {
    // Đảm bảo không bị null list
    final safeLogs = widget.logs;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: safeLogs.isEmpty
          ? Center(
              child: Text(
                'Chưa có nhật ký sửa chữa nào.',
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: safeLogs.length,
              itemBuilder: (context, index) {
                final log = safeLogs[index];
                final isDone = (log['ket_qua'] ?? '') == 'Đã xử lý';

                return Card(
                  elevation: 1.5,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ID: ${log['id']} | Phiếu BT: #${log['ma_phieu_bao_tri']}',
                              style: TextStyle(color: primaryNavy, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDone ? Colors.green.shade100 : Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                log['ket_qua'] ?? 'Đang xử lý',
                                style: TextStyle(
                                  color: isDone ? Colors.green.shade800 : Colors.orange.shade800, 
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.computer, 'Máy: ${log['ma_may'] ?? 'N/A'} - ${log['ten_may'] ?? ''}'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.access_time, 'Thời gian: ${_formatDate(log['thoi_gian_sua'] ?? log['created_at'])}'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.build_circle_outlined, 'Nội dung: ${log['noi_dung_sua'] ?? 'Không có'}'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.attach_money, 'Chi phí: ${_formatCost(log['chi_phi'])} VNĐ'),
                        const SizedBox(height: 8),
                        _buildInfoRow(Icons.person, 'Người sửa: ${log['nguoi_sua'] ?? 'Hệ thống'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text, 
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}