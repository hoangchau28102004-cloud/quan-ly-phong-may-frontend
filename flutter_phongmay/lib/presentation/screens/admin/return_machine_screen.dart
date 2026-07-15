import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';
import 'package:flutter_phongmay/presentation/screens/admin/return_machine_history_screen.dart';

const Color kAppBlue = Color(0xFF193D87);

class ReturnMachineScreen extends StatefulWidget {
  const ReturnMachineScreen({super.key});

  @override
  State<ReturnMachineScreen> createState() => _ReturnMachineScreenState();
}

class _ReturnMachineScreenState extends State<ReturnMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoadingReceipts = true;
  bool _isLoadingDetails = false;
  DateTime _selectedDate = DateTime.now();

  List<dynamic> _activeBorrowReceipts = [];
  int? _selectedReceiptId;

  List<dynamic> _borrowedMachines = [];
  Set<String> _selectedMachineIds = {};

  @override
  void initState() {
    super.initState();
    _fetchActiveReceipts();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchActiveReceipts() async {
    try {
      final res = await ApiService.get('/borrow-return/muon-may');
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
                return status.contains('đang mượn');
              }).toList();

              // LOGIC CẬP NHẬT UI THÔNG MINH KHI TRẢ 1 PHẦN NẰM Ở ĐÂY
              if (_selectedReceiptId != null) {
                // Tìm lại cái phiếu đang được chọn trong danh sách mới kéo về
                final currentReceipt = _activeBorrowReceipts.firstWhere(
                  (r) =>
                      (int.tryParse(r['id'].toString()) ?? 0) ==
                      _selectedReceiptId,
                  orElse: () => null,
                );

                if (currentReceipt == null) {
                  // Nếu không tìm thấy (tức là đã trả hết, phiếu đóng rồi) -> Reset sạch sẽ
                  _selectedReceiptId = null;
                  _borrowedMachines.clear();
                  _selectedMachineIds.clear();
                } else {
                  // Nếu tìm thấy (tức là mới trả 1 phần, phiếu vẫn mở) -> Cập nhật lại list máy mới nhất
                  if (currentReceipt['danh_sach_may'] != null) {
                    _borrowedMachines = List<dynamic>.from(
                      currentReceipt['danh_sach_may'],
                    );
                  } else {
                    _borrowedMachines.clear();
                  }
                  // Xóa các tick chọn của lần thao tác trước để user thao tác tiếp
                  _selectedMachineIds.clear();
                }
              }
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi Server: ${res.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải phiếu mượn: $e');
    } finally {
      if (mounted) setState(() => _isLoadingReceipts = false);
    }
  }

  void _fetchTicketDetails(int ticketId) {
    setState(() {
      _isLoadingDetails = true;
      _borrowedMachines.clear();
      _selectedMachineIds.clear();
    });

    final selectedReceipt = _activeBorrowReceipts.firstWhere(
      (r) => (int.tryParse(r['id'].toString()) ?? 0) == ticketId,
      orElse: () => null,
    );

    if (selectedReceipt != null && selectedReceipt['danh_sach_may'] != null) {
      setState(() {
        _borrowedMachines = List<dynamic>.from(
          selectedReceipt['danh_sach_may'],
        );
      });
    }

    setState(() => _isLoadingDetails = false);
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
          ).copyWith(colorScheme: const ColorScheme.light(primary: kAppBlue)),
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

    if (_selectedMachineIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng tick chọn ít nhất 1 máy để trả!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await ApiService.post('/borrow-return/tra-may', {
        'ma_phieu_muon_id': _selectedReceiptId,
        'machine_ids': _selectedMachineIds.toList(),
        'ghi_chu': _noteCtrl.text,
        'thoi_gian_tra': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(_selectedDate),
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xác nhận trả thiết bị!'),
              backgroundColor: kAppBlue,
            ),
          );

          // QUAN TRỌNG: Phải await chờ lấy data mới về thì UI mới vẽ lại chuẩn
          await _fetchActiveReceipts();

          setState(() {
            _noteCtrl.clear();
          });
        }
      } else {
        throw Exception('Lỗi Server: ${res.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi yêu cầu: $e'),
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
    return AdminLayout(
      title: 'Tạo phiếu trả máy ',
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'Lịch sử trả máy',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReturnMachineHistoryScreen(),
              ),
            ).then((_) {
              _fetchActiveReceipts();
            });
          },
        ),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _isLoadingReceipts
            ? const Center(child: CircularProgressIndicator(color: kAppBlue))
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

                      DropdownButtonFormField<int>(
                        initialValue: _selectedReceiptId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(
                            Icons.receipt_long,
                            color: kAppBlue,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        isExpanded: true,
                        hint: const Text('Nhấn để chọn phiếu mượn'),
                        items: _activeBorrowReceipts.map<DropdownMenuItem<int>>((
                          receipt,
                        ) {
                          int soLuongConLai =
                              int.tryParse(
                                receipt['so_luong']?.toString() ?? '0',
                              ) ??
                              0;
                          String ngayMuon = 'N/A';
                          if (receipt['ngay_muon'] != null) {
                            try {
                              ngayMuon = DateFormat('dd/MM').format(
                                DateTime.parse(receipt['ngay_muon']).toLocal(),
                              );
                            } catch (_) {}
                          }

                          int pId = int.tryParse(receipt['id'].toString()) ?? 0;

                          return DropdownMenuItem<int>(
                            value: pId,
                            child: Text(
                              '${receipt['ma_phieu_muon']} (Mượn $ngayMuon - Nợ: $soLuongConLai)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != _selectedReceiptId) {
                            setState(() {
                              _selectedReceiptId = value;
                            });
                            if (value != null) {
                              _fetchTicketDetails(value);
                            }
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Vui lòng chọn phiếu mượn' : null,
                      ),

                      const SizedBox(height: 24),

                      if (_selectedReceiptId != null) ...[
                        const Text(
                          'Chọn các máy muốn trả *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingDetails)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(color: kAppBlue),
                            ),
                          )
                        else if (_borrowedMachines.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Phiếu này không có thiết bị nào (Phiếu rỗng)',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _borrowedMachines.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final machine = _borrowedMachines[index];
                                final String mId = machine['ma_may'].toString();
                                final bool isSelected = _selectedMachineIds
                                    .contains(mId);

                                return CheckboxListTile(
                                  title: Text(
                                    '${machine['ma_may']} - ${machine['ten_may']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    'Tình trạng: ${machine['tinh_trang'] ?? 'Bình thường'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: isSelected,
                                  activeColor: kAppBlue,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (bool? val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedMachineIds.add(mId);
                                      } else {
                                        _selectedMachineIds.remove(mId);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Đã chọn trả: ${_selectedMachineIds.length} máy',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: kAppBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],

                      const SizedBox(height: 24),
                      const Text(
                        'Ngày trả',
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
                            color: Colors.white,
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
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _noteCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Ghi chú / Tình trạng',
                          filled: true,
                          fillColor: Colors.white,
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
                          onPressed: _isSubmitting
                              ? null
                              : _submitReturnRequest,
                          child: _isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Xác nhận Trả Máy',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
