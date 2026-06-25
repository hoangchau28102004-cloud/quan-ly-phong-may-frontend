import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/schedule_viewmodel.dart';

const Color kAppBlue = Color(0xFF193D87);

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _history = [];
  List<Map<String, dynamic>> _rooms =
      []; // Chứa danh sách phòng để dùng khi Edit

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final user = context.read<LoginViewModel>().currentUser;
    if (user != null) {
      try {
        // 1. Lấy danh sách phòng máy (để phòng hờ khi giảng viên muốn bấm sửa)
        final resRoom = await ApiService.get('/phong-may');
        if (resRoom.statusCode == 200) {
          final bodyRoom = ApiService.decodeBody(resRoom);
          if (bodyRoom != null && bodyRoom['success'] == true) {
            _rooms = List<Map<String, dynamic>>.from(bodyRoom['data'] ?? []);
          }
        }

        // 2. Lấy lịch sử mượn phòng của giảng viên này (Giả sử bạn đã viết API này trong Backend)
        // Thay URL này bằng URL API lấy danh sách đặt phòng theo ma_giang_vien của bạn
        final resHistory = await ApiService.get(
          '/dat-phong?nguoi_dung_id=${user.id}',
        );
        if (resHistory.statusCode == 200) {
          final bodyHistory = ApiService.decodeBody(resHistory);
          if (bodyHistory != null && bodyHistory['success'] == true) {
            _history = bodyHistory['data'] ?? [];
          }
        }
      } catch (e) {
        debugPrint('Lỗi tải lịch sử: $e');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Hàm gọi API Cập nhật phiếu
  Future<void> _updateBooking(int bookingId, Map<String, dynamic> data) async {
    // Gọi API PUT/PATCH để cập nhật
    final res = await ApiService.put('/dat-phong/$bookingId', data);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật yêu cầu thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchData(); // Tải lại danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật thất bại. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Lịch Sử Mượn Phòng',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kAppBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAppBlue))
          : _history.isEmpty
          ? const Center(
              child: Text(
                'Bạn chưa có lịch sử mượn phòng nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return _buildHistoryCard(item);
              },
            ),
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    String status = item['trang_thai_duyet'] ?? 'pending';
    Color statusColor;
    String statusText;

    if (status == 'approved') {
      statusColor = Colors.green;
      statusText = 'Đã duyệt';
    } else if (status == 'rejected') {
      statusColor = Colors.red;
      statusText = 'Từ chối';
    } else {
      statusColor = Colors.orange;
      statusText = 'Chờ duyệt';
    }

    // Format ngày hiển thị
    String ngayDat = item['ngay_dat'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(item['ngay_dat']))
        : 'Đang cập nhật';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Phòng: ${item['ten_phong'] ?? 'Chưa rõ'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kAppBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
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
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.calendar_today, 'Ngày mượn:', ngayDat),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian:',
              'Ca ${item['ma_ca']} (Tiết ${item['tiet_bat_dau']} - ${item['tiet_ket_thuc']})',
            ),
            _buildInfoRow(
              Icons.info_outline,
              'Mục đích:',
              item['muc_dich'] ?? 'Không có',
            ),

            // CHỈ HIỂN THỊ NÚT SỬA KHI TRẠNG THÁI LÀ PENDING
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showEditBottomSheet(item),
                  icon: const Icon(Icons.edit, size: 18, color: kAppBlue),
                  label: const Text(
                    'Sửa yêu cầu',
                    style: TextStyle(color: kAppBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kAppBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // --- BOTTOM SHEET ĐỂ SỬA YÊU CẦU ---
  void _showEditBottomSheet(dynamic item) {
    // Khởi tạo các giá trị ban đầu dựa trên phiếu cũ
    DateTime? editDate = item['ngay_dat'] != null
        ? DateTime.parse(item['ngay_dat'])
        : DateTime.now();
    int? editRoomId = item['ma_phong'];
    String editCa = item['ma_ca'] ?? 'Sáng';
    int editTietBatDau = item['tiet_bat_dau'] ?? 1;
    int editTietKetThuc = item['tiet_ket_thuc'] ?? 3;
    TextEditingController editMucDichCtrl = TextEditingController(
      text: item['muc_dich'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(
                  context,
                ).viewInsets.bottom, // Đẩy UI lên khi hiện bàn phím
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sửa Yêu Cầu Mượn Phòng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kAppBlue,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sửa Ngày
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: editDate!,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (picked != null)
                          setModalState(() => editDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(editDate!)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sửa Phòng
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: editRoomId,
                      items: _rooms
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: r['id'],
                              child: Text(r['ten_phong'].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setModalState(() => editRoomId = val),
                    ),
                    const SizedBox(height: 12),

                    // Sửa Ca và Tiết
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value: editCa,
                            items: ['Sáng', 'Chiều', 'Tối']
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setModalState(() => editCa = val!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value: editTietBatDau,
                            items: List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('T${i + 1}'),
                              ),
                            ),
                            onChanged: (val) =>
                                setModalState(() => editTietBatDau = val!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value: editTietKetThuc,
                            items: List.generate(
                              12,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('T${i + 1}'),
                              ),
                            ),
                            onChanged: (val) =>
                                setModalState(() => editTietKetThuc = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Sửa Mục đích
                    TextField(
                      controller: editMucDichCtrl,
                      decoration: InputDecoration(
                        hintText: 'Mục đích mượn',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nút Lưu Cập Nhật
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAppBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (editTietBatDau > editTietKetThuc) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tiết bắt đầu không được lớn hơn tiết kết thúc',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          Navigator.pop(context); // Đóng BottomSheet
                          // Gọi hàm update
                          _updateBooking(item['id'], {
                            'ngay_dat': DateFormat(
                              'yyyy-MM-dd',
                            ).format(editDate!),
                            'ma_phong': editRoomId,
                            'ma_ca': editCa,
                            'tiet_bat_dau': editTietBatDau,
                            'tiet_ket_thuc': editTietKetThuc,
                            'muc_dich': editMucDichCtrl.text,
                          });
                        },
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
