import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/user_viewmodel.dart';
import 'package:flutter_phongmay/domain/entities/user_entity.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();
  final _importController = TextEditingController();
  final _defaultPasswordController = TextEditingController();
  
  int _selectedRole = 2;
  int _filterRole = -1; // -1 means all
  int _filterStatus = -1; // -1 all, 1 active, 0 locked

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<UserViewModel>(context, listen: false);
      vm.fetchUsers();
      vm.fetchRoles();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    _importController.dispose();
    _defaultPasswordController.dispose();
    super.dispose();
  }

  // =========================================================================
  // CÁC HÀM LOGIC (GIỮ NGUYÊN 100% CỦA BẠN)
  // =========================================================================
  
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showConfirmAction({
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
    required String successMessage,
    bool isDestructive = false,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Colors.blue,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await onConfirm();
        _showMessage(successMessage);
        if (mounted) Provider.of<UserViewModel>(context, listen: false).fetchUsers();
      } catch (e) {
        _showMessage('Lỗi: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _showAddDialog() async {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    final vm = Provider.of<UserViewModel>(context, listen: false);
    _selectedRole = vm.roles.isNotEmpty ? vm.roles.first['id'] as int : 2;
    
    String? selectedGender;
    DateTime? selectedDob;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder( 
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Thêm người dùng'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ và tên *')),
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email (Tài khoản) *')),
                  const SizedBox(height: 8),
                  
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Giới tính *'),
                    value: selectedGender,
                    items: const [
                      DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                      DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                    ],
                    onChanged: (v) => setStateDialog(() => selectedGender = v),
                  ),
                  const SizedBox(height: 8),

                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setStateDialog(() => selectedDob = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Ngày sinh *'),
                      child: Text(selectedDob != null ? DateFormat('yyyy-MM-dd').format(selectedDob!) : 'Chọn ngày...'),
                    ),
                  ),

                  TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
                  
                  Consumer<UserViewModel>(
                    builder: (context, vm, _) {
                      return vm.roles.isNotEmpty
                          ? DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Vai trò *'),
                              value: _selectedRole,
                              items: vm.roles.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['ten_vai_tro'] ?? ''))).toList(),
                              onChanged: (v) => setStateDialog(() => _selectedRole = v ?? _selectedRole),
                            )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final email = _emailController.text.trim();
                  final phone = _phoneController.text.trim();
                  
                  if (name.isEmpty || email.isEmpty) {
                    _showMessage('Vui lòng nhập tên và email', isError: true);
                    return;
                  }
                  if (selectedGender == null || selectedDob == null) {
                    _showMessage('Vui lòng chọn giới tính và ngày sinh', isError: true);
                    return;
                  }

                  final tempPw = (Random().nextInt(90000000) + 10000000).toString();
                  final newUser = UserEntity(
                    id: 0, taiKhoan: email, hoTen: name, email: email, 
                    soDienThoai: phone.isNotEmpty ? phone : null,
                    vaiTroId: _selectedRole,
                    gioiTinh: selectedGender,
                    ngaySinh: DateFormat('yyyy-MM-dd').format(selectedDob!),
                    lopHocId: null,
                  );
                  
                  try {
                    final created = await vm.createUser(newUser, tempPw);
                    if (mounted) Navigator.of(ctx).pop();
                    if (created != null) {
                      _showMessage('Tạo thành công. Mật khẩu tạm: $tempPw');
                      vm.fetchUsers();
                    }
                  } catch (e) {
                    _showMessage('Lỗi: ${e.toString()}', isError: true);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _showEditDialog(UserEntity u) async {
    _nameController.text = u.hoTen;
    _emailController.text = u.email ?? '';
    _phoneController.text = u.soDienThoai ?? '';
    _selectedRole = u.vaiTroId;
    
    String? selectedGender = u.gioiTinh;
    DateTime? selectedDob = u.ngaySinh != null ? DateTime.tryParse(u.ngaySinh!) : null;
    
    final vm = Provider.of<UserViewModel>(context, listen: false);
    
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Chỉnh sửa người dùng'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Họ và tên *')),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email (Không được sửa)'),
                    enabled: false,
                  ),
                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Giới tính *'),
                    value: ['Nam', 'Nữ'].contains(selectedGender) ? selectedGender : null,
                    items: const [
                      DropdownMenuItem(value: 'Nam', child: Text('Nam')),
                      DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
                    ],
                    onChanged: (v) => setStateDialog(() => selectedGender = v),
                  ),
                  const SizedBox(height: 8),

                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDob ?? DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setStateDialog(() => selectedDob = date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Ngày sinh *'),
                      child: Text(selectedDob != null ? DateFormat('yyyy-MM-dd').format(selectedDob!) : 'Chọn ngày...'),
                    ),
                  ),

                  TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Số điện thoại')),
                  const SizedBox(height: 8),
                  Consumer<UserViewModel>(
                    builder: (context, vm2, _) {
                      return vm2.roles.isNotEmpty
                          ? DropdownButtonFormField<int>(
                              decoration: const InputDecoration(labelText: 'Vai trò *'),
                              value: _selectedRole,
                              items: vm2.roles.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['ten_vai_tro'] ?? ''))).toList(),
                              onChanged: (v) => setStateDialog(() => _selectedRole = v ?? _selectedRole),
                            )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final phone = _phoneController.text.trim();
                  
                  if (name.isEmpty || selectedGender == null || selectedDob == null) {
                    _showMessage('Tên, Giới tính và Ngày sinh không được để trống', isError: true);
                    return;
                  }
                  
                  final updated = u.copyWith(
                    hoTen: name,
                    soDienThoai: phone.isNotEmpty ? phone : null,
                    vaiTroId: _selectedRole,
                    gioiTinh: selectedGender,
                    ngaySinh: DateFormat('yyyy-MM-dd').format(selectedDob!),
                  );
                  try {
                    await vm.updateUser(updated);
                    if (mounted) Navigator.of(ctx).pop();
                    _showMessage('Cập nhật người dùng thành công');
                    vm.fetchUsers();
                  } catch (e) {
                    _showMessage('Lỗi: ${e.toString()}', isError: true);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _showImportDialog() async {
    _importController.clear();
    _defaultPasswordController.text = '123456';
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import người dùng (CSV)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dán nội dung CSV (hoặc dạng: tên,email,phone[,vai_tro_id]) mỗi dòng 1 user.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _importController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Hoặc dán CSV ở đây...\nVí dụ: Nguyễn A, nguyen.a@mail.com, 0911222333, 2',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _defaultPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mặc định cho các tài khoản mới',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final csv = _importController.text.trim();
                final pw = _defaultPasswordController.text.trim();
                if (csv.isEmpty) return;
                Navigator.of(context).pop();
                await _processImport(csv, pw);
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processImport(String csv, String password) async {
    final vm = Provider.of<UserViewModel>(context, listen: false);
    final lines = csv.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.isEmpty) return;

    final header = lines.first;
    int startIndex = 0;
    List<String> keys = [];
    if (header.toLowerCase().contains('email') || header.toLowerCase().contains('ho') || header.toLowerCase().contains('name')) {
      keys = header.split(',').map((k) => k.trim().toLowerCase()).toList();
      startIndex = 1;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    int success = 0;
    final List<String> errors = [];

    for (int i = startIndex; i < lines.length; i++) {
      final line = lines[i];
      final parts = line.split(',').map((p) => p.trim()).toList();
      String? hoTen;
      String? email;
      String? phone;
      int? roleId;

      if (keys.isNotEmpty && keys.length <= parts.length) {
        for (int j = 0; j < keys.length && j < parts.length; j++) {
          final k = keys[j];
          final v = parts[j];
          if (k.contains('ho') || k.contains('name')) hoTen = v;
          if (k.contains('email')) email = v;
          if (k.contains('phone') || k.contains('dien') || k.contains('so')) phone = v;
          if (k.contains('vai') || k.contains('role') || k.contains('ma_vai')) roleId = int.tryParse(v);
        }
      } else {
        if (parts.isNotEmpty) hoTen = parts[0];
        if (parts.length > 1) email = parts[1];
        if (parts.length > 2) phone = parts[2];
        if (parts.length > 3) roleId = int.tryParse(parts[3]);
      }

      if ((email == null || email.isEmpty) || (hoTen == null || hoTen.isEmpty)) {
        errors.add('Dòng ${i + 1}: Thiếu tên hoặc email');
        continue;
      }

      final defaultRole = vm.roles.isNotEmpty ? vm.roles.first['id'] as int : 2;
      final newUser = UserEntity(
        id: 0, taiKhoan: email, hoTen: hoTen, email: email, soDienThoai: phone, vaiTroId: roleId ?? defaultRole, lopHocId: null,
      );

      try {
        final created = await vm.createUser(newUser, password.isNotEmpty ? password : '123456');
        if (created != null) success++;
      } catch (e) {
        errors.add('Dòng ${i + 1}: ${e.toString()}');
      }
    }

    if (mounted) Navigator.of(context).pop();

    final message = 'Import hoàn tất: $success thành công, ${errors.length} lỗi.';
    if (errors.isEmpty) {
      _showMessage(message);
    } else {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kết quả Import'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                const SizedBox(height: 8),
                Expanded(child: SingleChildScrollView(child: Text(errors.join('\n')))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng')),
          ],
        ),
      );
    }
    await vm.fetchUsers();
  }

  // =========================================================================
  // UI CHUYÊN BIỆT: TÁCH NÚT ACTION ĐỂ DÙNG CHUNG CHO MOBILE & DESKTOP
  // =========================================================================
  Widget _buildActionButtons(UserEntity u, UserViewModel vm, int trangThai) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.autorenew, color: Colors.blueGrey),
          tooltip: 'Reset mật khẩu',
          onPressed: () => _showConfirmAction(
            title: 'Xác nhận Reset mật khẩu',
            content: 'Bạn có chắc chắn muốn đặt lại mật khẩu của người dùng ${u.hoTen} không?',
            successMessage: 'Đã reset mật khẩu thành công!',
            onConfirm: () async => await vm.resetPassword(u.id),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          tooltip: 'Chỉnh sửa',
          onPressed: () => _showEditDialog(u),
        ),
        IconButton(
          icon: Icon(
            trangThai == 1 ? Icons.lock_open : Icons.lock,
            color: trangThai == 1 ? Colors.green : Colors.orange,
          ),
          tooltip: trangThai == 1 ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
          onPressed: () => _showConfirmAction(
            title: trangThai == 1 ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
            content: trangThai == 1
                ? 'Bạn có muốn khóa tài khoản người dùng ${u.hoTen} không?'
                : 'Bạn có muốn mở khóa tài khoản người dùng ${u.hoTen} không?',
            successMessage: 'Cập nhật trạng thái thành công!',
            onConfirm: () async => await vm.toggleStatus(u.id, trangThai != 1),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          tooltip: 'Xóa',
          onPressed: () => _showConfirmAction(
            title: 'Xóa tài khoản',
            content: 'Bạn có chắc muốn xóa tài khoản người dùng ${u.hoTen} không?',
            successMessage: 'Đã xóa tài khoản thành công!',
            isDestructive: true,
            onConfirm: () async => await vm.deleteUser(u.id),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // GIAO DIỆN CHÍNH (ĐÃ FIX RESPONSIVE)
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        // Lọc danh sách trước để tái sử dụng cho cả ListView (Mobile) và DataTable (Desktop)
        final filteredUsers = vm.users.where((u) {
          final q = _searchController.text.trim().toLowerCase();
          if (q.isNotEmpty) {
            final hay = '${u.hoTen} ${u.email ?? ''}'.toLowerCase();
            if (!hay.contains(q)) return false;
          }
          if (_filterRole != -1 && u.vaiTroId != _filterRole) return false;
          if (_filterStatus != -1 && u.trangThai != _filterStatus) return false;
          return true;
        }).toList();

        return AdminLayout(
          title: 'Quản lý Tài khoản',
          child: vm.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildResponsiveHeader(vm), // Header tìm kiếm/nút bấm co giãn
                    const SizedBox(height: 16),
                    if (vm.error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(vm.error, style: const TextStyle(color: Colors.red)),
                      ),
                    const SizedBox(height: 8),
                    // ==========================================
                    // RESPONSIVE DATA VIEW
                    // ==========================================
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 900;
                          
                          if (isMobile) {
                            // --- GIAO DIỆN MOBILE: Dùng ListView & Card ---
                            return ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final u = filteredUsers[index];
                                final trangThai = u.trangThai;
                                final roleName = vm.roles.firstWhere((r) => r['id'] == u.vaiTroId, orElse: () => {})['ten_vai_tro'] ?? '';
                                
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Tên & Email
                                        Text(u.hoTen, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(u.email ?? 'Không có email', style: TextStyle(color: Colors.grey.shade600)),
                                        const Divider(),
                                        // Thông tin chi tiết
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('SĐT: ${u.soDienThoai ?? '-'}'),
                                            Text('Giới tính: ${u.gioiTinh ?? '-'}'),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Chip(
                                              label: Text(roleName, style: const TextStyle(fontSize: 12)),
                                              backgroundColor: Colors.blue.shade50,
                                              padding: EdgeInsets.zero,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: trangThai == 1 ? Colors.green.shade50 : Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                trangThai == 1 ? 'Hoạt động' : 'Bị khóa',
                                                style: TextStyle(
                                                  color: trangThai == 1 ? Colors.green : Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Nút hành động
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: _buildActionButtons(u, vm, trangThai ?? 0),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          } else {
                            // --- GIAO DIỆN DESKTOP: Dùng DataTable ngang ---
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical, // Cuộn dọc
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal, // Cuộn ngang nếu bảng quá rộng
                                child: DataTable(
                                  columnSpacing: 24,
                                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
                                  columns: const [
                                    DataColumn(label: Text('Họ và Tên', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Giới tính', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Ngày sinh', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Số điện thoại', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Vai trò', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: filteredUsers.map((u) {
                                    final trangThai = u.trangThai;
                                    final roleName = vm.roles.firstWhere((r) => r['id'] == u.vaiTroId, orElse: () => {})['ten_vai_tro'] ?? '';
                                    
                                    String displayDob = '-';
                                    if (u.ngaySinh != null && u.ngaySinh!.isNotEmpty) {
                                      displayDob = u.ngaySinh!.contains('T') ? u.ngaySinh!.split('T')[0] : u.ngaySinh!;
                                    }

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(u.hoTen)),
                                        DataCell(Text(u.email?.isNotEmpty == true ? u.email! : '-')),
                                        DataCell(Text(u.gioiTinh?.isNotEmpty == true ? u.gioiTinh! : '-')),
                                        DataCell(Text(displayDob)),
                                        DataCell(Text(u.soDienThoai?.isNotEmpty == true ? u.soDienThoai! : '-')),
                                        DataCell(Text(roleName)),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: trangThai == 1 ? Colors.green.shade50 : Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              trangThai == 1 ? 'Hoạt động' : 'Bị khóa',
                                              style: TextStyle(color: trangThai == 1 ? Colors.green : Colors.red),
                                            ),
                                          ),
                                        ),
                                        DataCell(_buildActionButtons(u, vm, trangThai ?? 0)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // =========================================================================
  // HEADER RESPONSIVE: Thanh tìm kiếm & Dropdown tự động xuống dòng trên mobile
  // =========================================================================
  Widget _buildResponsiveHeader(UserViewModel vm) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700; // Breakpoint cho header
        
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Ô tìm kiếm (Full màn trên Mobile, cố định 300px trên PC)
            SizedBox(
              width: isMobile ? double.infinity : 300,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm theo tên hoặc email...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            
            // Nhóm Filter
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DropdownButton<int>(
                  value: _filterRole,
                  items: [
                    const DropdownMenuItem(value: -1, child: Text('Tất cả Vai trò')),
                    ...vm.roles.map((r) => DropdownMenuItem(value: r['id'] as int, child: Text(r['ten_vai_tro'] ?? ''))),
                  ],
                  onChanged: (v) => setState(() => _filterRole = v ?? -1),
                ),
                DropdownButton<int>(
                  value: _filterStatus,
                  items: const [
                    DropdownMenuItem(value: -1, child: Text('Tất cả Trạng thái')),
                    DropdownMenuItem(value: 1, child: Text('Hoạt động')),
                    DropdownMenuItem(value: 0, child: Text('Bị khóa')),
                  ],
                  onChanged: (v) => setState(() => _filterStatus = v ?? -1),
                ),
              ],
            ),
            
            // Nhóm Nút bấm
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm mới'),
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                ),
                ElevatedButton.icon(
                  onPressed: _showImportDialog,
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Import'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),
          ],
        );
      }
    );
  }
}