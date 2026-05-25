// File: lib/features/scanner/scan_action_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class ScanActionScreen extends StatefulWidget {
  final String qrData; // Nhận mã QR truyền từ camera sang
  const ScanActionScreen({super.key, required this.qrData});

  @override
  State<ScanActionScreen> createState() => _ScanActionScreenState();
}

class _ScanActionScreenState extends State<ScanActionScreen> {
  final Color primaryNavy = const Color(0xFF1D357A);
  final TextEditingController _issueController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic>? _pcDetails;
  String _attendanceStatus = 'CO_MAT';
  String _pcStatus = 'BINH_THUONG';

  @override
  void initState() {
    super.initState();
    _fetchPCDetails();
  }

  // Gọi API lấy cấu hình máy tính dựa vào mã QR vừa quét
  /// Lấy thông tin máy tính từ server dựa trên `widget.qrData` (mã QR).
  /// Endpoint: GET /may-tinh/qrcode/:qrcode
  /// Khi có dữ liệu sẽ cập nhật `_pcDetails` để hiển thị chi tiết.
  Future<void> _fetchPCDetails() async {
    try {
      final response = await ApiService.get(
        '/may-tinh/qrcode/${widget.qrData}',
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _pcDetails = jsonDecode(response.body)['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể kết nối máy chủ')),
      );
    }
  }

  // Thực hiện lưu thông tin điểm danh và báo cáo lỗi lên hệ thống
  /// Gửi thông tin điểm danh và (nếu có) phiếu báo cáo sự cố lên server.
  /// - POST /diem-danh  body: { may_tinh_id, tt_diem_danh, tt_may_tinh }
  /// - POST /bao-cao-su-co body: { may_tinh_id, mo_ta, trang_thai }
  Future<void> _submitData() async {
    try {
      // 1. Gửi dữ liệu điểm danh ca học
      await ApiService.post('/diem-danh', {
        'may_tinh_id': _pcDetails?['id'],
        'tt_diem_danh': _attendanceStatus,
        'tt_may_tinh': _pcStatus,
      });

      // 2. Nếu máy lỗi, gửi thêm phiếu báo cáo sự cố
      if (_pcStatus == 'CO_LOI' && _issueController.text.isNotEmpty) {
        await ApiService.post('/bao-cao-su-co', {
          'may_tinh_id': _pcDetails?['id'],
          'mo_ta': _issueController.text,
          'trang_thai': 'CHO_XU_LY',
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ghi nhận dữ liệu thành công!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xảy ra lỗi hệ thống')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Thông Tin Máy Tính & Điểm Danh',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryNavy,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã Số Máy: ${_pcDetails?['ma_may'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryNavy,
                          ),
                        ),
                        const Divider(height: 20),
                        Text(
                          'Hệ điều hành: ${_pcDetails?['he_dieu_hanh'] ?? 'Windows 11'}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Bộ xử lý (CPU): ${_pcDetails?['cpu'] ?? 'Intel Core i7'}',
                        ),
                        const SizedBox(height: 6),
                        Text('Bộ nhớ RAM: ${_pcDetails?['ram'] ?? '16GB'}'),
                        const SizedBox(height: 6),
                        Text(
                          'Card đồ họa (GPU): ${_pcDetails?['gpu'] ?? 'RTX 3060'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Chọn Tình Trạng Điểm Danh
                  const Text(
                    'Xác nhận điểm danh:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              setState(() => _attendanceStatus = 'CO_MAT'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _attendanceStatus == 'CO_MAT'
                                  ? primaryNavy
                                  : Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: Text(
                              'Có Mặt',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _attendanceStatus == 'CO_MAT'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              setState(() => _attendanceStatus = 'VANG'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _attendanceStatus == 'VANG'
                                  ? Colors.red.shade800
                                  : Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: Text(
                              'Vắng Mặt',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _attendanceStatus == 'VANG'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Form Báo Cáo Tình Trạng Thiết Bị Máy Tính
                  const Text(
                    'Tình trạng hoạt động của máy:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () =>
                              setState(() => _pcStatus = 'BINH_THUONG'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _pcStatus == 'BINH_THUONG'
                                  ? primaryNavy
                                  : Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: Text(
                              'Bình Thường',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _pcStatus == 'BINH_THUONG'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _pcStatus = 'CO_LOI'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _pcStatus == 'CO_LOI'
                                  ? Colors.orange.shade800
                                  : Colors.white,
                              border: Border.all(
                                color: const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: Text(
                              'Báo Máy Hỏng',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _pcStatus == 'CO_LOI'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Hiển thị khung nhập mô tả lỗi nếu chọn máy hỏng
                  if (_pcStatus == 'CO_LOI') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _issueController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Nhập chi tiết mô tả lỗi thiết bị phần cứng (Màn hình xanh, không nhận chuột, hư phím...)',
                        fillColor: Colors.white,
                        filled: true,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: primaryNavy, width: 2),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),

                  // Nút hoàn tất vuông vức dính cuối form
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryNavy,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: _submitData,
                      child: const Text(
                        'GỬI THÔNG TIN HỆ THỐNG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
