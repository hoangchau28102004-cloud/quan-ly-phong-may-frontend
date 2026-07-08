import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import các ViewModel đang được gọi trong hàm _submitReport
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/issue_viewmodel.dart';

class StudentReportIncidentScreen extends StatefulWidget {
  final String machineId;
  final String machineName;

  const StudentReportIncidentScreen({
    Key? key,
    required this.machineId,
    required this.machineName,
  }) : super(key: key);

  @override
  State<StudentReportIncidentScreen> createState() =>
      _StudentReportIncidentScreenState();
}

class _StudentReportIncidentScreenState
    extends State<StudentReportIncidentScreen> {
  final Color primaryNavy = const Color(0xFF1E3A8A);
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  String _selectedIssueType = 'Phần cứng (Hardware)';

  final List<String> _issueTypes = [
    'Phần cứng (Hardware)',
    'Phần mềm (Software)',
    'Mất/Thiếu thiết bị',
    'Mạng / Internet',
    'Khác',
  ];

  @override
  void dispose() {
    _descController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    if (_titleController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đủ Tiêu đề và Mô tả sự cố!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final issueVM = context.read<IssueViewModel>();
    
    // Tận dụng chuỗi string thay vì ép kiểu int.tryParse()
    final String scannedCode = (widget.machineName.isNotEmpty && widget.machineName != 'null') 
        ? widget.machineName 
        : widget.machineId;

    final success = await issueVM.sendIssueReport(
      maNguoiBaoCao: context.read<LoginViewModel>().currentUser?.id ?? 0, 
      maMayTinh: scannedCode, // TRUYỀN CHUỖI STRING MÃ MÁY ("MT-...")
      loaiSuCo: _selectedIssueType,
      tieuDe: _titleController.text,
      moTa: _descController.text,
      mucDo: 'normal',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Báo cáo thành công! Cán bộ quản lý sẽ kiểm tra sơm nhất.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi: Không thể gửi báo cáo, vui lòng thử lại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Báo cáo sự cố', style: TextStyle(fontSize: 18)),
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thông tin máy đang báo cáo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.report_problem, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Đang báo cáo sự cố cho:\n${widget.machineName} (ID: ${widget.machineId})',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Loại sự cố
              const Text(
                'Loại sự cố',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedIssueType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryNavy),
                  ),
                ),
                items: _issueTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedIssueType = value!),
              ),
              const SizedBox(height: 20),

              // Form Tiêu đề
              const Text(
                'Tiêu đề tóm tắt',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Ví dụ: Hư chuột phải, Không lên nguồn...',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryNavy),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Mô tả chi tiết
              const Text(
                'Mô tả chi tiết',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Mô tả rõ ràng vấn đề bạn đang gặp phải. Thiết bị nào bị lỗi? Hiện tượng như thế nào?',
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryNavy),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Nút Submit
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submitReport,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Gửi báo cáo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
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
