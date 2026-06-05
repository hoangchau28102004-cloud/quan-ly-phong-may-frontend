import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/user_viewmodel.dart';
import 'package:flutter_phongmay/domain/entities/user_entity.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

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

  Future<void> _showAddDialog() async {
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    final vm = Provider.of<UserViewModel>(context, listen: false);
    _selectedRole = vm.roles.isNotEmpty ? vm.roles.first['id'] as int : 2;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            Consumer<UserViewModel>(
              builder: (context, vm, _) {
                return vm.roles.isNotEmpty
                    ? DropdownButton<int>(
                        value: _selectedRole,
                        items: vm.roles
                            .map(
                              (r) => DropdownMenuItem(
                                value: r['id'] as int,
                                child: Text(r['ten_vai_tro'] ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedRole = v ?? _selectedRole),
                      )
                    : const SizedBox();
              },
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
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();
              final phone = _phoneController.text.trim();
              if (name.isEmpty || email.isEmpty) return;
              final tempPw = (Random().nextInt(90000000) + 10000000).toString();
              final newUser = UserEntity(
                id: 0,
                taiKhoan: email,
                hoTen: name,
                email: email,
                soDienThoai: phone.isNotEmpty ? phone : null,
                vaiTroId: _selectedRole,
                lopHocId: null,
              );
              try {
                final created = await vm.createUser(newUser, tempPw);
                Navigator.of(context).pop();
                if (created != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tạo thành công. Mật khẩu tạm: $tempPw'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    _importController.dispose();
    _defaultPasswordController.dispose();
    super.dispose();
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
                  hintText:
                      'Hoặc dán CSV ở đây...\nVí dụ: Nguyễn A, nguyen.a@mail.com, 0911222333, 2',
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

  Future<void> _showEditDialog(UserEntity u) async {
    _nameController.text = u.hoTen;
    _emailController.text = u.email ?? '';
    _phoneController.text = u.soDienThoai ?? '';
    _selectedRole = u.vaiTroId;
    final vm = Provider.of<UserViewModel>(context, listen: false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa người dùng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            Consumer<UserViewModel>(
              builder: (context, vm2, _) {
                return vm2.roles.isNotEmpty
                    ? DropdownButton<int>(
                        value: _selectedRole,
                        items: vm2.roles
                            .map(
                              (r) => DropdownMenuItem(
                                value: r['id'] as int,
                                child: Text(r['ten_vai_tro'] ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedRole = v ?? _selectedRole),
                      )
                    : const SizedBox();
              },
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
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();
              final phone = _phoneController.text.trim();
              if (name.isEmpty || email.isEmpty) return;
              final updated = u.copyWith(
                hoTen: name,
                email: email,
                soDienThoai: phone.isNotEmpty ? phone : null,
                vaiTroId: _selectedRole,
              );
              try {
                await vm.updateUser(updated);
              } catch (e) {}
              Navigator.of(context).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _processImport(String csv, String password) async {
    final vm = Provider.of<UserViewModel>(context, listen: false);
    final lines = csv
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return;

    // detect header
    final header = lines.first;
    int startIndex = 0;
    List<String> keys = [];
    if (header.toLowerCase().contains('email') ||
        header.toLowerCase().contains('ho') ||
        header.toLowerCase().contains('name')) {
      // treat first line as header
      keys = header.split(',').map((k) => k.trim().toLowerCase()).toList();
      startIndex = 1;
    }

    // show progress
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
          if (k.contains('phone') || k.contains('dien') || k.contains('so'))
            phone = v;
          if (k.contains('vai') || k.contains('role') || k.contains('ma_vai'))
            roleId = int.tryParse(v);
        }
      } else {
        // fallback positional: name,email,phone,role?
        if (parts.isNotEmpty) hoTen = parts[0];
        if (parts.length > 1) email = parts[1];
        if (parts.length > 2) phone = parts[2];
        if (parts.length > 3) roleId = int.tryParse(parts[3]);
      }

      if ((email == null || email.isEmpty) ||
          (hoTen == null || hoTen.isEmpty)) {
        errors.add('Dòng ${i + 1}: Thiếu tên hoặc email');
        continue;
      }

      final defaultRole = vm.roles.isNotEmpty ? vm.roles.first['id'] as int : 2;
      final newUser = UserEntity(
        id: 0,
        taiKhoan: email,
        hoTen: hoTen,
        email: email,
        soDienThoai: phone,
        vaiTroId: roleId ?? defaultRole,
        lopHocId: null,
      );

      try {
        final created = await vm.createUser(
          newUser,
          password.isNotEmpty ? password : '123456',
        );
        if (created != null) success++;
      } catch (e) {
        errors.add('Dòng ${i + 1}: ${e.toString()}');
      }
    }

    Navigator.of(context).pop(); // close progress

    final message =
        'Import hoàn tất: $success thành công, ${errors.length} lỗi.';
    if (errors.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } else {
      // show errors in dialog
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
                Expanded(
                  child: SingleChildScrollView(child: Text(errors.join('\n'))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }

    // refresh list
    await vm.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, vm, _) {
        return AdminLayout(
          title: 'Quản lý Tài khoản',
          child: vm.loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top tools: search, filters, actions
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm theo tên hoặc email...',
                              prefixIcon: Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: _filterRole,
                          items: [
                            const DropdownMenuItem(
                              value: -1,
                              child: Text('Tất cả Vai trò'),
                            ),
                            ...vm.roles.map(
                              (r) => DropdownMenuItem(
                                value: r['id'] as int,
                                child: Text(r['ten_vai_tro'] ?? ''),
                              ),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _filterRole = v ?? -1),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<int>(
                          value: _filterStatus,
                          items: const [
                            DropdownMenuItem(
                              value: -1,
                              child: Text('Tất cả Trạng thái'),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text('Hoạt động'),
                            ),
                            DropdownMenuItem(value: 0, child: Text('Bị khóa')),
                          ],
                          onChanged: (v) =>
                              setState(() => _filterStatus = v ?? -1),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _showAddDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm mới'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showImportDialog,
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text('Import'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (vm.error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          vm.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 900;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth.isFinite
                                    ? constraints.maxWidth
                                    : MediaQuery.of(context).size.width,
                              ),
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columnSpacing: 24,
                                  columns: isCompact
                                      ? const [
                                          DataColumn(label: Text('Họ và Tên')),
                                          DataColumn(label: Text('Vai trò')),
                                          DataColumn(label: Text('Hành động')),
                                        ]
                                      : const [
                                          DataColumn(label: Text('Họ và Tên')),
                                          DataColumn(label: Text('Email')),
                                          DataColumn(label: Text('Vai trò')),
                                          DataColumn(label: Text('Trạng thái')),
                                          DataColumn(
                                            label: Text('Số điện thoại'),
                                          ),
                                          DataColumn(label: Text('Hành động')),
                                        ],
                                  rows: vm.users
                                      .where((u) {
                                        final q = _searchController.text
                                            .trim()
                                            .toLowerCase();
                                        if (q.isNotEmpty) {
                                          final hay =
                                              (u.hoTen + ' ' + (u.email ?? ''))
                                                  .toLowerCase();
                                          if (!hay.contains(q)) return false;
                                        }
                                        if (_filterRole != -1 &&
                                            u.vaiTroId != _filterRole)
                                          return false;
                                        if (_filterStatus != -1 &&
                                            u.trangThai != _filterStatus)
                                          return false;
                                        return true;
                                      })
                                      .map((u) {
                                        final trangThai = u.trangThai;
                                        final roleName =
                                            vm.roles.firstWhere(
                                              (r) => r['id'] == u.vaiTroId,
                                              orElse: () => {},
                                            )['ten_vai_tro'] ??
                                            '';
                                        if (isCompact) {
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(u.hoTen)),
                                              DataCell(Text(roleName)),
                                              DataCell(
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.sync,
                                                      ),
                                                      tooltip: 'Reset mật khẩu',
                                                      onPressed: () => vm
                                                          .resetPassword(u.id),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        trangThai == 1
                                                            ? Icons.lock
                                                            : Icons.lock_open,
                                                      ),
                                                      tooltip: 'Toggle',
                                                      onPressed: () =>
                                                          vm.toggleStatus(
                                                            u.id,
                                                            trangThai == 1,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return DataRow(
                                          cells: [
                                            DataCell(Text(u.hoTen)),
                                            DataCell(Text(u.email ?? '-')),
                                            DataCell(Text(roleName)),
                                            DataCell(
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: trangThai == 1
                                                      ? Colors.blue[50]
                                                      : Colors.red[50],
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  trangThai == 1
                                                      ? 'Hoạt động'
                                                      : 'Bị khóa',
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(u.soDienThoai ?? '-'),
                                            ),
                                            DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.sync,
                                                    ),
                                                    tooltip: 'Reset mật khẩu',
                                                    onPressed: () =>
                                                        vm.resetPassword(u.id),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.edit,
                                                    ),
                                                    tooltip: 'Chỉnh sửa',
                                                    onPressed: () =>
                                                        _showEditDialog(u),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      trangThai == 1
                                                          ? Icons.lock
                                                          : Icons.lock_open,
                                                    ),
                                                    tooltip: 'Toggle',
                                                    onPressed: () =>
                                                        vm.toggleStatus(
                                                          u.id,
                                                          trangThai == 1,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                    ),
                                                    tooltip: 'Xóa',
                                                    onPressed: () async {
                                                      final ok =
                                                          await showDialog<
                                                            bool
                                                          >(
                                                            context: context,
                                                            builder: (ctx) => AlertDialog(
                                                              title: const Text(
                                                                'Xác nhận',
                                                              ),
                                                              content: const Text(
                                                                'Bạn có chắc muốn xóa tài khoản này?',
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                        ctx,
                                                                      ).pop(
                                                                        false,
                                                                      ),
                                                                  child:
                                                                      const Text(
                                                                        'Hủy',
                                                                      ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                        ctx,
                                                                      ).pop(
                                                                        true,
                                                                      ),
                                                                  child:
                                                                      const Text(
                                                                        'Xóa',
                                                                      ),
                                                                ),
                                                              ],
                                                            ),
                                                          ) ??
                                                          false;
                                                      if (ok)
                                                        await vm.deleteUser(
                                                          u.id,
                                                        );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      })
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
