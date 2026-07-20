import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/core/constants/status_translations.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

const Color kAppBlue = Color(0xFF193D87);

class MachineDetailScreen extends StatefulWidget {
  final Map<String, dynamic> machine;
  final String roomName;

  const MachineDetailScreen({
    super.key,
    required this.machine,
    required this.roomName,
  });

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  bool _isLoading = true;

  List<dynamic> _transfers = [];
  List<dynamic> _borrows = [];
  List<dynamic> _returns =
      []; // Bác tách riêng Mượn/Trả ở backend nên phải có biến này
  List<dynamic> _maintenances = [];

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);
    try {
      final machineId = widget.machine['id'];

      // SỬA ĐƯỜNG DẪN: Bỏ chữ /assets đi, vì app.js đã map trực tiếp từ /api
      final res = await ApiService.get('/may-tinh/$machineId/history');

      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body['success'] == true) {
          setState(() {
            _transfers = body['data']['dieu_chuyen'] ?? [];
            _borrows = body['data']['muon_may'] ?? [];
            _returns = body['data']['tra_may'] ?? [];
            _maintenances = body['data']['sua_chua'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải lịch sử thiết bị: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F9),
        appBar: AppBar(
          backgroundColor: kAppBlue,
          foregroundColor: Colors.white,
          title: const Text('Hồ sơ Máy Tính', style: TextStyle(fontSize: 18)),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'ĐIỀU CHUYỂN'),
              Tab(text: 'MƯỢN/TRẢ'),
              Tab(text: 'SỬA CHỮA'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildMachineHeader(),
            const Divider(height: 1, color: Colors.black12),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kAppBlue),
                    )
                  : TabBarView(
                      children: [
                        _buildTransferHistoryTab(),
                        _buildBorrowHistoryTab(),
                        _buildMaintenanceHistoryTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineHeader() {
    final c = widget.machine;
    bool isActive =
        (c['trang_thai'] ?? 'active').toString().toLowerCase() == 'active';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.desktop_windows, color: kAppBlue, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    c['ma_may']?.toString() ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  translateAppStatus(
                    c['trang_thai'],
                    defaultLabel: isActive ? 'Đang hoạt động' : 'Bảo trì',
                  ),
                  style: TextStyle(
                    color: isActive
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.room, size: 18, color: Colors.redAccent),
              const SizedBox(width: 4),
              Text(
                widget.roomName,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildConfigRow('CPU', c['bo_xu_ly']),
                const SizedBox(height: 8),
                _buildConfigRow('RAM', c['ram']),
                const SizedBox(height: 8),
                _buildConfigRow('Ổ cứng', c['ssd'] ?? c['hdd']),
                const SizedBox(height: 8),
                _buildConfigRow('VGA/GPU', c['card_do_hoa']),
                const SizedBox(height: 8),
                _buildConfigRow('Bo mạch chủ', c['bo_mach_chu']),
                const SizedBox(height: 8),
                _buildConfigRow('Màn hình', c['man_hinh']),
                const SizedBox(height: 8),
                _buildConfigRow(
                  'Phụ kiện',
                  '${c['ban_phim'] ?? '-'} / ${c['chuot'] ?? '-'}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, dynamic value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(
          value?.toString() ?? 'N/A',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 1: LỊCH SỬ ĐIỀU CHUYỂN
  // ==========================================
  Widget _buildTransferHistoryTab() {
    if (_transfers.isEmpty) {
      return _buildEmptyState('Chưa có lịch sử điều chuyển');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transfers.length,
      itemBuilder: (context, index) {
        final t = _transfers[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8EEFF),
              child: Icon(Icons.swap_horiz, color: kAppBlue),
            ),
            // UPDATE: Đã map đúng key 'tu_phong' và 'den_phong' từ Backend trả về
            title: Text(
              'Từ: ${t['tu_phong'] ?? 'KHO'} ➡️ Đến: ${t['den_phong'] ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'Ngày thao tác: ${_formatDate(t['thoi_gian_dieu_chuyen'])}\n'
              'Người thao tác: ${t['nguoi_thao_tac'] ?? 'Hệ thống'}\n'
              'Lý do: ${t['ly_do'] ?? 'Không có lý do cụ thể'}',
              style: const TextStyle(height: 1.4),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 2: LỊCH SỬ MƯỢN TRẢ
  // Kết hợp data từ getMachineBorrowHistory và getMachineReturnHistory của bác
  // ==========================================
  Widget _buildBorrowHistoryTab() {
    if (_borrows.isEmpty) return _buildEmptyState('Chưa có lịch sử mượn trả');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _borrows.length,
      itemBuilder: (context, index) {
        final b = _borrows[index];

        // Tìm xem cái mã phiếu mượn này đã có trong danh sách TRẢ MÁY chưa
        final r = _returns.firstWhere(
          (ret) => ret['ma_phieu_muon'] == b['id'],
          orElse: () => null,
        );

        bool isReturned = r != null;
        String returnDate = isReturned
            ? _formatDate(r['thoi_gian_tra'])
            : 'ĐANG MƯỢN';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isReturned
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Icon(
                isReturned ? Icons.check_circle : Icons.hourglass_top,
                color: isReturned ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              'Mã phiếu mượn: ${b['ma_phieu_muon'] ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'Khoa/Phòng: ${b['ten_phong_ban'] ?? 'N/A'}\n'
              'Ngày mượn: ${_formatDate(b['ngay_muon'])}\n'
              'Trạng thái: ${isReturned ? 'Đã trả ($returnDate)' : 'ĐANG NỢ MÁY'}',
              style: const TextStyle(height: 1.4),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 3: LỊCH SỬ SỬA CHỮA
  // Lấy data từ bảng bao_cao_su_co thông qua getMachineMaintenanceHistory của bác
  // ==========================================
  Widget _buildMaintenanceHistoryTab() {
    if (_maintenances.isEmpty) {
      return _buildEmptyState('Máy chưa có sự cố sửa chữa');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _maintenances.length,
      itemBuilder: (context, index) {
        final m = _maintenances[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.build, color: Colors.red),
            ),
            title: Text(
              '${m['tieu_de'] ?? 'Báo cáo sự cố'} (${m['loai_su_co'] ?? 'N/A'})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'Mức độ: ${translateAppStatus(m['muc_do']?.toString(), defaultLabel: 'Bình thường')}\n'
              'Ngày báo: ${_formatDate(m['created_at'])}\n'
              'Trạng thái: ${translateAppStatus(m['trang_thai']?.toString(), defaultLabel: 'Không rõ')}\n'
              'Mô tả: ${m['mo_ta'] ?? 'Không có mô tả chi tiết'}',
              style: const TextStyle(height: 1.4),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
