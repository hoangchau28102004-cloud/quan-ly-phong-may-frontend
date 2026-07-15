import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

class SchedulingManagementScreen extends StatefulWidget {
  const SchedulingManagementScreen({super.key});

  @override
  State<SchedulingManagementScreen> createState() =>
      _SchedulingManagementScreenState();
}

class _SchedulingManagementScreenState
    extends State<SchedulingManagementScreen> {
  bool isLoading = true;
  List<dynamic> rooms = [];
  List<dynamic> schedules = [];
  List<dynamic> bookingRequests = [];
  List<dynamic> modules = [];
  List<dynamic> teachers = [];

  // STATE CHO CHẾ ĐỘ THỜI KHÓA BIỂU
  bool _isGridView = true;
  int? _selectedRoomId;
  DateTime _currentWeekDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final sRes = await ApiService.get('/schedule/lich-phong');
      final bRes = await ApiService.get('/schedule/dat-phong');
      final rRes = await ApiService.get('/phong-may');
      final tRes = await ApiService.get('/giang-vien');
      dynamic mRes;
      try {
        mRes = await ApiService.get('/lop-hoc-phan');
      } catch (e) {
        debugPrint('Lỗi tải LHP: $e');
      }

      setState(() {
        final sBody = ApiService.decodeBody(sRes);
        final bBody = ApiService.decodeBody(bRes);
        final rBody = ApiService.decodeBody(rRes);
        final mBody = mRes != null ? ApiService.decodeBody(mRes) : null;
        final tBody = ApiService.decodeBody(tRes);

        schedules = (sBody != null && sBody['data'] is List)
            ? sBody['data']
            : [];
        bookingRequests = (bBody != null && bBody['data'] is List)
            ? bBody['data']
            : [];
        rooms = (rBody != null && rBody['data'] is List) ? rBody['data'] : [];
        modules = (mBody != null && mBody['data'] is List) ? mBody['data'] : [];
        teachers = (tBody != null && tBody['data'] is List)
            ? tBody['data']
            : [];
        // Khởi tạo phòng mặc định
        if (rooms.isNotEmpty && _selectedRoomId == null) {
          _selectedRoomId = int.tryParse(rooms.first['id']?.toString() ?? '');
        }
      });
    } catch (e) {
      debugPrint("Lỗi tải dữ liệu: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateBookingStatus(int id, String status) async {
    try {
      final res = await ApiService.put('/schedule/dat-phong/$id', {
        'trang_thai_duyet': status,
      });
      final resBody = ApiService.decodeBody(res);

      // 🚀 FIX: Bắt lỗi gắt gao khi Duyệt/Từ chối
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                status == 'approved'
                    ? 'Đã duyệt yêu cầu đặt phòng!'
                    : 'Đã từ chối yêu cầu!',
              ),
              backgroundColor: status == 'approved'
                  ? Colors.green
                  : Colors.redAccent,
            ),
          );
        }
        _loadData();
      } else {
        String errorMsg =
            resBody?['message']?.toString() ??
            'Lỗi từ Server (Mã: ${res.statusCode})';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xử lý thất bại: $errorMsg'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi sập mạng: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AdminLayout(
        title: 'Quản lý Lịch & Đặt phòng',
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      indicatorWeight: 3,
                      tabs: [
                        Tab(
                          text: 'Lịch sử dụng phòng',
                          icon: Icon(Icons.calendar_month),
                        ),
                        Tab(
                          text: 'Yêu cầu đặt phòng',
                          icon: Icon(Icons.notifications_active),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [_buildSchedulesTab(), _buildBookingTab()],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSchedulesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              _buildWeekNavigator(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _buildRoomSelector(),
                  _buildViewToggle(),
                  ElevatedButton.icon(
                    onPressed: () => _openAddScheduleModal(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Thêm thủ công',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showImportDialog(),
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text(
                      'Nhập CSV/Excel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _isGridView ? _buildTimetableGrid() : _buildListView()),
      ],
    );
  }

  Widget _buildWeekNavigator() {
    DateTime monday = _currentWeekDate.subtract(
      Duration(days: _currentWeekDate.weekday - 1),
    );
    DateTime sunday = monday.add(const Duration(days: 6));
    String weekStr =
        '${DateFormat('dd/MM').format(monday)} - ${DateFormat('dd/MM').format(sunday)}';

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.blue),
          onPressed: () => setState(
            () => _currentWeekDate = _currentWeekDate.subtract(
              const Duration(days: 7),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Tuần: $weekStr',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.blue),
          onPressed: () => setState(
            () => _currentWeekDate = _currentWeekDate.add(
              const Duration(days: 7),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.calendar_today, color: Colors.grey),
          tooltip: 'Trở về tuần hiện tại',
          onPressed: () => setState(() => _currentWeekDate = DateTime.now()),
        ),
      ],
    );
  }

  Widget _buildRoomSelector() {
    final validRooms = rooms
        .where((r) => r != null && r['id'] != null)
        .toList();

    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _selectedRoomId,
          hint: const Text('Chọn phòng máy'),
          items: validRooms
              .map((r) {
                int? parsedId = int.tryParse(r['id'].toString());
                return DropdownMenuItem<int>(
                  value: parsedId,
                  child: Text(
                    r['ten_phong']?.toString() ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              })
              .where((item) => item.value != null)
              .toList(),
          onChanged: (v) => setState(() => _selectedRoomId = v),
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleBtn(
            'Lưới',
            Icons.grid_view,
            _isGridView,
            () => setState(() => _isGridView = true),
          ),
          _buildToggleBtn(
            'Danh sách',
            Icons.format_list_bulleted,
            !_isGridView,
            () => setState(() => _isGridView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(
    String label,
    IconData icon,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.black54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FORM THÊM LỊCH THỦ CÔNG =================
  void _openAddScheduleModal() {
    int? formRoomId = _selectedRoomId;
    int? formModuleId;
    int formStartPeriod = 1;
    int formEndPeriod = 3;
    DateTime formDate = DateTime.now();
    String formType = 'Thực hành';
    int? formTeacherId; // Biến hứng ID giảng viên

    final validTeachers = teachers
        .where((t) => t != null && t['id'] != null)
        .toList();
    final validRooms = rooms
        .where((r) => r != null && r['id'] != null)
        .toList();
    final validModules = modules
        .where((m) => m != null && m['id'] != null)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Thêm lịch phòng thủ công',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 24),

                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Lớp học phần (*)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: validModules
                          .map(
                            (m) => DropdownMenuItem<int>(
                              value: int.tryParse(m['id'].toString()),
                              child: Text(
                                '${m['ma_lop_hoc_phan']} - ${m['ten_mon']}',
                              ),
                            ),
                          )
                          .where((item) => item.value != null)
                          .toList(),
                      onChanged: (v) => setModalState(() => formModuleId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Giảng viên (*)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: validTeachers
                          .map(
                            (t) => DropdownMenuItem<int>(
                              value: int.tryParse(t['id'].toString()),
                              child: Text(
                                t['ho_ten'] ?? t['ten_giang_vien'] ?? 'N/A',
                              ),
                            ),
                          )
                          .where((item) => item.value != null)
                          .toList(),
                      onChanged: (v) => setModalState(() => formTeacherId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: formRoomId,
                      decoration: InputDecoration(
                        labelText: 'Phòng máy (*)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: validRooms
                          .map(
                            (r) => DropdownMenuItem<int>(
                              value: int.tryParse(r['id'].toString()),
                              child: Text(r['ten_phong']?.toString() ?? 'N/A'),
                            ),
                          )
                          .where((item) => item.value != null)
                          .toList(),
                      onChanged: (v) => setModalState(() => formRoomId = v),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: formDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setModalState(() => formDate = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ngày học: ${DateFormat('dd/MM/yyyy').format(formDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: formStartPeriod,
                            decoration: InputDecoration(
                              labelText: 'Tiết bắt đầu',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: List.generate(
                              10,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('Tiết ${i + 1}'),
                              ),
                            ),
                            onChanged: (v) => setModalState(() {
                              formStartPeriod = v!;
                              if (formEndPeriod < formStartPeriod) {
                                formEndPeriod = formStartPeriod;
                              }
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: formEndPeriod,
                            decoration: InputDecoration(
                              labelText: 'Tiết kết thúc',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: List.generate(11 - formStartPeriod, (i) {
                              int validPeriod = formStartPeriod + i;
                              return DropdownMenuItem(
                                value: validPeriod,
                                child: Text('Tiết $validPeriod'),
                              );
                            }),
                            onChanged: (v) =>
                                setModalState(() => formEndPeriod = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: formType,
                      decoration: InputDecoration(
                        labelText: 'Loại lịch',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Lý thuyết',
                          child: Text('Lý thuyết'),
                        ),
                        DropdownMenuItem(
                          value: 'Thực hành',
                          child: Text('Thực hành'),
                        ),
                        DropdownMenuItem(
                          value: 'Học bù',
                          child: Text('Học bù'),
                        ),
                        DropdownMenuItem(
                          value: 'Thi',
                          child: Text('Thi/Kiểm tra'),
                        ),
                      ],
                      onChanged: (v) => setModalState(() => formType = v!),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (formModuleId == null || formRoomId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng chọn Phòng máy và Lớp học phần!',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (formEndPeriod < formStartPeriod) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tiết kết thúc không hợp lệ!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          String inputDateStr = DateFormat(
                            'yyyy-MM-dd',
                          ).format(formDate);

                          bool isOverlap = schedules.any((s) {
                            if (s['ma_phong'].toString() !=
                                formRoomId.toString())
                              return false;

                            String dbDateStr = '';
                            if (s['ngay_hoc_cu_the'] != null) {
                              DateTime? parsedDate = DateTime.tryParse(
                                s['ngay_hoc_cu_the'].toString(),
                              );
                              if (parsedDate != null) {
                                dbDateStr = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(parsedDate.toLocal());
                              }
                            }
                            if (dbDateStr != inputDateStr) return false;

                            int sStart =
                                int.tryParse(
                                  s['so_tiet_bat_dau']?.toString() ?? '0',
                                ) ??
                                0;
                            int sEnd =
                                int.tryParse(
                                  s['so_tiet_ket_thuc']?.toString() ?? '0',
                                ) ??
                                0;

                            if (formStartPeriod <= sEnd &&
                                formEndPeriod >= sStart) {
                              return true;
                            }

                            return false;
                          });

                          if (isOverlap) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '❌ Phòng này đã có lịch dạy trong thời gian này! Vui lòng đổi giờ.',
                                ),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 4),
                              ),
                            );
                            return;
                          }

                          final payload = {
                            'ma_phong': formRoomId,
                            'ma_lop_hoc_phan': formModuleId,
                            'ma_giang_vien': formTeacherId,
                            'ngay_hoc_cu_the': inputDateStr,
                            'so_tiet_bat_dau': formStartPeriod,
                            'so_tiet_ket_thuc': formEndPeriod,
                            'loai_lich': formType,
                            'thu_trong_tuan':
                                'Thứ ${formDate.weekday + 1 == 8 ? 'Chủ nhật' : formDate.weekday + 1}',
                          };

                          // 🚀 BẮT LỖI TẠI ĐÂY: KHÔNG CHO PHÉP FAKE SUCCESS
                          try {
                            final response = await ApiService.post(
                              '/schedule/lich-phong',
                              payload,
                            );
                            final resData = ApiService.decodeBody(response);

                            if (response.statusCode == 200 ||
                                response.statusCode == 201) {
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Thêm lịch thành công vào CSDL!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              if (mounted) Navigator.pop(ctx);
                              _loadData();
                            } else {
                              String errorMsg =
                                  resData?['message']?.toString() ??
                                  'Lỗi Database hoặc sai API (Mã: ${response.statusCode})';
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Thêm thất bại: $errorMsg'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sập mạng: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                          }
                        },
                        child: const Text(
                          'LƯU LỊCH PHÒNG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImportDialog() {
    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.upload_file, color: Colors.green),
                SizedBox(width: 8),
                Text('Nhập lịch từ file'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Hệ thống hỗ trợ tự động xếp lịch từ file Excel (.xlsx) hoặc CSV.',
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    try {
                      // Đã xóa chữ 'fp.' và '.platform', chỉ gọi trực tiếp FilePicker.pickFiles
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['csv', 'xlsx', 'xls'],
                      );

                      if (result != null) {
                        setDialogState(() {
                          selectedFile = result.files.first;
                        });
                      }
                    } catch (e) {
                      debugPrint('Lỗi chọn file: $e');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: selectedFile != null
                          ? Colors.green.shade50
                          : Colors.blue.shade50,
                      border: Border.all(
                        color: selectedFile != null
                            ? Colors.green.shade300
                            : Colors.blue.shade200,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          selectedFile != null
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          size: 48,
                          color: selectedFile != null
                              ? Colors.green
                              : Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedFile != null
                              ? selectedFile!.name
                              : 'Click để chọn file CSV/Excel',
                          style: TextStyle(
                            color: selectedFile != null
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: selectedFile == null
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đang xử lý file ${selectedFile!.name} lên hệ thống...',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                child: const Text(
                  'Tiến hành Nhập',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimetableGrid() {
    if (_selectedRoomId == null)
      return const Center(
        child: Text('Vui lòng chọn phòng máy để xem thời khóa biểu'),
      );

    DateTime monday = _currentWeekDate.subtract(
      Duration(days: _currentWeekDate.weekday - 1),
    );
    const double colWidth = 100.0;
    const double firstColWidth = 120.0;
    const double rowHeight = 85.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildHeaderCell('THỨ / NGÀY', firstColWidth, isFirst: true),
                  for (int i = 1; i <= 10; i++)
                    _buildHeaderCell('Tiết $i', colWidth),
                ],
              ),
              for (int d = 0; d < 7; d++)
                Builder(
                  builder: (context) {
                    DateTime currentDay = monday.add(Duration(days: d));
                    String dayName = d == 6 ? 'Chủ nhật' : 'Thứ ${d + 2}';
                    String dateStr = DateFormat(
                      'dd/MM/yyyy',
                    ).format(currentDay);
                    String dateDbStr = DateFormat(
                      'yyyy-MM-dd',
                    ).format(currentDay);

                    List<dynamic> daySchedules = schedules.where((s) {
                      bool matchRoom =
                          s['ma_phong'].toString() ==
                          _selectedRoomId.toString();
                      String dbDate = '';
                      if (s['ngay_hoc_cu_the'] != null) {
                        DateTime? parsedDate = DateTime.tryParse(
                          s['ngay_hoc_cu_the'].toString(),
                        );
                        if (parsedDate != null)
                          dbDate = DateFormat(
                            'yyyy-MM-dd',
                          ).format(parsedDate.toLocal());
                      }
                      return matchRoom && dbDate == dateDbStr;
                    }).toList();

                    return Row(
                      children: _buildRowCells(
                        dayName,
                        dateStr,
                        daySchedules,
                        firstColWidth,
                        colWidth,
                        rowHeight,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRowCells(
    String dayName,
    String dateStr,
    List<dynamic> daySchedules,
    double firstColWidth,
    double colWidth,
    double rowHeight,
  ) {
    List<Widget> cells = [];
    cells.add(
      Container(
        width: firstColWidth,
        height: rowHeight,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          border: Border(
            right: BorderSide(color: Colors.grey.shade300),
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    int currentPeriod = 1;
    while (currentPeriod <= 10) {
      final matches = daySchedules.where((s) {
        int start = int.tryParse(s['so_tiet_bat_dau']?.toString() ?? '0') ?? 0;
        int end = int.tryParse(s['so_tiet_ket_thuc']?.toString() ?? '0') ?? 0;
        return currentPeriod >= start && currentPeriod <= end;
      }).toList();

      if (matches.isNotEmpty) {
        final matchSchedule = matches.first;
        int start =
            int.tryParse(matchSchedule['so_tiet_bat_dau']?.toString() ?? '0') ??
            0;
        int end =
            int.tryParse(
              matchSchedule['so_tiet_ket_thuc']?.toString() ?? '0',
            ) ??
            0;

        if (currentPeriod == start) {
          int span = (end - start) + 1;
          cells.add(
            _buildScheduleBlock(matchSchedule, span * colWidth, rowHeight),
          );
          currentPeriod = end + 1;
        } else {
          currentPeriod++;
        }
      } else {
        cells.add(
          Container(
            width: colWidth,
            height: rowHeight,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.shade200),
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        );
        currentPeriod++;
      }
    }
    return cells;
  }

  Widget _buildScheduleBlock(dynamic schedule, double width, double height) {
    String loaiLich = schedule['loai_lich']?.toString() ?? '';
    Color bgColor = Colors.blue.shade50;
    Color textColor = Colors.blue.shade900;

    if (loaiLich.toLowerCase().contains('thuchanh')) {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade900;
    }
    if (loaiLich.toLowerCase().contains('hocbu')) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade900;
    }

    String className = schedule['ma_lop'] ?? schedule['ma_lhp_str'] ?? '';
    String gvName = schedule['ten_giang_vien'] ?? 'Chưa phân công';

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${schedule['ten_mon']}${className.isNotEmpty ? ' - $className' : ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'GV: $gvName',
              style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.8)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              loaiLich.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: textColor.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width, {bool isFirst = false}) {
    return Container(
      width: width,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildListView() {
    DateTime monday = _currentWeekDate.subtract(
      Duration(days: _currentWeekDate.weekday - 1),
    );
    DateTime sunday = monday.add(
      const Duration(days: 6, hours: 23, minutes: 59),
    );

    List<dynamic> filteredSchedules = schedules.where((s) {
      if (_selectedRoomId != null &&
          s['ma_phong'].toString() != _selectedRoomId.toString())
        return false;
      try {
        DateTime date = DateTime.parse(
          s['ngay_hoc_cu_the'].toString(),
        ).toLocal();
        return date.isAfter(monday.subtract(const Duration(days: 1))) &&
            date.isBefore(sunday);
      } catch (e) {
        return false;
      }
    }).toList();

    if (filteredSchedules.isEmpty)
      return const Center(
        child: Text(
          'Không có lịch học nào trong tuần này.',
          style: TextStyle(color: Colors.grey),
        ),
      );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSchedules.length,
      itemBuilder: (context, index) {
        final s = filteredSchedules[index];
        final ngayHoc = s['ngay_hoc_cu_the'] != null
            ? DateFormat(
                'dd/MM/yyyy',
              ).format(DateTime.parse(s['ngay_hoc_cu_the']).toLocal())
            : '';
        String className = s['ma_lop'] ?? s['ma_lhp_str'] ?? 'Chưa gán lớp';
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              radius: 25,
              child: const Icon(Icons.class_, color: Colors.blue),
            ),
            title: Text(
              '${s['ten_mon']} - Lớp: $className',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Phòng: ${s['ten_phong']} | GV: ${s['ten_giang_vien']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Thời gian: ${s['thu_trong_tuan']}, $ngayHoc (Tiết ${s['so_tiet_bat_dau']} - ${s['so_tiet_ket_thuc']})',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                s['loai_lich'] ?? '',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: bookingRequests.isEmpty
          ? const Center(
              child: Text(
                'Không có yêu cầu đặt phòng nào.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: bookingRequests.length,
              itemBuilder: (context, index) {
                final b = bookingRequests[index];
                String status =
                    b['trang_thai_duyet']?.toString().toLowerCase() ??
                    'pending';
                final ngayDat = b['ngay_dat'] != null
                    ? DateFormat(
                        'dd/MM/yyyy',
                      ).format(DateTime.parse(b['ngay_dat']).toLocal())
                    : '';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                b['ten_phong'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(status),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Người đặt: ${b['nguoi_dat'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Thời gian: Ngày $ngayDat (Tiết ${b['tiet_bat_dau']} - ${b['tiet_ket_thuc']})',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Mục đích: ${b['muc_dich'] ?? 'Không có'}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (status == 'pending') ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _updateBookingStatus(
                                  int.parse(b['id'].toString()),
                                  'rejected',
                                ),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Từ chối',
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _updateBookingStatus(
                                  int.parse(b['id'].toString()),
                                  'approved',
                                ),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Duyệt ngay',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;
    switch (status) {
      case 'approved':
        bg = Colors.green.shade50;
        text = Colors.green.shade700;
        label = 'ĐÃ DUYỆT';
        break;
      case 'rejected':
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        label = 'TỪ CHỐI';
        break;
      default:
        bg = Colors.orange.shade50;
        text = Colors.orange.shade800;
        label = 'CHỜ DUYỆT';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}
