import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class AcademicYearTab extends StatefulWidget {
  const AcademicYearTab({Key? key}) : super(key: key);

  @override
  State<AcademicYearTab> createState() => _AcademicYearTabState();
}

class _AcademicYearTabState extends State<AcademicYearTab> {
  final Color primaryNavy = const Color(0xFF193D87);
  bool _isLoading = true;
  List<dynamic> _years = [];
  String _statusFilter = 'all'; // all, active, pending, inactive

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/nam-hoc');
      setState(() {
        _years = ApiService.decodeBody(res)?['data'] ?? [];
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
    setState(() => _isLoading = false);
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      // Đã sửa 'dateString' thành 'dateStr' và thêm .toString() cho an toàn
      final dt = DateTime.parse(dateStr.toString()).toLocal();
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (_) {
      return dateStr.toString();
    }
  }

  // Hiển thị Bottom Sheet tạo/sửa Năm Học
  void _showFormBottomSheet([Map<String, dynamic>? yearData]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: AddYearForm(
          initialData: yearData,
          onSuccess: _loadData,
        ),
      ),
    );
  }

  // Hiển thị Bottom Sheet Danh sách tuần học
  void _showWeeksBottomSheet(int maNamHoc, String tenNamHoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WeekListSheet(maNamHoc: maNamHoc, tenNamHoc: tenNamHoc),
    );
  }

  Future<void> _deleteYear(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Xóa năm học sẽ xóa luôn toàn bộ tuần học bên trong. Tiếp tục?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.delete('/nam-hoc/$id');
        _loadData();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Xóa thành công'), backgroundColor: Colors.green));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _years.where((y) => _statusFilter == 'all' || y['trang_thai'] == _statusFilter).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Bộ lọc và Nút thêm (Phong cách Mobile)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10), color: Colors.white),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _statusFilter,
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                          DropdownMenuItem(value: 'active', child: Text('Đang diễn ra')),
                          DropdownMenuItem(value: 'pending', child: Text('Sắp diễn ra')),
                          DropdownMenuItem(value: 'inactive', child: Text('Đã kết thúc')),
                        ],
                        onChanged: (val) => setState(() => _statusFilter = val!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () => _showFormBottomSheet(),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('Không có dữ liệu năm học.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final year = filtered[i];
                          Color badgeColor = year['trang_thai'] == 'active' ? Colors.green : (year['trang_thai'] == 'pending' ? Colors.orange : Colors.grey);
                          String badgeText = year['trang_thai'] == 'active' ? 'Đang diễn ra' : (year['trang_thai'] == 'pending' ? 'Sắp diễn ra' : 'Đã kết thúc');

                          return Card(
                            elevation: 1, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(year['ten_nam_hoc'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryNavy)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                        child: Text(badgeText, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.date_range, size: 16, color: Colors.grey.shade600), const SizedBox(width: 8),
                                      Text('${_formatDate(year['ngay_bat_dau'])} - ${_formatDate(year['ngay_ket_thuc'])}', style: TextStyle(color: Colors.grey.shade700)),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton.icon(
                                        onPressed: () => _showWeeksBottomSheet(year['id'], year['ten_nam_hoc']),
                                        icon: const Icon(Icons.view_week, size: 18), label: const Text('Xem Tuần'),
                                      ),
                                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _deleteYear(year['id'])),
                                    ],
                                  )
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

// =====================================
// BOTTOM SHEET: FORM THÊM NĂM HỌC
// =====================================
class AddYearForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final VoidCallback onSuccess;
  const AddYearForm({Key? key, this.initialData, required this.onSuccess}) : super(key: key);

  @override
  State<AddYearForm> createState() => _AddYearFormState();
}

class _AddYearFormState extends State<AddYearForm> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryNavy = const Color(0xFF193D87);
  
  final _nameCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _status = 'pending';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thêm Năm Học', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryNavy)),
            const SizedBox(height: 8),
            Text('Hệ thống sẽ tự động chia tuần học dựa trên khoảng thời gian bạn chọn.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic)),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _nameCtrl, decoration: InputDecoration(labelText: 'Tên năm học (VD: 2024-2025)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setState(() => _startDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                      child: Text(_startDate == null ? 'Ngày bắt đầu' : DateFormat('dd/MM/yyyy').format(_startDate!)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final d = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (d != null) setState(() => _endDate = d);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                      child: Text(_endDate == null ? 'Ngày kết thúc' : DateFormat('dd/MM/yyyy').format(_endDate!)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status, decoration: InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Sắp diễn ra')),
                DropdownMenuItem(value: 'active', child: Text('Đang diễn ra')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (_startDate == null || _endDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc!'), backgroundColor: Colors.red)
                      );
                      return;
                    }
                    if (_endDate!.isBefore(_startDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu!'), backgroundColor: Colors.red)
                      );
                      return;
                    }

                    try {
                      final response = await ApiService.post('/nam-hoc', {
                        'ten_nam_hoc': _nameCtrl.text.trim(),
                        'ngay_bat_dau': DateFormat('yyyy-MM-dd').format(_startDate!),
                        'ngay_ket_thuc': DateFormat('yyyy-MM-dd').format(_endDate!),
                        'trang_thai': _status
                      });

                      final responseData = ApiService.decodeBody(response); 
                      
                      // ĐÃ SỬA: Chỉ khi success == true VÀ statusCode là 200 mới tính là thành công
                      if (response != null && (response.statusCode == 200 || response.statusCode == 201) && responseData?['success'] == true) {
                        widget.onSuccess();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tạo năm học thành công!'), backgroundColor: Colors.green)
                          );
                        }
                      } else {
                        // Backend có lỗi -> Báo màu đỏ ngay lập tức
                        final errorMsg = responseData?['message'] ?? 'Lỗi hệ thống hoặc Database Backend';
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Thất bại: $errorMsg'), backgroundColor: Colors.red)
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi kết nối: $e'), backgroundColor: Colors.red)
                      );
                    }
                  }
                },
                child: const Text('Lưu & Tự động tạo Tuần', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// =====================================
// BOTTOM SHEET: XEM DANH SÁCH TUẦN
// =====================================
class WeekListSheet extends StatefulWidget {
  final int maNamHoc;
  final String tenNamHoc;
  const WeekListSheet({Key? key, required this.maNamHoc, required this.tenNamHoc}) : super(key: key);

  @override
  State<WeekListSheet> createState() => _WeekListSheetState();
}

class _WeekListSheetState extends State<WeekListSheet> {
  bool _isLoading = true;
  List<dynamic> _weeks = [];

  @override
  void initState() {
    super.initState();
    _fetchWeeks();
  }

  Future<void> _fetchWeeks() async {
    try {
      final res = await ApiService.get('/tuan/${widget.maNamHoc}');
      setState(() => _weeks = ApiService.decodeBody(res)?['data'] ?? []);
    } catch (e) {
      debugPrint('Lỗi tải tuần: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tuần học - ${widget.tenNamHoc}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _weeks.isEmpty
                    ? const Center(child: Text('Chưa có dữ liệu tuần học.'))
                    : ListView.builder(
                        itemCount: _weeks.length,
                        itemBuilder: (ctx, i) {
                          final w = _weeks[i];
                          final start = DateFormat('dd/MM/yyyy').format(DateTime.parse(w['ngay_bat_dau']));
                          final end = DateFormat('dd/MM/yyyy').format(DateTime.parse(w['ngay_ket_thuc']));
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: const Color(0xFF193D87).withOpacity(0.1), child: Text('${w['so_tuan']}')),
                            title: Text('Tuần ${w['so_tuan']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('$start - $end'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}