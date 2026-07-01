import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/academic_viewmodel.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/student_model.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classItem;
  const ClassDetailScreen({super.key, required this.classItem});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Tải danh sách sinh viên ngay khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicViewModel>().fetchStudentsForClass(widget.classItem.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AcademicViewModel>();

    // LỌC SINH VIÊN THEO TÊN HOẶC MSSV
    final displayedStudents = viewModel.classStudents.where((sv) {
      final query = _searchQuery.toLowerCase();
      return sv.hoTen.toLowerCase().contains(query) || 
             sv.maSinhVien.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text('Lớp ${widget.classItem.maLop}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0F3E99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. HEADER THÔNG TIN LỚP HỌC
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              children: [
                Expanded(child: _buildInfoBox('NIÊN KHÓA', widget.classItem.nienKhoa)),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoBox('GIẢNG VIÊN', widget.classItem.tenGiangVien ?? 'Chưa có')),
                const SizedBox(width: 8),
                Expanded(child: _buildInfoBox('SỈ SỐ', '${viewModel.classStudents.length} SV')),
              ],
            ),
          ),

          // 2. THANH TÌM KIẾM & NÚT THÊM CSV
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Thanh tìm kiếm
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Tìm MSSV, Họ tên...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF0F3E99)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Nút Nhập CSV (Thiết kế hình vuông xanh lá chuẩn form Excel)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.green.shade200, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    tooltip: 'Thêm bằng file CSV',
                    onPressed: () => _showImportCsvDialog(context),
                  ),
                ),
              ],
            ),
          ),

          // 3. DANH SÁCH SINH VIÊN ĐÃ LỌC
          Expanded(
            child: viewModel.isStudentLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F3E99)))
                : displayedStudents.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        itemCount: displayedStudents.length,
                        itemBuilder: (context, index) {
                          final sv = displayedStudents[index];
                          return _buildStudentCard(context, viewModel, sv);
                        },
                      ),
          ),
        ],
      ),
      
      // 4. NÚT THÊM SINH VIÊN THỦ CÔNG (FAB)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentBottomSheet(context, viewModel),
        backgroundColor: const Color(0xFF0F3E99),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Thêm SV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- WIDGET UI HỖ TRỢ ---
  Widget _buildInfoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F3E99)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(_searchQuery.isEmpty ? 'Lớp này chưa có sinh viên nào.' : 'Không tìm thấy sinh viên phù hợp.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, AcademicViewModel viewModel, StudentModel sv) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8EAF6),
          child: Text(sv.hoTen.substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFF0F3E99), fontWeight: FontWeight.bold)),
        ),
        title: Text(sv.hoTen, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${sv.maSinhVien} • ${sv.email ?? 'Không có email'}', style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.person_remove, color: Colors.redAccent),
          onPressed: () => _showRemoveConfirm(context, viewModel, sv),
        ),
      ),
    );
  }

  // --- BOTTOM SHEET THÊM SINH VIÊN THỦ CÔNG ---
  void _showAddStudentBottomSheet(BuildContext context, AcademicViewModel viewModel) {
    int? selectedStudentId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Thêm Sinh Viên', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F3E99)), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  initialValue: selectedStudentId,
                  decoration: InputDecoration(labelText: 'Chọn sinh viên', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  items: viewModel.availableStudents.map((sv) => DropdownMenuItem(value: sv.id, child: Text('${sv.maSinhVien} - ${sv.hoTen}'))).toList(),
                  onChanged: (val) => setState(() => selectedStudentId = val),
                  hint: viewModel.availableStudents.isEmpty ? const Text('Đã phân hết sinh viên') : const Text('Chọn sinh viên'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3E99), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: selectedStudentId == null ? null : () async {
                    final success = await viewModel.addStudentToClass(widget.classItem.id, selectedStudentId!);
                    if (!ctx.mounted) return;
                    if (success) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm sinh viên vào lớp!'), backgroundColor: Colors.green));
                    }
                  },
                  child: const Text('THÊM VÀO LỚP', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      ),
    );
  }

  // --- DIALOG THÊM SINH VIÊN TỪ FILE CSV ---
  void _showImportCsvDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upload_file, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Nhập từ CSV', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chức năng này cho phép bạn chọn file .csv hoặc .xlsx để thêm hàng loạt sinh viên vào lớp.'),
            SizedBox(height: 12),
            Text('Lưu ý: File cần có cột "ma_sinh_vien" để hệ thống nhận diện.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 13)),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              // TODO: Tích hợp package `file_picker` và gọi API upload ở đây
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng cấu hình API xử lý File ở Backend!'), backgroundColor: Colors.orange),
              );
            },
            child: const Text('Chọn file CSV', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- DIALOG XÁC NHẬN XÓA SINH VIÊN ---
  void _showRemoveConfirm(BuildContext context, AcademicViewModel viewModel, StudentModel sv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khỏi lớp', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Bạn có muốn xóa sinh viên ${sv.hoTen} ra khỏi lớp này không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              final success = await viewModel.removeStudentFromClass(widget.classItem.id, sv.id);
              if (!ctx.mounted) return;
              if (success) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa sinh viên khỏi lớp'), backgroundColor: Colors.green));
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}