import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/datasources/api_service.dart';
import 'lecturer_machine_detail_screen.dart';

class LecturerQRScannerScreen extends StatefulWidget {
  final String tenMon;
  final String maLop;
  final int scheduleId;
  final String expectedRoomName; // 🚀 ĐÃ KHAI BÁO BIẾN ĐỂ HỨNG TÊN PHÒNG

  const LecturerQRScannerScreen({
    Key? key,
    required this.tenMon,
    required this.maLop,
    required this.scheduleId,
    required this.expectedRoomName, // 🚀 ĐÃ THÊM VÀO CONSTRUCTOR
  }) : super(key: key);

  @override
  State<LecturerQRScannerScreen> createState() => _LecturerQRScannerScreenState();
}

class _LecturerQRScannerScreenState extends State<LecturerQRScannerScreen> {
  bool _isProcessing = false;
  late MobileScannerController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String qrCode) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    _cameraController.stop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final response = await ApiService.post('/scan-lecturer', {
        'qrCode': qrCode,
      });
      
      final decoded = ApiService.decodeBody(response);

      if (!mounted) return;
      Navigator.pop(context); // Tắt loading

      if (decoded != null && decoded['success'] == true) {
        final machineData = decoded['data']['machine'];
        final scannedRoomName = machineData['ten_phong'] ?? '';

        // 🚀 LOGIC CHẶN ĐỨNG NẾU QUÉT MÃ SAI PHÒNG (BẢO VỆ UX)
        if (scannedRoomName.toString().trim().toLowerCase() != widget.expectedRoomName.trim().toLowerCase()) {
           throw Exception('Mã QR sai phòng!\nThiết bị này thuộc "$scannedRoomName". Vui lòng đến đúng phòng "${widget.expectedRoomName}" của lớp học này để điểm danh.');
        }

        // Tắt màn hình camera, ĐẨY TOÀN BỘ DATA SANG MÀN TRẠM TRUNG CHUYỂN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LecturerMachineDetailScreen(
              machineData: machineData,
              tenMon: widget.tenMon,
              maLop: widget.maLop,
              scheduleId: widget.scheduleId,
            ),
          ),
        );
      } else {
        throw Exception(decoded?['message'] ?? 'Mã QR không hợp lệ.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      // Show Snackbar báo lỗi cụ thể
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontSize: 15)), 
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      setState(() => _isProcessing = false);
      _cameraController.start(); // Khởi động lại cam để quét tiếp
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã máy tính'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black, 
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                final String code = barcodes.first.rawValue!;
                _processQRCode(code);
              }
            },
          ),
          QRScannerOverlay(overlayColour: Colors.black.withOpacity(0.6)),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
                const SizedBox(height: 16),
                Text(
                  _isProcessing ? 'Đang xử lý...' : 'Di chuyển camera đến mã QR\nphòng: ${widget.expectedRoomName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class QRScannerOverlay extends StatelessWidget {
  final Color overlayColour;

  const QRScannerOverlay({Key? key, required this.overlayColour}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double scanArea = (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 250.0 : 300.0;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(overlayColour, BlendMode.srcOut),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: scanArea,
                height: scanArea,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}