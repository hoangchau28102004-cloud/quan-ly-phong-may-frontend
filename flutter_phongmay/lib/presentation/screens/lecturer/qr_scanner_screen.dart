import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;
  bool _isTorchOn = false;

  // HÀM GỌI API VÀ HIỂN THỊ BOTTOM SHEET GIỐNG TRONG ẢNH
  Future<void> _fetchAndShowDetails(String qrCode) async {
    // Hiện vòng xoay loading mờ trên màn hình
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final res = await ApiService.get('/may-tinh/qrcode/$qrCode');

      if (!mounted) return;
      Navigator.pop(context); // Tắt loading

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          final data = body['data'];
          _showInfoBottomSheet(data); // Gọi hàm hiện Bottom Sheet
        }
      } else {
        _showErrorAndResume('Không tìm thấy dữ liệu máy tính này!');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      _showErrorAndResume('Lỗi kết nối máy chủ!');
    }
  }

  void _showErrorAndResume(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    setState(() => _isScanned = false);
    cameraController.start();
  }

  // --- GIAO DIỆN BOTTOM SHEET GIỐNG Y HỆT ẢNH ---
  void _showInfoBottomSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Thông tin máy tính',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Màu xanh dương giống ảnh
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(
                color: Colors.blue,
                thickness: 1,
              ), // Đường gạch ngang xanh
              const SizedBox(height: 16),

              _buildInfoRow(
                Icons.computer,
                'Tên máy: ',
                data['ma_may'] ?? 'N/A',
              ),
              _buildInfoRow(Icons.qr_code, 'Mã QR: ', data['ma_qr'] ?? 'N/A'),
              _buildInfoRow(
                Icons.info_outline,
                'Trạng thái: ',
                data['trang_thai'] ?? 'N/A',
              ),
              _buildInfoRow(
                Icons.location_on,
                'Phòng: ',
                data['ten_phong'] ?? 'N/A',
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Nút màu xanh dương
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Đóng Bottom Sheet
                  },
                  child: const Text(
                    'ĐÓNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // KHI NGƯỜI DÙNG BẤM "ĐÓNG" HOẶC VUỐT XUỐNG, CAMERA SẼ HOẠT ĐỘNG LẠI ĐỂ QUÉT TIẾP
      setState(() => _isScanned = false);
      cameraController.start();
    });
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24), // Icon màu xanh
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quét mã QR Máy Tính',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1D357A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              try {
                await cameraController.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              } catch (_) {}
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          if (_isScanned) return; // Nếu đang xử lý rồi thì bỏ qua

          List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String qrCodeData = barcodes.first.rawValue ?? '';
            if (qrCodeData.isNotEmpty) {
              setState(() => _isScanned = true); // Khóa không cho quét tiếp
              cameraController.stop(); // Tạm dừng camera

              // Gọi hàm hiển thị dữ liệu
              _fetchAndShowDetails(qrCodeData);
            }
          }
        },
      ),
    );
  }
}
