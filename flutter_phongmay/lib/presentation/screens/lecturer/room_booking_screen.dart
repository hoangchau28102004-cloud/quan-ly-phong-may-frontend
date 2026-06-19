import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

class RoomBookingScreen extends StatefulWidget {
  const RoomBookingScreen({super.key});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  final _mucDichController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedRoomId;
  String _selectedCa = 'Sáng';
  int _tietBatDau = 1;
  int _tietKetThuc = 3;

  // Gọi API để lấy danh sách phòng thay vì hardcode
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingRooms = true;

  final List<String> _caList = ['Sáng', 'Chiều', 'Tối'];
  final List<int> _tietList = List.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _fetchRooms(); // Tự động lấy phòng khi mở màn hình
  }

  Future<void> _fetchRooms() async {
    try {
      final res = await ApiService.get('/phong-may');
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          if (mounted) {
            setState(() {
              _rooms = List<Map<String, dynamic>>.from(body['data'] ?? []);
              _isLoadingRooms = false;
            });
          }
          return;
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingRooms = false);
    }
  }

  @override
  void dispose() {
    _mucDichController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitBooking() async {
    if (_selectedDate == null || _selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày và phòng!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tietBatDau > _tietKetThuc) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiết bắt đầu không được lớn hơn tiết kết thúc!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final user = context.read<LoginViewModel>().currentUser;

    if (user != null) {
      bool success = await context.read<ScheduleViewModel>().submitRoomBooking(
        formattedDate,
        user.id,
        _selectedRoomId!,
        _selectedCa,
        _tietBatDau,
        _tietKetThuc,
        _mucDichController.text.trim(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi yêu cầu mượn phòng thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi: Không thể gửi yêu cầu.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ScheduleViewModel>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Đăng Ký Mượn Phòng',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF193D87),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BLOCK 1: THỜI GIAN & ĐỊA ĐIỂM ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THÔNG TIN CHUNG',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn Ngày
                  const Text(
                    'Ngày mượn *',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Chọn ngày'
                                : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                          ),
                          const Icon(Icons.calendar_month, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn Phòng (Load từ API)
                  const Text(
                    'Phòng máy *',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    hint: Text(
                      _isLoadingRooms
                          ? 'Đang tải danh sách phòng...'
                          : (_rooms.isEmpty ? 'Chưa có phòng nào trong CSDL' : 'Vui lòng chọn phòng'),
                    ),
                    value: _selectedRoomId,
                    items: _rooms
                        .map(
                          (r) => DropdownMenuItem<int>(
                            value: r['id'],
                            child: Text(r['ten_phong']?.toString() ?? 'Phòng trống'),
                          ),
                        )
                        .toList(),
                    onChanged: _rooms.isEmpty ? null : (val) => setState(() => _selectedRoomId = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- BLOCK 2: CHI TIẾT CA & TIẾT ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CHI TIẾT MƯỢN',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Chọn Ca
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ca học',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: _selectedCa,
                              items: _caList
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCa = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Chọn Tiết Bắt Đầu
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Từ tiết',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: _tietBatDau,
                              items: _tietList
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text('Tiết $t'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _tietBatDau = val!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Chọn Tiết Kết Thúc
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đến tiết',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: _tietKetThuc,
                              items: _tietList
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text('Tiết $t'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _tietKetThuc = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mục đích
                  const Text(
                    'Mục đích mượn',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _mucDichController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'VD: Dạy bù môn Lập trình Web...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- NÚT GỬI YÊU CẦU ---
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF193D87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isLoading ? null : _submitBooking,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GỬI YÊU CẦU MƯỢN PHÒNG',
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
      ),
    );
  }
}