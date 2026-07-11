import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';
import 'package:flutter_phongmay/presentation/screens/admin/select_machine_to_borrow_screen.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

// THÊM IMPORT TRANG LỊCH SỬ MƯỢN MÁY CỦA BÁC VÀO ĐÂY
import 'package:flutter_phongmay/presentation/screens/admin/borrow_machine_history_screen.dart';

const Color kAppBlue = Color(0xFF193D87);

class BorrowMachineScreen extends StatefulWidget {
  const BorrowMachineScreen({super.key});

  @override
  State<BorrowMachineScreen> createState() => _BorrowMachineScreenState();
}

class _BorrowMachineScreenState extends State<BorrowMachineScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nguoiMuonCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController(text: '1');
  final TextEditingController _reasonCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _phongBanList = [];
  int? _selectedPhongBanId;
  bool _isLoadingDepartments = true;

  @override
  void initState() {
    super.initState();
    _fetchDepartments(); 
  }

  @override
  void dispose() {
    _nguoiMuonCtrl.dispose();
    _quantityCtrl.dispose();
    _reasonCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    try {
      final res = await ApiService.get('/phong-ban');
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body['success'] == true) {
          setState(() {
            _phongBanList = List<Map<String, dynamic>>.from(body['data']);
            _isLoadingDepartments = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi lấy danh sách phòng ban: $e');
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kAppBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _goToStep2SelectMachine() {
    if (!_formKey.currentState!.validate()) return;

    final phieuMuonData = {
      'nguoi_muon': _nguoiMuonCtrl.text.trim(),
      'ma_phong_ban': _selectedPhongBanId,
      'so_luong': int.parse(_quantityCtrl.text.trim()),
      'ly_do_muon': _reasonCtrl.text.trim(),
      'ghi_chu': _noteCtrl.text.trim(),
      'ngay_muon': DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate),
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMachineToBorrowScreen(ticketData: phieuMuonData),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang chuyển sang bước Chọn máy tính...'),
        backgroundColor: kAppBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Tạo phiếu mượn máy',
      
      // ==============================================================
      // GẮN NÚT LỊCH SỬ VÀ ĐIỀU HƯỚNG SANG BORROW_MACHINE_HISTORY_SCREEN
      // ==============================================================
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Lịch sử mượn máy',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BorrowMachineHistoryScreen(),
              ),
            );
          },
        ),
      ],
      // ==============================================================

      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin người mượn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kAppBlue,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nguoiMuonCtrl,
                  decoration: InputDecoration(
                    labelText: 'Họ tên người mượn (SV/GV) *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập người mượn'
                      : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Khoa / Phòng ban *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.domain),
                  ),
                  initialValue: _selectedPhongBanId,
                  hint: const Text('Chọn khoa/phòng ban'),
                  items: _phongBanList.map((pb) {
                    return DropdownMenuItem<int>(
                      value: pb['id'],
                      child: Text(pb['ten_phong_ban']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedPhongBanId = val),
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn khoa' : null,
                ),
                const SizedBox(height: 24),

                const Divider(height: 1, color: Colors.black12),
                const SizedBox(height: 20),

                const Text(
                  'Chi tiết phiếu mượn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kAppBlue,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Ngày mượn',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, color: kAppBlue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _quantityCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Số lượng máy tính/thiết bị cần mượn *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.devices),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Nhập số lượng';
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Số lượng phải lớn hơn 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Lý do mượn *',
                    hintText: 'VD: Dùng cho thực hành môn học...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập lý do'
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú thêm (Không bắt buộc)',
                    hintText: 'VD: Kèm theo chuột, bàn phím...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAppBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _goToStep2SelectMachine,
                    child: const Text(
                      'Tiếp tục (Chọn máy)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}