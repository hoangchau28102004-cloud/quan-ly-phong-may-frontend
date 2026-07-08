import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class ScanActionScreen extends StatefulWidget {
  final String qrData;
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

  Future<void> _submitData() async {
    try {
      await ApiService.post('/diem-danh', {
        'ma_may_tinh': _pcDetails?['id'],
        'tt_diem_danh': _attendanceStatus,
        'tt_may_tinh': _pcStatus,
      });

      if (_pcStatus == 'CO_LOI' && _issueController.text.isNotEmpty) {
        await ApiService.post('/bao-cao-su-co', {
          'ma_may_tinh': _pcDetails?['id'],
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
                          'Máy: ${_pcDetails?['ma_may'] ?? _pcDetails?['ten_may'] ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text('CPU: ${_pcDetails?['bo_xu_ly'] ?? 'N/A'}'),
                        const SizedBox(height: 6),
                        Text('RAM: ${_pcDetails?['ram'] ?? 'N/A'}'),
                        const SizedBox(height: 6),
                        Text('GPU: ${_pcDetails?['card_do_hoa'] ?? 'N/A'}'),
                        const SizedBox(height: 6),
                        Text(
                          'Ổ cứng: ${_pcDetails?['ssd'] ?? _pcDetails?['hdd'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ghi chú: ${_pcDetails?['ghi_chu'] ?? 'Không có'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
