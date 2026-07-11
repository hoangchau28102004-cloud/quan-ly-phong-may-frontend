import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class RoomBookingScreen extends StatefulWidget {
  const RoomBookingScreen({super.key});

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  DateTime _selectedDate = DateTime.now();

  // Để null mặc định để Dropdown ban đầu trống
  int? _tietBatDau;
  int? _tietKetThuc;

  List<Map<String, dynamic>> _rooms = [];
  bool _isLoadingRooms = true;

  @override
  void initState() {
    super.initState();
    _fetchAvailableRooms(); // Lấy phòng trống theo ngày và tiết hiện tại
  }

  // GỌI API MỚI CÓ KIỂM TRA TRẠNG THÁI
  Future<void> _fetchAvailableRooms() async {
    setState(() => _isLoadingRooms = true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      // SỬA: Xử lý an toàn khi _tietBatDau hoặc _tietKetThuc là null
      final startParam = _tietBatDau != null ? '$_tietBatDau' : '';
      final endParam = _tietKetThuc != null ? '$_tietKetThuc' : '';

      final res = await ApiService.get(
        '/phong-may/available?date=$formattedDate&start=$startParam&end=$endParam',
      );

      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          if (mounted) {
            setState(() {
              _rooms = List<Map<String, dynamic>>.from(body['data'] ?? []);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải phòng: $e");
    } finally {
      if (mounted) setState(() => _isLoadingRooms = false);
    }
  }

  String _getCaHoc(int tiet) {
    if (tiet >= 11) return 'Tối';
    if (tiet >= 6) return 'Chiều';
    return 'Sáng';
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchAvailableRooms(); // Tải lại danh sách phòng khi đổi ngày
    }
  }

  void _showBookingDialog(Map<String, dynamic> room) {
    // SỬA: Bắt lỗi nếu người dùng chưa chọn tiết mà đã bấm đăng ký
    if (_tietBatDau == null || _tietKetThuc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ tiết bắt đầu và tiết kết thúc!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_tietBatDau! > _tietKetThuc!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiết bắt đầu không được lớn hơn tiết kết thúc!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController mucDichCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Đăng ký ${room['ma_phong']}',
            style: const TextStyle(
              color: kAppBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thời gian: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}, Tiết $_tietBatDau - $_tietKetThuc',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mục đích mượn phòng:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: mucDichCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'VD: Dạy bù môn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAppBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _submitBooking(room['id'], mucDichCtrl.text.trim());
              },
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitBooking(int roomId, String mucDich) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final user = context.read<LoginViewModel>().currentUser;

    if (user != null && _tietBatDau != null && _tietKetThuc != null) {
      String caHoc = _getCaHoc(_tietBatDau!);
      bool success = await context.read<ScheduleViewModel>().submitRoomBooking(
        formattedDate,
        user.id,
        roomId,
        caHoc,
        _tietBatDau!,
        _tietKetThuc!,
        mucDich,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi yêu cầu mượn phòng thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchAvailableRooms(); // Tải lại phòng sau khi đăng ký thành công
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
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- BỘ LỌC TÌM KIẾM ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày đặt',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 13),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Từ tiết',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // SỬA: DROPDOWN TIẾT BẮT ĐẦU CHẠY ĐỘNG
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'Chọn',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        initialValue: _tietBatDau,
                        items: List.generate(
                          12,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text(
                              'Tiết ${i + 1}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _tietBatDau = val;
                            // Reset Tiết kết thúc nếu nó nhỏ hơn Tiết bắt đầu mới
                            if (_tietKetThuc != null &&
                                _tietKetThuc! < _tietBatDau!) {
                              _tietKetThuc = null;
                            }
                          });
                          _fetchAvailableRooms();
                        },
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đến tiết',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // SỬA: DROPDOWN TIẾT KẾT THÚC CHẠY ĐỘNG DỰA VÀO TIẾT BẮT ĐẦU
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: 'Chọn',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        initialValue: _tietKetThuc,
                        disabledHint: const Text(
                          'Chọn',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        // Nếu chưa chọn tiết bắt đầu -> null -> Dropdown bị disable
                        items: _tietBatDau == null
                            ? null
                            : List.generate(
                                13 - _tietBatDau!, // Chỉ sinh từ tiết BĐ đến 12
                                (i) {
                                  int tiet = _tietBatDau! + i;
                                  return DropdownMenuItem(
                                    value: tiet,
                                    child: Text(
                                      'Tiết $tiet',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  );
                                },
                              ),
                        onChanged: _tietBatDau == null
                            ? null
                            : (val) {
                                setState(() => _tietKetThuc = val);
                                _fetchAvailableRooms();
                              },
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Danh sách phòng ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}, tiết ${_tietBatDau ?? "?"}-${_tietKetThuc ?? "?"}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoadingRooms || isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kAppBlue),
                  )
                : _rooms.isEmpty
                ? const Center(child: Text('Không có dữ liệu phòng'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      return _buildRoomCard(_rooms[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    // 1 là Trống, 0 là Đã sử dụng (Từ Backend trả về)
    bool isAvailable = room['is_available'] == 1;

    Color statusColor = isAvailable ? Colors.green : Colors.orange;
    String statusText = isAvailable ? 'Trống' : 'Đã sử dụng';
    String detailText = isAvailable ? 'Có thể đăng ký' : 'Đã có lịch học/mượn';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAppBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.desktop_windows,
                    color: kAppBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['ma_phong'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        room['ten_phong'] ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${room['suc_chua'] ?? 0} máy',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withOpacity(0.5)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detailText,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isAvailable
                        ? kAppBlue
                        : Colors.grey.shade300,
                    foregroundColor: isAvailable ? Colors.white : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.event_available, size: 16),
                  label: const Text(
                    'Đăng ký',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: isAvailable
                      ? () => _showBookingDialog(room)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}