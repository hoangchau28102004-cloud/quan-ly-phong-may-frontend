import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/academic_viewmodel.dart';
import '../../../data/models/course_section_model.dart';
import '../../../data/models/student_model.dart';

class CourseSectionDetailScreen extends StatefulWidget {
  final CourseSectionModel sectionItem;

  const CourseSectionDetailScreen({super.key, required this.sectionItem});

  @override
  State<CourseSectionDetailScreen> createState() =>
      _CourseSectionDetailScreenState();
}

class _CourseSectionDetailScreenState extends State<CourseSectionDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Gọi API lấy dữ liệu thật ngay khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicViewModel>().fetchStudentsForModule(
        widget.sectionItem.id,
      );
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

    // Logic tìm kiếm realtime trên dữ liệu thật
    final displayedStudents = viewModel.moduleStudents.where((sv) {
      final query = _searchQuery.toLowerCase();
      return sv.hoTen.toLowerCase().contains(query) ||
          sv.maSinhVien.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'Sinh viên LHP: ${widget.sectionItem.maLopHocPhan}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F3E99),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. HEADER THÔNG TIN LỚP HỌC PHẦN (Chia lưới 2x2)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'MÃ LHP',
                        widget.sectionItem.maLopHocPhan,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoBox(
                        'LỚP cha',
                        widget.sectionItem.tenLop ?? 'N/A',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'MÔN HỌC',
                        widget.sectionItem.tenMon ?? 'N/A',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoBox(
                        'SĨ SỐ',
                        '${viewModel.moduleStudents.length} / ${widget.sectionItem.siSoToiDa}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        'GIẢNG VIÊN',
                        widget.sectionItem.tenGiangVien ?? 'Chưa phân công',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. THANH TÌM KIẾM
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm MSSV, họ tên, email...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
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

          // 3. DANH SÁCH SINH VIÊN (DATA THẬT)
          Expanded(
            child: viewModel.isStudentLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F3E99)),
                  )
                : displayedStudents.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy sinh viên nào.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemCount: displayedStudents.length,
                    itemBuilder: (context, index) {
                      final sv = displayedStudents[index];
                      return _buildStudentCard(context, viewModel, sv);
                    },
                  ),
          ),
        ],
      ),

      // 4. NÚT THÊM SINH VIÊN
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStudentBottomSheet(context, viewModel),
        backgroundColor: const Color(0xFF0F3E99),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Thêm SV',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- WIDGET UI HỖ TRỢ ---
  Widget _buildInfoBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F3E99),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    AcademicViewModel viewModel,
    StudentModel sv,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8EAF6),
          child: Text(
            sv.hoTen.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF0F3E99),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          sv.hoTen,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${sv.maSinhVien} • Khóa: ${sv.nienKhoa ?? "N/A"}\n${sv.email ?? "Chưa có email"}',
            style: const TextStyle(fontSize: 12, height: 1.4),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
          onPressed: () => _showRemoveConfirm(context, viewModel, sv),
        ),
      ),
    );
  }

  // --- BOTTOM SHEET THÊM SINH VIÊN (DATA THẬT) ---
  void _showAddStudentBottomSheet(
    BuildContext context,
    AcademicViewModel viewModel,
  ) {
    int? selectedStudentId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Thêm Sinh Viên vào LHP',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F3E99),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<int>(
                  initialValue: selectedStudentId,
                  decoration: InputDecoration(
                    labelText: 'Chọn sinh viên',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: viewModel.allStudents
                      .map(
                        (sv) => DropdownMenuItem(
                          value: sv.id,
                          child: Text('${sv.maSinhVien} - ${sv.hoTen}'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedStudentId = val),
                  hint: viewModel.allStudents.isEmpty
                      ? const Text('Không có sinh viên nào')
                      : const Text('Chọn sinh viên cần thêm'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F3E99),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: selectedStudentId == null
                      ? null
                      : () async {
                          if (viewModel.moduleStudents.length >=
                              widget.sectionItem.siSoToiDa) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Không thể thêm: Lớp học phần đã đạt sĩ số tối đa!',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          // LƯU LẠI MESSENGER TRƯỚC KHI AWAIT ĐỂ KHÔNG BỊ LỖI VÀNG
                          final messenger = ScaffoldMessenger.of(context);

                          final success = await viewModel.addStudentToModule(
                            widget.sectionItem.id,
                            selectedStudentId!,
                          );
                          if (!ctx.mounted) return;

                          Navigator.pop(ctx); // Đóng BottomSheet

                          if (success) {
                            // GỌI MESSENGER ĐÃ LƯU
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm sinh viên!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lỗi: Sinh viên đã tồn tại hoặc có lỗi xảy ra!',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: const Text(
                    'THÊM VÀO LỚP HỌC PHẦN',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- DIALOG XÁC NHẬN XÓA SINH VIÊN (DATA THẬT) ---
  void _showRemoveConfirm(
    BuildContext context,
    AcademicViewModel viewModel,
    StudentModel sv,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Xóa khỏi lớp học phần',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có muốn xóa sinh viên ${sv.hoTen} ra khỏi Lớp học phần này không?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              // LƯU LẠI MESSENGER TRƯỚC KHI AWAIT ĐỂ KHÔNG BỊ LỖI VÀNG
              final messenger = ScaffoldMessenger.of(context);

              final success = await viewModel.removeStudentFromModule(
                widget.sectionItem.id,
                sv.id,
              );
              if (!ctx.mounted) return;

              Navigator.pop(ctx); // Đóng Dialog

              if (success) {
                // GỌI MESSENGER ĐÃ LƯU
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa sinh viên khỏi LHP'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
