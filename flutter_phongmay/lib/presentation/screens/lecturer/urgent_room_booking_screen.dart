import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class UrgentRoomBookingScreen extends StatefulWidget {
  const UrgentRoomBookingScreen({super.key});

  @override
  State<UrgentRoomBookingScreen> createState() =>
      _UrgentRoomBookingScreenState();
}

class _UrgentRoomBookingScreenState extends State<UrgentRoomBookingScreen> {
  final DateTime _selectedDate = DateTime.now();
  int? _tietBatDau;
  int? _tietKetThuc;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableRooms = [];

  @override
  void initState() {
    super.initState();
  }

  bool _isRoomAvailable(Map<String, dynamic> room) {
    final value = room['is_available'];
    return value == 1 || value == '1' || value == true;
  }

  Future<void> _fetchAvailableRooms() async {
    if (_tietBatDau == null || _tietKetThuc == null) {
      if (mounted) {
        setState(() {
          _availableRooms = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = true);
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final response = await ApiService.get(
        '/phong-may/available?date=$formattedDate&start=$_tietBatDau&end=$_tietKetThuc',
      );
      final body = ApiService.decodeBody(response);
      if (response.statusCode == 200 &&
          body != null &&
          body['success'] == true) {
        final rawRooms = List<Map<String, dynamic>>.from(body['data'] ?? []);
        final onlyAvailable = rawRooms.where(_isRoomAvailable).toList();
        if (mounted) {
          setState(() {
            _availableRooms = onlyAvailable;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _availableRooms = [];
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải phòng gấp: $e');
      if (mounted) {
        setState(() {
          _availableRooms = [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getCaHoc(int tiet) {
    if (tiet >= 11) return 'Tối';
    if (tiet >= 6) return 'Chiều';
    return 'Sáng';
  }

  Future<void> _showConfirmDialog(Map<String, dynamic> room) async {
    final TextEditingController reasonCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Mượn gấp ${room['ma_phong'] ?? room['ten_phong']}',
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
                'Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Tiết: $_tietBatDau - $_tietKetThuc',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lý do mượn nhanh',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'VD: Dạy bù, thi gấp, mượn máy ngắn hạn...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
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
                _submitUrgentBooking(room['id'], reasonCtrl.text.trim());
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

  Future<void> _submitUrgentBooking(int roomId, String reason) async {
    if (_tietBatDau == null || _tietKetThuc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ tiết bắt đầu và kết thúc'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_tietBatDau! > _tietKetThuc!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiết bắt đầu không được lớn hơn tiết kết thúc'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final user = context.read<LoginViewModel>().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập trước khi mượn phòng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await context.read<ScheduleViewModel>().submitRoomBooking(
      DateFormat('yyyy-MM-dd').format(_selectedDate),
      user.id,
      roomId,
      _getCaHoc(_tietBatDau!),
      _tietBatDau!,
      _tietKetThuc!,
      reason.isEmpty ? 'Mượn gấp' : reason,
      trangThai: 'pending',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Mượn phòng gấp thành công. Chờ admin duyệt sau.'
                : 'Lỗi khi mượn phòng gấp. Vui lòng thử lại.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) _fetchAvailableRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Mượn phòng gấp',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ngày gấp',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
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
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Chọn',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            value: _tietBatDau,
                            items: List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('Tiết ${i + 1}'),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _tietBatDau = value;
                                if (_tietKetThuc != null &&
                                    _tietBatDau != null &&
                                    _tietKetThuc! < _tietBatDau!) {
                                  _tietKetThuc = null;
                                }
                              });
                              _fetchAvailableRooms();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
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
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              hintText: 'Chọn',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            value: _tietKetThuc,
                            items: _tietBatDau == null
                                ? null
                                : List.generate(
                                    13 - _tietBatDau!,
                                    (i) => DropdownMenuItem(
                                      value: _tietBatDau! + i,
                                      child: Text('Tiết ${_tietBatDau! + i}'),
                                    ),
                                  ),
                            onChanged: _tietBatDau == null
                                ? null
                                : (value) {
                                    setState(() => _tietKetThuc = value);
                                    _fetchAvailableRooms();
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Danh sách phòng trống lúc ${DateFormat('dd/MM/yyyy').format(_selectedDate)} - Tiết ${_tietBatDau ?? '?'} đến ${_tietKetThuc ?? '?'}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (_tietBatDau != null && _tietKetThuc != null)
                  TextButton(
                    onPressed: _fetchAvailableRooms,
                    child: const Text('Làm mới'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kAppBlue),
                  )
                : _tietBatDau == null || _tietKetThuc == null
                ? const Center(
                    child: Text(
                      'Vui lòng chọn tiết bắt đầu và tiết kết thúc để xem phòng trống',
                      textAlign: TextAlign.center,
                    ),
                  )
                : _availableRooms.isEmpty
                ? const Center(
                    child: Text('Không có phòng trống cho thời gian này'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _availableRooms.length,
                    itemBuilder: (context, index) {
                      final room = _availableRooms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: kAppBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.meeting_room,
                                      color: kAppBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room['ma_phong'] ?? 'Phòng không tên',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          room['ten_phong'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${room['suc_chua'] ?? '-'} máy',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Trống',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Được phép mượn gấp',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kAppBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _showConfirmDialog(room),
                                    child: const Text(
                                      'Mượn',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
