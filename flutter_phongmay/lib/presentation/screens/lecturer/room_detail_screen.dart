import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

const Color kAppBlue = Color(0xFF193D87);

class RoomDetailScreen extends StatefulWidget {
  final Map<String, dynamic> room;

  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  bool _isLoading = true;
  List<dynamic> _computers = [];

  @override
  void initState() {
    super.initState();
    _fetchComputers();
  }

  Future<void> _fetchComputers() async {
    try {
      final res = await ApiService.get(
        '/phong-may/${widget.room['id']}/may-tinh',
      );
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          setState(() {
            _computers = body['data'] ?? [];
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải máy tính: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm xử lý hiển thị Ổ cứng (ghép SSD và HDD nếu có)
  String _getStorageString(dynamic may) {
    String ssd = may['ssd'] ?? '';
    String hdd = may['hdd'] ?? '';
    if (ssd.isNotEmpty && hdd.isNotEmpty) return 'SSD $ssd + HDD $hdd';
    if (ssd.isNotEmpty) return 'SSD $ssd';
    if (hdd.isNotEmpty) return 'HDD $hdd';
    return 'N/A';
  }

  // ========================================================
  // HÀM HIỂN THỊ CHI TIẾT CẤU HÌNH MÁY TÍNH (BOTTOM SHEET)
  // ========================================================
  void _showComputerDetails(BuildContext context, dynamic may) {
    bool isMayActive = may['trang_thai'] == 'active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép thiết lập chiều cao tùy chỉnh
      backgroundColor: Colors.transparent, // Nền trong suốt để bo góc đẹp hơn
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7, // Mở lên chiếm 70% màn hình
          minChildSize: 0.5,
          maxChildSize: 0.9, // Kéo tối đa chiếm 90%
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              controller: controller, // Gắn controller để cuộn được
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chi Tiết ${may['ten_may'] ?? may['ma_may']}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kAppBlue,
                  ),
                ),
                const SizedBox(height: 24),

                _buildDetailRow(
                  Icons.qr_code,
                  'Mã máy:',
                  may['ma_may'] ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.info_outline,
                  'Trạng thái:',
                  isMayActive ? 'Đang hoạt động' : 'Bảo trì / Lỗi',
                  valueColor: isMayActive ? Colors.green : Colors.orange,
                ),

                const Divider(height: 30),
                const Text(
                  'Cấu hình phần cứng:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kAppBlue,
                  ),
                ),
                const SizedBox(height: 12),

                _buildDetailRow(Icons.memory, 'CPU:', may['bo_xu_ly'] ?? 'N/A'),
                _buildDetailRow(Icons.sd_storage, 'RAM:', may['ram'] ?? 'N/A'),
                _buildDetailRow(
                  Icons.storage,
                  'Ổ cứng:',
                  _getStorageString(may),
                ),
                _buildDetailRow(
                  Icons.developer_board,
                  'VGA:',
                  may['card_do_hoa'] ?? 'Onboard',
                ),
                _buildDetailRow(
                  Icons.device_hub,
                  'Mainboard:',
                  may['bo_mach_chu'] ?? 'N/A',
                ),

                const Divider(height: 30),
                const Text(
                  'Thiết bị ngoại vi:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kAppBlue,
                  ),
                ),
                const SizedBox(height: 12),

                _buildDetailRow(
                  Icons.monitor,
                  'Màn hình:',
                  may['man_hinh'] ?? 'N/A',
                ),
                _buildDetailRow(
                  Icons.keyboard,
                  'Bàn phím:',
                  may['ban_phim'] ?? 'N/A',
                ),
                _buildDetailRow(Icons.mouse, 'Chuột:', may['chuot'] ?? 'N/A'),

                const Divider(height: 30),
                _buildDetailRow(
                  Icons.note,
                  'Ghi chú:',
                  (may['ghi_chu'] == null ||
                          may['ghi_chu'].toString().trim().isEmpty)
                      ? 'Không có ghi chú'
                      : may['ghi_chu'],
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hàm hỗ trợ vẽ từng dòng thông tin
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRoomActive = widget.room['trang_thai'] == 'active';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: Text(
          'Chi Tiết ${widget.room['ten_phong']}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- THÔNG TIN TỔNG QUAN VỀ PHÒNG ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mã phòng: ${widget.room['ma_phong']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isRoomActive
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isRoomActive ? 'Đang hoạt động' : 'Bảo trì',
                        style: TextStyle(
                          color: isRoomActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.computer, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Sức chứa: ${widget.room['suc_chua']} máy tính',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.description, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.room['mo_ta'] ?? 'Chưa có mô tả',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // --- DANH SÁCH MÁY TÍNH TRONG PHÒNG ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Danh sách thiết bị (${_computers.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kAppBlue,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kAppBlue),
                  )
                : _computers.isEmpty
                ? const Center(
                    child: Text(
                      'Phòng này hiện chưa có máy tính nào.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _computers.length,
                    itemBuilder: (context, index) {
                      final may = _computers[index];
                      bool isMayActive = may['trang_thai'] == 'active';

                      String cpu = may['bo_xu_ly'] ?? 'N/A';
                      String ram = may['ram'] ?? 'N/A';
                      String oCung = _getStorageString(may);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          // CHÍNH LÀ CHỖ NÀY: BẤM VÀO SẼ GỌI HÀM HIỂN THỊ CHI TIẾT MÁY
                          onTap: () => _showComputerDetails(context, may),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isMayActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            child: Icon(
                              Icons.desktop_windows,
                              color: isMayActive ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            may['ten_may'] ?? may['ma_may'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CPU: $cpu\nRAM: $ram  |  Ổ cứng: $oCung',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Bấm xem cấu hình chi tiết ➔',
                                  style: TextStyle(
                                    color: kAppBlue,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(
                            isMayActive
                                ? Icons.check_circle
                                : Icons.build_circle,
                            color: isMayActive ? Colors.green : Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}