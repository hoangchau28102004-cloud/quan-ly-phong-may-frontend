import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/academic_viewmodel.dart';
import '../../../data/models/class_model.dart';
import '../../../data/models/course_section_model.dart'; 
import '../../../data/models/subject_model.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/repositories/academic_repository_impl.dart';

import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';
import 'class_detail_screen.dart'; 
import 'course_section_detail_screen.dart'; 

class AcademicManagementScreen extends StatelessWidget {
  const AcademicManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AcademicViewModel(
        repository: AcademicRepositoryImpl(apiService: ApiService()),
      ),
      child: const AcademicManagementView(),
    );
  }
}

class AcademicManagementView extends StatelessWidget {
  const AcademicManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Quản lý Học vụ',
      child: Container(
        color: const Color(0xFFF4F6F9), 
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
            ),
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Color(0xFF0F3E99),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF0F3E99),
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    tabs: [
                      Tab(text: 'Lớp học'), 
                      Tab(text: 'Lớp học phần'),
                      Tab(text: 'Môn học'),
                    ],
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  
                  const Expanded(
                    child: TabBarView(
                      children: [
                        ClassListBody(),           
                        CourseSectionListBody(),   
                        SubjectListBody(),         
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// --- TAB 1: DANH SÁCH LỚP HỌC ---
// =========================================================================
class ClassListBody extends StatefulWidget {
  const ClassListBody({super.key});
  @override
  State<ClassListBody> createState() => _ClassListBodyState();
}

class _ClassListBodyState extends State<ClassListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AcademicViewModel>();
    if (viewModel.isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF0F3E99)));

    final displayedClasses = viewModel.classes.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.maLop.toLowerCase().contains(query) || c.nienKhoa.toLowerCase().contains(query) || c.chuyenNganh.toLowerCase().contains(query) || (c.tenGiangVien?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(hintText: 'Tìm mã lớp, niên khóa, GVCN...', prefixIcon: const Icon(Icons.search, color: Colors.grey), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F3E99)))),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showClassBottomSheet(context, viewModel, null),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Thêm lớp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3E99), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), elevation: 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchInitialData(),
            child: displayedClasses.isEmpty 
              ? const Center(child: Text('Không tìm thấy lớp học nào.', style: TextStyle(color: Colors.grey, fontSize: 16)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: displayedClasses.length,
                  itemBuilder: (context, index) {
                    return _buildListItemCard(context, viewModel, displayedClasses[index]);
                  },
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildListItemCard(BuildContext context, AcademicViewModel viewModel, ClassModel classItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFFFAFAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChangeNotifierProvider.value(value: viewModel, child: ClassDetailScreen(classItem: classItem)))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.class_, color: Color(0xFF0F3E99), size: 24)),
        title: Text(classItem.maLop, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4.0), child: Text('Khóa: ${classItem.nienKhoa} • ${classItem.chuyenNganh}\nGVCN: ${classItem.tenGiangVien ?? "Chưa phân công"} • SV: ${classItem.soSinhVien}', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () => _showClassBottomSheet(context, viewModel, classItem)),
            Container(margin: const EdgeInsets.only(left: 4), decoration: BoxDecoration(color: const Color(0xFFFF5C5C), borderRadius: BorderRadius.circular(8)), child: IconButton(icon: const Icon(Icons.delete, color: Colors.white, size: 20), onPressed: () => _showDeleteConfirm(context, viewModel, classItem))),
          ],
        ),
      ),
    );
  }

  void _showClassBottomSheet(BuildContext context, AcademicViewModel viewModel, ClassModel? existingClass) {
    final isEdit = existingClass != null;
    final maLopCtrl = TextEditingController(text: existingClass?.maLop ?? '');
    final nienKhoaCtrl = TextEditingController(text: existingClass?.nienKhoa ?? '');
    final chuyenNganhCtrl = TextEditingController(text: existingClass?.chuyenNganh ?? '');
    int? selectedTeacherId = existingClass?.maGiangVien;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(isEdit ? 'Cập nhật Lớp học' : 'Thêm Lớp học mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F3E99)), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextField(controller: maLopCtrl, decoration: InputDecoration(labelText: 'Mã Lớp', hintText: 'VD: CDTH22A', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), readOnly: isEdit),
                  const SizedBox(height: 16),
                  TextField(controller: nienKhoaCtrl, decoration: InputDecoration(labelText: 'Niên khóa', hintText: 'VD: 2022-2025', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  TextField(controller: chuyenNganhCtrl, decoration: InputDecoration(labelText: 'Chuyên ngành', hintText: 'VD: CNTT', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(initialValue: selectedTeacherId, decoration: InputDecoration(labelText: 'Giảng viên chủ nhiệm', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: viewModel.teachers.map((t) => DropdownMenuItem(value: t.id, child: Text(t.hoTen))).toList(), onChanged: (val) => setState(() => selectedTeacherId = val)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3E99), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      final newData = ClassModel(id: existingClass?.id ?? 0, maLop: maLopCtrl.text, nienKhoa: nienKhoaCtrl.text, chuyenNganh: chuyenNganhCtrl.text, maGiangVien: selectedTeacherId, soSinhVien: existingClass?.soSinhVien ?? 0);
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await viewModel.saveClass(existingClass?.id, newData);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (success) messenger.showSnackBar(SnackBar(content: Text(isEdit ? 'Cập nhật thành công!' : 'Thêm lớp thành công!'), backgroundColor: Colors.green));
                    },
                    child: Text(isEdit ? 'LƯU THAY ĐỔI' : 'TẠO LỚP MỚI', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AcademicViewModel viewModel, ClassModel classItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa lớp ${classItem.maLop} không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context); 
              final success = await viewModel.deleteClass(classItem.id);
              if (!ctx.mounted) return;
              Navigator.pop(ctx); 
              if (success) messenger.showSnackBar(const SnackBar(content: Text('Xóa lớp thành công!'), backgroundColor: Colors.green));
            },
            child: const Text('Xóa ngay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// --- TAB 2: DANH SÁCH LỚP HỌC PHẦN ---
// =========================================================================
class CourseSectionListBody extends StatefulWidget {
  const CourseSectionListBody({super.key});
  @override
  State<CourseSectionListBody> createState() => _CourseSectionListBodyState();
}

class _CourseSectionListBodyState extends State<CourseSectionListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { context.read<AcademicViewModel>().fetchCourseSections(); });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AcademicViewModel>();
    if (viewModel.isSectionLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF0F3E99)));

    final displayedItems = viewModel.courseSections.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.maLopHocPhan.toLowerCase().contains(q) || (c.tenMon?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController, onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(hintText: 'Tìm Lớp học phần, môn...', prefixIcon: const Icon(Icons.search, color: Colors.grey), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F3E99)))),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCourseSectionBottomSheet(context, viewModel, null),
                icon: const Icon(Icons.add, color: Colors.white, size: 18), label: const Text('Thêm mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3E99), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), elevation: 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchCourseSections(),
            child: displayedItems.isEmpty 
              ? const Center(child: Text('Không tìm thấy lớp học phần nào.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) => _buildCourseSectionCard(context, viewModel, displayedItems[index]),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseSectionCard(BuildContext context, AcademicViewModel viewModel, CourseSectionModel item) {
    bool isActive = item.trangThai.toLowerCase().contains('hoạt động') || item.trangThai.toLowerCase() == 'active';
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => ChangeNotifierProvider.value(value: viewModel, child: CourseSectionDetailScreen(sectionItem: item)))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.library_books, color: Color(0xFF0F3E99), size: 18)), const SizedBox(width: 8), Text(item.maLopHocPhan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))]),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isActive ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? Colors.green.shade200 : Colors.red.shade200)), child: Text(item.trangThai.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green.shade700 : Colors.red.shade700))),
                ],
              ),
              const SizedBox(height: 12), const Divider(height: 1, color: Color(0xFFEEEEEE)), const SizedBox(height: 12),
              Text('Môn: ${item.tenMon ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F3E99))),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(item.tenNamHoc ?? "N/A", style: const TextStyle(fontSize: 12, color: Colors.black87)), const Spacer(), const Icon(Icons.room, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(item.tenPhong ?? "Chưa xếp", style: const TextStyle(fontSize: 12, color: Colors.black87)), const Spacer(), const Icon(Icons.people, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('${item.soSinhVien} / ${item.siSoToiDa}', style: const TextStyle(fontSize: 12, color: Colors.black87))]),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.person, size: 14, color: Colors.grey), const SizedBox(width: 4), Text('GV: ${item.tenGiangVien ?? "Chưa phân công"}', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700))]),
              const SizedBox(height: 12), const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [TextButton.icon(onPressed: () => _showCourseSectionBottomSheet(context, viewModel, item), icon: const Icon(Icons.edit, size: 16, color: Colors.orange), label: const Text('Sửa', style: TextStyle(color: Colors.orange))), TextButton.icon(onPressed: () => _showDeleteConfirm(context, viewModel, item), icon: const Icon(Icons.delete, size: 16, color: Colors.red), label: const Text('Xóa', style: TextStyle(color: Colors.red)))]),
            ],
          ),
        ),
      ),
    );
  }

  void _showCourseSectionBottomSheet(BuildContext context, AcademicViewModel viewModel, CourseSectionModel? existingItem) {
    final isEdit = existingItem != null;
    final maLopHocPhanCtrl = TextEditingController(text: existingItem?.maLopHocPhan ?? '');
    int? selectedMon = (existingItem?.maMon != null && viewModel.subjects.any((m) => m['id'] == existingItem!.maMon)) ? existingItem?.maMon : null;
    int? selectedNam = (existingItem?.maNamHoc != null && viewModel.academicYears.any((n) => n['id'] == existingItem!.maNamHoc)) ? existingItem?.maNamHoc : null;
    int? selectedPhong = (existingItem?.maPhong != null && viewModel.rooms.any((p) => p['id'] == existingItem!.maPhong)) ? existingItem?.maPhong : null;
    int? selectedTeacher = existingItem?.maGiangVien; 
    final siSoCtrl = TextEditingController(text: existingItem?.siSoToiDa.toString() ?? '40');
    
    String normalizeTrangThai(String? tt) {
      if (tt == null) return 'Hoạt động';
      final lower = tt.toLowerCase();
      if (lower == 'active' || lower.contains('hoạt động') || lower.contains('hoat dong')) return 'Hoạt động';
      return 'Đã khóa';
    }
    String selectedTrangThai = normalizeTrangThai(existingItem?.trangThai);
    final ghiChuCtrl = TextEditingController(text: existingItem?.ghiChu ?? '');

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85, 
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
            child: Column(
              children: [
                Text(isEdit ? 'Cập nhật Lớp học phần' : 'Thêm Lớp học phần mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F3E99))),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [Expanded(child: TextField(controller: maLopHocPhanCtrl, decoration: InputDecoration(labelText: 'Mã LHP', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), readOnly: isEdit)), const SizedBox(width: 12), Expanded(child: DropdownButtonFormField<int>(initialValue: selectedMon, decoration: InputDecoration(labelText: 'Môn học', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: viewModel.subjects.map((m) => DropdownMenuItem<int>(value: m['id'], child: Text(m['ten_mon'], overflow: TextOverflow.ellipsis))).toList(), onChanged: (val) => setState(() => selectedMon = val)))]),
                        const SizedBox(height: 16),
                        Row(children: [Expanded(child: DropdownButtonFormField<int>(initialValue: selectedNam, decoration: InputDecoration(labelText: 'Năm học', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: viewModel.academicYears.map((n) => DropdownMenuItem<int>(value: n['id'], child: Text(n['ten_nam_hoc']?.toString() ?? n['nam_hoc']?.toString() ?? 'N/A'))).toList(), onChanged: (val) => setState(() => selectedNam = val))), const SizedBox(width: 12), Expanded(child: DropdownButtonFormField<int>(initialValue: selectedTeacher, decoration: InputDecoration(labelText: 'Giảng viên', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: viewModel.teachers.map((t) => DropdownMenuItem<int>(value: t.id, child: Text(t.hoTen, overflow: TextOverflow.ellipsis))).toList(), onChanged: (val) => setState(() => selectedTeacher = val), hint: const Text('Chưa phân công')))]),
                        const SizedBox(height: 16),
                        Row(children: [Expanded(child: DropdownButtonFormField<int>(initialValue: selectedPhong, decoration: InputDecoration(labelText: 'Phòng', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: viewModel.rooms.map((p) => DropdownMenuItem<int>(value: p['id'], child: Text(p['ten_phong']))).toList(), onChanged: (val) => setState(() => selectedPhong = val))), const SizedBox(width: 12), Expanded(child: TextField(controller: siSoCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Sĩ số tối đa', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))))]),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(initialValue: selectedTrangThai, decoration: InputDecoration(labelText: 'Trạng thái', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), items: const [DropdownMenuItem(value: 'Hoạt động', child: Text('Hoạt động')), DropdownMenuItem(value: 'Đã khóa', child: Text('Đã khóa'))], onChanged: (val) => setState(() => selectedTrangThai = val ?? 'Hoạt động')),
                        const SizedBox(height: 16),
                        TextField(controller: ghiChuCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Ghi chú', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3E99), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    if (maLopHocPhanCtrl.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Mã Lớp Học Phần'))); return; }
                    final newData = CourseSectionModel(id: existingItem?.id ?? 0, maLopHocPhan: maLopHocPhanCtrl.text, maMon: selectedMon, maNamHoc: selectedNam, maPhong: selectedPhong, maGiangVien: selectedTeacher, siSoToiDa: int.tryParse(siSoCtrl.text) ?? 40, soSinhVien: existingItem?.soSinhVien ?? 0, trangThai: selectedTrangThai, ghiChu: ghiChuCtrl.text);
                    final messenger = ScaffoldMessenger.of(context);
                    final success = await viewModel.saveCourseSection(existingItem?.id, newData);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (success) messenger.showSnackBar(const SnackBar(content: Text('Đã lưu lớp học phần!'), backgroundColor: Colors.green));
                  },
                  child: const Text('LƯU LỚP HỌC PHẦN', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AcademicViewModel viewModel, CourseSectionModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa Lớp học phần ${item.maLopHocPhan} không?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final success = await viewModel.deleteCourseSection(item.id);
              if (!ctx.mounted) return;
              Navigator.pop(ctx); 
              if (success) messenger.showSnackBar(const SnackBar(content: Text('Xóa thành công!'), backgroundColor: Colors.green));
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// --- TAB 3: DANH SÁCH MÔN HỌC ---
// =========================================================================
class SubjectListBody extends StatefulWidget {
  const SubjectListBody({super.key});
  @override
  State<SubjectListBody> createState() => _SubjectListBodyState();
}

class _SubjectListBodyState extends State<SubjectListBody> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicViewModel>().fetchSubjectsData();
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

    if (viewModel.isSubjectLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF0F3E99)));

    final displayedItems = viewModel.listMonHoc.where((m) {
      final q = _searchQuery.toLowerCase();
      return m.tenMon.toLowerCase().contains(q) || m.maMonHoc.toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Tìm mã môn, tên môn...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0F3E99))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showSubjectBottomSheet(context, viewModel, null),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Thêm môn', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3E99), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), elevation: 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => viewModel.fetchSubjectsData(),
            child: displayedItems.isEmpty 
              ? const Center(child: Text('Không tìm thấy môn học nào.', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) => _buildSubjectCard(context, viewModel, displayedItems[index]),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(BuildContext context, AcademicViewModel viewModel, SubjectModel item) {
    return Card(
      elevation: 0, margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE8EAF6), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.menu_book, color: Color(0xFF0F3E99))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('[${item.maMonHoc}] ${item.tenMon}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange.shade200)), child: Text(item.loaiMon, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
                      const SizedBox(width: 8),
                      Text('${item.soTinChi} Tín chỉ', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _showSubjectBottomSheet(context, viewModel, item)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20), onPressed: () => _showDeleteSubjectConfirm(context, viewModel, item)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSubjectBottomSheet(BuildContext context, AcademicViewModel viewModel, SubjectModel? existingItem) {
    final isEdit = existingItem != null;
    final maMonCtrl = TextEditingController(text: existingItem?.maMonHoc ?? '');
    final tenMonCtrl = TextEditingController(text: existingItem?.tenMon ?? '');
    final soTinChiCtrl = TextEditingController(text: existingItem?.soTinChi.toString() ?? '3');
    String selectedLoai = (existingItem?.loaiMon == 'Chuyên ngành') ? 'Chuyên ngành' : 'Cơ sở';
    final moTaCtrl = TextEditingController(text: existingItem?.moTa ?? '');

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(isEdit ? 'Cập nhật Môn học' : 'Thêm Môn học mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F3E99)), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextField(controller: maMonCtrl, decoration: InputDecoration(labelText: 'Mã môn học', hintText: 'VD: MH001', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))), readOnly: isEdit),
                  const SizedBox(height: 16),
                  TextField(controller: tenMonCtrl, decoration: InputDecoration(labelText: 'Tên môn học', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedLoai, decoration: InputDecoration(labelText: 'Loại môn', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          items: const [DropdownMenuItem(value: 'Cơ sở', child: Text('Cơ sở')), DropdownMenuItem(value: 'Chuyên ngành', child: Text('Chuyên ngành'))],
                          onChanged: (val) => setState(() => selectedLoai = val!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: soTinChiCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Số tín chỉ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: moTaCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Mô tả (Tùy chọn)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F3E99), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      if (maMonCtrl.text.trim().isEmpty || tenMonCtrl.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Mã và Tên môn học!'))); return; }
                      final newData = SubjectModel(id: existingItem?.id ?? 0, maMonHoc: maMonCtrl.text.trim(), tenMon: tenMonCtrl.text.trim(), loaiMon: selectedLoai, soTinChi: int.tryParse(soTinChiCtrl.text) ?? 3, moTa: moTaCtrl.text.trim());
                      final messenger = ScaffoldMessenger.of(context);
                      final success = await viewModel.saveSubject(existingItem?.id, newData);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (success) { messenger.showSnackBar(const SnackBar(content: Text('Đã lưu môn học!'), backgroundColor: Colors.green)); } 
                      else { messenger.showSnackBar(SnackBar(content: Text('Lỗi: ${viewModel.errorMessage}'), backgroundColor: Colors.redAccent)); }
                    },
                    child: const Text('LƯU MÔN HỌC', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  void _showDeleteSubjectConfirm(BuildContext context, AcademicViewModel viewModel, SubjectModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa môn [${item.maMonHoc}] ${item.tenMon} không?\n\nLưu ý: Nếu môn này đang được sử dụng ở Lớp học phần, việc xóa sẽ bị từ chối.', style: const TextStyle(height: 1.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final success = await viewModel.deleteSubject(item.id);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              if (success) { messenger.showSnackBar(const SnackBar(content: Text('Xóa môn học thành công!'), backgroundColor: Colors.green)); } 
              else { messenger.showSnackBar(const SnackBar(content: Text('Xóa thất bại: Môn học đang được sử dụng!'), backgroundColor: Colors.redAccent)); }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}