import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/issue_viewmodel.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _rooms = [];
  int? _selectedRoomId;
  
int? _selectedComputerId;

  String _selectedType = 'Phần cứng';
  String _selectedSeverity = 'normal';

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final res = await ApiService.get('/phong-may');
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          setState(() => _rooms = body['data'] ?? []);
        }
      }
    } catch (e) {
      debugPrint('Lỗi load phòng: $e');
    }
  }
void _submitReport() async {
    // 🚀 Check biến ID mới
    if (!_formKey.currentState!.validate() || _selectedComputerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ thông tin máy lỗi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = context.read<LoginViewModel>().currentUser;
    if (user == null) return;

    final success = await context.read<IssueViewModel>().sendIssueReport(
      maNguoiBaoCao: user.id,
      maMayTinh: _selectedComputerId!, // 🚀 TRUYỀN ĐÚNG SỐ INT XUỐNG BACKEND
      loaiSuCo: _selectedType,
      tieuDe: _titleCtrl.text,
      moTa: _descCtrl.text,
      mucDo: _selectedSeverity,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi báo cáo lỗi thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final issueVM = context.watch<IssueViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo Sự Cố Máy Tính'),
        backgroundColor: const Color(0xFF193D87),
        foregroundColor: Colors.white,
      ),
      body: issueVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // CHỌN PHÒNG MÁY
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Chọn phòng học'),
                      value: _selectedRoomId, // Dùng value thay vì initialValue
                      items: _rooms.map((r) => DropdownMenuItem<int>(
                              value: r['id'],
                              child: Text(r['ten_phong']),
                            )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedRoomId = val;
                          _selectedComputerId = null; // 🚀 Reset biến ID khi đổi phòng
                        });
                        if (val != null) {
                          context.read<IssueViewModel>().fetchComputers(val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // CHỌN MÁY TÍNH BỊ LỖI
                    DropdownButtonFormField<int>( 
                      decoration: const InputDecoration(labelText: 'Chọn máy tính bị lỗi'),
                      value: _selectedComputerId, 
                      items: issueVM.computers.map((c) {
                        // 🚀 BỌC THÉP ÉP KIỂU: Chống sập app khi ID là String
                        final int parsedId = int.tryParse(c['id']?.toString() ?? '') ?? 0;
                        
                        return DropdownMenuItem<int>(
                          value: parsedId, 
                          child: Text('${c['ten_may']} (${c['ma_may']})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedComputerId = val),
                    ),
                    const SizedBox(height: 12),

                    // CHỌN LOẠI SỰ CỐ
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Loại sự cố',
                      ),
                      initialValue: _selectedType,
                      items:
                          [
                                'Phần cứng',
                                'Phần mềm',
                                'Mạng internet',
                                'Thiết bị ngoại vi',
                              ]
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                    const SizedBox(height: 12),

                    // MỨC ĐỘ NGUY HIỂM
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Mức độ nghiêm trọng',
                      ),
                      initialValue: _selectedSeverity,
                      items: const [
                        DropdownMenuItem(
                          value: 'low',
                          child: Text('Thấp (Vẫn dùng được)'),
                        ),
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Bình thường'),
                        ),
                        DropdownMenuItem(
                          value: 'high',
                          child: Text('Cao (Hỏng hẳn/Không thể học)'),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedSeverity = val!),
                    ),
                    const SizedBox(height: 12),

                    // TIÊU ĐỀ LỖI
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề sự cố',
                        hintText: 'Ví dụ: Máy không lên màn hình',
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                    ),
                    const SizedBox(height: 12),

                    // MÔ TẢ CHI TIẾT
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả chi tiết tình trạng',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // NÚT GỬI
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF193D87),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submitReport,
                      child: const Text(
                        'Gửi Báo Cáo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}