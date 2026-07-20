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
  
  // 🚀 Đã đổi về int để chuẩn cấu trúc CSDL
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

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
    // ---------------------------------------------------------
    // 🚀🚀🚀 KHU VỰC ĐẶT CAMERA BẮT LỖI
    // ---------------------------------------------------------
    print("👉👉👉 [DEBUG] Bắt đầu hàm _submitReport. Bác vừa bấm nút Gửi!");

    if (!_formKey.currentState!.validate() || _selectedComputerId == null) {
      print("❌❌❌ [DEBUG] BỊ CHẶN: Chưa điền đủ form hoặc chưa chọn máy!");
      print("👉 Form Validate: ${_formKey.currentState?.validate()} | ID Máy: $_selectedComputerId");
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đầy đủ thông tin máy lỗi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print("👉👉👉 [DEBUG] Form OK. Đang lấy dữ liệu User từ Provider...");
    final user = context.read<LoginViewModel>().currentUser;
    
    print("👉👉👉 [DEBUG] Dữ liệu User lấy ra là: $user");

    if (user == null) {
      print("💀💀💀 [DEBUG] CHẾT CHỖ NÀY! Biến user bị NULL, hàm bị ngắt, API KHÔNG ĐƯỢC GỌI!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('LỖI: Mất dữ liệu phiên đăng nhập. Vui lòng đăng nhập lại!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("👉👉👉 [DEBUG] Chuẩn bị gọi API với userID = ${user.id}, máyID = $_selectedComputerId");
    
    final success = await context.read<IssueViewModel>().sendIssueReport(
      maNguoiBaoCao: user.id,
      maMayTinh: _selectedComputerId!, 
      loaiSuCo: _selectedType,
      tieuDe: _titleCtrl.text,
      moTa: _descCtrl.text,
      mucDo: _selectedSeverity,
    );

    print("👉👉👉 [DEBUG] Kết quả trả về từ API Backend: $success");
    // ---------------------------------------------------------

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi báo cáo lỗi thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi gửi báo cáo, vui lòng thử lại!'),
          backgroundColor: Colors.red,
        ),
      );
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
        elevation: 0,
      ),
      body: issueVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text('Thông tin thiết bị', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    // CHỌN PHÒNG MÁY
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Chọn phòng học',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      initialValue: _selectedRoomId,
                      items: _rooms.map((r) => DropdownMenuItem<int>(
                              value: int.tryParse(r['id']?.toString() ?? '') ?? 0,
                              child: Text(r['ten_phong']?.toString() ?? ''),
                            )).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedRoomId = val;
                          _selectedComputerId = null; // 🚀 Reset ID máy tính khi đổi phòng
                        });
                        if (val != null) {
                          context.read<IssueViewModel>().fetchComputers(val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // CHỌN MÁY TÍNH BỊ LỖI
                    DropdownButtonFormField<int>( 
                      decoration: InputDecoration(
                        labelText: 'Chọn máy tính bị lỗi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      initialValue: _selectedComputerId,
                      items: issueVM.computers.map((c) {
                        final int parsedId = int.tryParse(c['id']?.toString() ?? '') ?? 0;
                        return DropdownMenuItem<int>(
                          value: parsedId,
                          child: Text('${c['ten_may']} (${c['ma_may']})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedComputerId = val),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text('Chi tiết sự cố', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),

                    // CHỌN LOẠI SỰ CỐ
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Loại sự cố',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      initialValue: _selectedType,
                      items: [
                        'Phần cứng',
                        'Phần mềm',
                        'Mạng internet',
                        'Thiết bị ngoại vi',
                      ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                    const SizedBox(height: 16),

                    // MỨC ĐỘ NGUY HIỂM
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Mức độ nghiêm trọng',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      initialValue: _selectedSeverity,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Thấp (Vẫn dùng được)')),
                        DropdownMenuItem(value: 'normal', child: Text('Bình thường')),
                        DropdownMenuItem(value: 'high', child: Text('Cao (Hỏng hẳn/Không thể học)')),
                      ],
                      onChanged: (val) => setState(() => _selectedSeverity = val!),
                    ),
                    const SizedBox(height: 16),

                    // TIÊU ĐỀ LỖI
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề sự cố',
                        hintText: 'Ví dụ: Máy không lên màn hình',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) => v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                    ),
                    const SizedBox(height: 16),

                    // MÔ TẢ CHI TIẾT
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Mô tả chi tiết tình trạng',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // NÚT GỬI
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF193D87),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _submitReport,
                        child: const Text(
                          'Gửi Báo Cáo',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}