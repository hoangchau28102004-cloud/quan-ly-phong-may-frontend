import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/student_dashboard_viewmodel.dart';
import '../scanner/student_machine_status_screen.dart';
import '../../providers/login_viewmodel.dart';

class StudentQRScannerScreen extends StatefulWidget {
  final int scheduleId;
  final String schedulePurpose;

  const StudentQRScannerScreen({
    super.key,
    required this.scheduleId,
    required this.schedulePurpose,
  });

  @override
  State<StudentQRScannerScreen> createState() => _StudentQRScannerScreenState();
}

class _StudentQRScannerScreenState extends State<StudentQRScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();

  // 🚀 CHỈ DÙNG 1 BIẾN DUY NHẤT ĐỂ KHÓA CAMERA
  bool _isProcessing = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // 🚀 HÀM QUÉT QR CHUẨN CLEAN ARCHITECTURE
  void _handleQrDetection(BarcodeCapture capture) async {
    // 1. CÔNG TẮC BÊ TÔNG: Chặn đứng 100% các khung hình quét bồi theo sau
    if (_isProcessing) return;
    _isProcessing = true; // Khóa công tắc NGAY LẬP TỨC

    // ❌ ĐÃ XÓA _cameraController.stop() Ở ĐÂY!

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || (barcodes.first.rawValue ?? '').isEmpty) {
      _isProcessing = false; // Mở khóa nếu không đọc được gì
      // ❌ ĐÃ XÓA _cameraController.start() Ở ĐÂY!
      return;
    }

    final String rawCode = barcodes.first.rawValue!;

    setState(() {}); // Cập nhật UI để hiện trạng thái Đang tải

    // 3. MÓC THÔNG TIN SINH VIÊN
    final loginVm = context.read<LoginViewModel>();
    final userId = loginVm.currentUser?.id;
    final token = loginVm.token ?? '';

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không tìm thấy thông tin Sinh viên!'),
        ),
      );
      setState(() => _isProcessing = false);
      // ❌ ĐÃ XÓA _cameraController.start() Ở ĐÂY!
      return;
    }

    // 4. GỌI API ĐIỂM DANH HOẶC ĐỔI MÁY
    final viewModel = context.read<StudentDashboardViewModel>();
    final responseData = await viewModel.checkInWithQRCode(
      rawCode,
      widget.scheduleId,
      userId,
      token,
    );

    if (!mounted) return;

    // 5. XỬ LÝ THEO TRẠNG THÁI TỪ BACKEND
    if (responseData['success'] == true) {
      // 🟢 Quét lần 1 (Mới) hoặc Quét máy khác (Đổi máy) đều THÀNH CÔNG
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentMachineStatusScreen(
            qrData: rawCode,
            machineData: responseData['data'], // Ném thông tin máy qua
            schedulePurpose: widget.schedulePurpose,
          ),
        ),
      );
    } else {
      // 🔴 Quét THẤT BẠI (Quét trùng máy cũ, sai ca, sai phòng...)
      _showResultDialog(
        icon: Icons.error_rounded,
        color: Colors.redAccent,
        title: 'Thông báo',
        content: responseData['message'] ?? 'Mã QR không hợp lệ!',
        onClose: () {
          Navigator.pop(context); // Đóng popup
          setState(() => _isProcessing = false); // Mở khóa cho phép quét tiếp
          // ❌ ĐÃ XÓA _cameraController.start() Ở ĐÂY!
        },
      );
    }
  }

  // 🚀 DIALOG THÔNG BÁO LỖI UI XỊN XÒ
  void _showResultDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
    required VoidCallback onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(icon, color: color, size: 52),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onClose,
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentDashboardViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quét QR Máy Tính',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Lớp Camera
          MobileScanner(
            controller: _cameraController,
            onDetect: _handleQrDetection,
          ),

          // Lớp Filter tối màu xung quanh
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(color: Colors.transparent),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Khung viền ngắm QR
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Chữ hướng dẫn
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Text(
              'Di chuyển camera vào vùng chứa mã QR trên máy',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),

          // Lớp Loading (Hiển thị mượt mà khi API đang chạy)
          if (viewModel.isSubmittingAttendance || _isProcessing)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý thông tin điểm danh...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
