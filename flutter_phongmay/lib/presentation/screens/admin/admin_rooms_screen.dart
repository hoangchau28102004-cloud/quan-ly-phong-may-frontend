import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

class AdminRoomsScreen extends StatefulWidget {
  const AdminRoomsScreen({super.key});

  @override
  State<AdminRoomsScreen> createState() => _AdminRoomsScreenState();
}

class _AdminRoomsScreenState extends State<AdminRoomsScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessing = false; 

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _fetchMachineBySerial(String serial) async {
    try {
      final encodedSerial = Uri.encodeComponent(serial);
      final res = await ApiService.get('/scan/$encodedSerial'); // Đảm bảo đúng route API của bạn
      final data = ApiService.decodeBody(res)?['data'];

      if (data != null && mounted) {
        _showMachineDetail(data);
      } else {
        _showError('Không tìm thấy máy có mã: $serial');
      }
    } catch (e) {
      _showError('Lỗi tra cứu: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  // =====================================================================
  // CÁC HÀM TIỆN ÍCH XÂY DỰNG GIAO DIỆN HIỂN THỊ CHI TIẾT
  // =====================================================================
  
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12, left: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1D357A), size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D357A))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    // Lọc bỏ những dòng trống (SizedBox.shrink) để tránh dư khoảng trắng
    final validChildren = children.where((child) => child is! SizedBox).toList();
    if (validChildren.isEmpty) return const Text('Không có dữ liệu', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: validChildren,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return const SizedBox.shrink(); 
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // GIAO DIỆN BOTTOM SHEET FULL THÔNG TIN
  // =====================================================================
  
  void _showMachineDetail(dynamic machine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép kéo cao lên
      backgroundColor: Colors.transparent, // Nền trong suốt để bo góc thấy rõ
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85, // Chiếm 85% chiều cao màn hình
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // Bo góc trên
        ),
        child: Column(
          children: [
            // Thanh vuốt (Handle)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            
            const Text('Hồ Sơ Máy Tính', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(height: 24),
            
            // Khu vực cuộn
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- KHỐI 1: THÔNG TIN CHUNG ---
                    _buildSectionTitle('Thông tin chung', Icons.info_outline),
                    _buildInfoCard([
                      _buildInfoRow(Icons.computer, 'Tên máy', machine['ten_may']),
                      _buildInfoRow(Icons.tag, 'Mã máy', machine['ma_may']),
                      _buildInfoRow(Icons.qr_code, 'Mã QR', machine['ma_qr']),
                      _buildInfoRow(Icons.room, 'Phòng', machine['ten_phong'] ?? 'Chưa gắn phòng'),
                      _buildInfoRow(Icons.location_on, 'Vị trí', machine['vi_tri']),
                      _buildInfoRow(Icons.toggle_on, 'Trạng thái', machine['trang_thai']),
                    ]),
                    const SizedBox(height: 16),

                    // --- KHỐI 2: CẤU HÌNH PHẦN CỨNG ---
                    _buildSectionTitle('Cấu hình phần cứng', Icons.memory),
                    _buildInfoCard([
                      _buildInfoRow(Icons.developer_board, 'CPU', machine['bo_xu_ly']),
                      _buildInfoRow(Icons.memory, 'RAM', machine['ram']),
                      _buildInfoRow(Icons.sd_card, 'VGA (Card đồ họa)', machine['card_do_hoa']),
                      _buildInfoRow(Icons.developer_board_off, 'Mainboard', machine['bo_mach_chu']),
                      _buildInfoRow(Icons.save, 'Ổ cứng SSD', machine['ssd']),
                      _buildInfoRow(Icons.save_outlined, 'Ổ cứng HDD', machine['hdd']),
                    ]),
                    const SizedBox(height: 16),

                    // --- KHỐI 3: NGOẠI VI & GHI CHÚ ---
                    _buildSectionTitle('Ngoại vi & Khác', Icons.keyboard),
                    _buildInfoCard([
                      _buildInfoRow(Icons.monitor, 'Màn hình', machine['man_hinh']),
                      _buildInfoRow(Icons.keyboard, 'Bàn phím', machine['ban_phim']),
                      _buildInfoRow(Icons.mouse, 'Chuột', machine['chuot']),
                      _buildInfoRow(Icons.notes, 'Ghi chú', machine['ghi_chu']),
                    ]),
                    const SizedBox(height: 24), // Đẩy khoảng trống phía dưới cùng
                  ],
                ),
              ),
            ),
            
            // Nút Đóng ghim dưới cùng
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700, 
                    padding: const EdgeInsets.symmetric(vertical: 14), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ĐÓNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                ),
              ),
            )
          ],
        ),
      ),
    ).then((_) {
      // Khi đóng bottom sheet thì nhả cờ cho quét mã tiếp
      if (mounted) setState(() => _isProcessing = false);
    });
  }

  // =====================================================================
  // KHUNG CAMERA
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Quét mã QR Máy Tính',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                controller: _cameraController,
                onDetect: (capture) {
                  if (_isProcessing) return; 

                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    setState(() => _isProcessing = true); 
                    final String serial = barcodes.first.rawValue!.trim(); 
                    _fetchMachineBySerial(serial);
                  }
                },
              ),
              
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: _isProcessing ? Colors.orange : Colors.greenAccent, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              
              if (_isProcessing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(8)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(width: 16),
                      Text('Đang tra cứu dữ liệu...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}