import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/return_machine_history_screen.dart';

const Color kAppGreen = Color(0xFF2E7D32);

class ReturnMachineScreen extends StatefulWidget {
  const ReturnMachineScreen({super.key});

  @override
  State<ReturnMachineScreen> createState() => _ReturnMachineScreenState();
}

class _ReturnMachineScreenState extends State<ReturnMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoadingReceipts = true;
  DateTime _selectedDate = DateTime.now();

  List<dynamic> _activeBorrowReceipts = [];
  dynamic _selectedReceipt;

  @override
  void initState() {
    super.initState();
    _fetchActiveReceipts();
  }

  Future<void> _fetchActiveReceipts() async {
    final user = context.read<LoginViewModel>().currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingReceipts = false);
      return;
    }
    try {
      // Nhớ dùng đúng API route của danh sách mượn
      final res = await ApiService.get(
        '/borrow-machine/history?nguoi_dung_id=${user.id}',
      );
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          final allReceipts = List<dynamic>.from(body['data'] ?? []);
          if (mounted) {
            setState(() {
              _activeBorrowReceipts = allReceipts.where((item) {
                final status = (item['trang_thai'] ?? '')
                    .toString()
                    .toLowerCase();
                final soLuongConLai =
                    int.tryParse(item['so_luong'].toString()) ?? 0;
                return (status.contains('đang mượn') ||
                        status.contains('chờ duyệt trả')) &&
                    soLuongConLai > 0;
              }).toList();
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải phiếu mượn: $e');
    } finally {
      if (mounted) setState(() => _isLoadingReceipts = false);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: kAppGreen)),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitReturnRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final user = context.read<LoginViewModel>().currentUser;

    try {
      final res = await ApiService.post('/tra-thiet-bi', {
        'nguoi_dung_id': user?.id,
        'ma_phieu_muon_id': _selectedReceipt['id'],
        'so_luong': int.parse(_quantityCtrl.text),
        'ghi_chu': _noteCtrl.text,
        'thoi_gian_tra': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(_selectedDate),
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã gửi yêu cầu trả thiết bị!'),
              backgroundColor: kAppGreen,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Lỗi Server');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi gửi yêu cầu.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trả Máy / Thiết Bị',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kAppGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Lịch sử trả máy',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReturnMachineHistoryScreen(),
                ),
              ).then((_) {
                // 🚀 Cốt lõi nằm ở đây: Gọi lại hàm này khi màn hình history đóng lại
                _fetchActiveReceipts();
              });
            },
          ),
        ],
      ),
      body: _isLoadingReceipts
          ? const Center(child: CircularProgressIndicator(color: kAppGreen))
          : _activeBorrowReceipts.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn phiếu cần trả *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<dynamic>(
                      value: _selectedReceipt,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(
                          Icons.receipt_long,
                          color: kAppGreen,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      hint: const Text('Nhấn để chọn phiếu mượn'),
                      items: _activeBorrowReceipts.map((receipt) {
                        // Lấy số lượng còn nợ từ receipt['so_luong']
                        int soLuongConLai = receipt['so_luong'];
                        String ngayMuon = DateFormat('dd/MM').format(
                          DateTime.parse(receipt['ngay_muon']).toLocal(),
                        );

                        return DropdownMenuItem<dynamic>(
                          value: receipt,
                          child: Text(
                            // Hiển thị số lượng còn nợ cho người dùng thấy
                            '${receipt['ma_phieu_muon']} (Mượn $ngayMuon - Còn nợ: $soLuongConLai)',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedReceipt = value;
                          _quantityCtrl.text = value['so_luong'].toString();
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Vui lòng chọn phiếu mượn' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số lượng thiết bị trả thực tế *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.devices),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nhập số lượng';
                        final intVal = int.tryParse(value);
                        if (intVal == null || intVal <= 0)
                          return 'Số lượng phải lớn hơn 0';
                        if (_selectedReceipt != null) {
                          final soLuongMuon = _selectedReceipt['so_luong'];
                          if (intVal > soLuongMuon)
                            return 'Không thể trả vượt quá số lượng đã mượn ($soLuongMuon)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ngày trả thực tế',
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
                            const Icon(Icons.calendar_today, color: kAppGreen),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Ghi chú / Tình trạng máy khi trả',
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
                          backgroundColor: kAppGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitReturnRequest,
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Xác nhận Trả Máy',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bạn không có thiết bị nào đang mượn!',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
