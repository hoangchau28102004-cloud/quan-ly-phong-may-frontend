import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

class AcademicManagementScreen extends StatefulWidget {
  const AcademicManagementScreen({super.key});

  @override
  State<AcademicManagementScreen> createState() =>
      _AcademicManagementScreenState();
}

class _AcademicManagementScreenState extends State<AcademicManagementScreen> {
  bool loading = true;
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> sessions = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> timeStructures = [];

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => loading = true);
    try {
      List<Map<String, dynamic>> s1 = [];
      List<Map<String, dynamic>> s2 = [];
      List<Map<String, dynamic>> s3 = [];
      List<Map<String, dynamic>> s4 = [];

      final res1 = await ApiService.get('/mon-hoc');
      if (res1.statusCode == 200) {
        final body = ApiService.decodeBody(res1);
        if (body != null && body['success'] == true) {
          s1 = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final res2 = await ApiService.get('/ca-hoc');
      if (res2.statusCode == 200) {
        final body = ApiService.decodeBody(res2);
        if (body != null && body['success'] == true) {
          s2 = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final res3 = await ApiService.get('/lop-hoc');
      if (res3.statusCode == 200) {
        final body = ApiService.decodeBody(res3);
        if (body != null && body['success'] == true) {
          s3 = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final res4 = await ApiService.get(
        '/cau-truc-cai-dat-thoi-gian?orderBy=nam_hoc&descending=true',
      );
      if (res4.statusCode == 200) {
        final body = ApiService.decodeBody(res4);
        if (body != null && body['success'] == true) {
          s4 = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      setState(() {
        subjects = s1;
        sessions = s2;
        classes = s3;
        timeStructures = s4;
      });
    } catch (e) {
      // ignore errors for now
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _addSubject() async {
    final nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Môn học'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên môn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                await ApiService.post('/mon-hoc', {'ten_mon': name});
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _addSession() async {
    final nameController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Ca học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên ca'),
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: 'Giờ bắt đầu (HH:mm)',
              ),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(
                labelText: 'Giờ kết thúc (HH:mm)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final start = startController.text.trim();
              final end = endController.text.trim();
              if (name.isEmpty) return;
              try {
                await ApiService.post('/ca-hoc', {
                  'ten_ca': name,
                  'gio_bat_dau': start,
                  'gio_ket_thuc': end,
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _addClass() async {
    final maController = TextEditingController();
    final nienController = TextEditingController();
    final chuyenController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Lớp học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: maController,
              decoration: const InputDecoration(labelText: 'Mã lớp'),
            ),
            TextField(
              controller: nienController,
              decoration: const InputDecoration(labelText: 'Niên khóa'),
            ),
            TextField(
              controller: chuyenController,
              decoration: const InputDecoration(labelText: 'Chuyên ngành'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final ma = maController.text.trim();
              final nien = nienController.text.trim();
              final chuyen = chuyenController.text.trim();
              if (ma.isEmpty) return;
              try {
                await ApiService.post('/lop-hoc', {
                  'ma_lop': ma,
                  'nien_khoa': nien,
                  'chuyen_nganh': chuyen,
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTimeStructure() async {
    final namController = TextEditingController();
    final hocKyController = TextEditingController();
    final soTuanController = TextEditingController();
    final tuNgayController = TextEditingController();
    final denNgayController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Cấu trúc thời gian'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namController,
                decoration: const InputDecoration(
                  labelText: 'Năm học (VD: 2026)',
                ),
              ),
              TextField(
                controller: hocKyController,
                decoration: const InputDecoration(labelText: 'Học kỳ'),
              ),
              TextField(
                controller: soTuanController,
                decoration: const InputDecoration(labelText: 'Số tuần'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tuNgayController,
                decoration: const InputDecoration(
                  labelText: 'Từ ngày (YYYY-MM-DD)',
                ),
              ),
              TextField(
                controller: denNgayController,
                decoration: const InputDecoration(
                  labelText: 'Đến ngày (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nam = namController.text.trim();
              final hocKy = hocKyController.text.trim();
              final soTuan = int.tryParse(soTuanController.text.trim()) ?? 0;
              final tu = tuNgayController.text.trim();
              final den = denNgayController.text.trim();
              if (nam.isEmpty) return;
              try {
                await ApiService.post('/cau-truc-cai-dat-thoi-gian', {
                  'nam_hoc': nam,
                  'hoc_ky': hocKy,
                  'so_tuan': soTuan,
                  'tu_ngay': tu,
                  'den_ngay': den,
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _editSubject(Map<String, dynamic> s) async {
    final id = s['id'];
    if (id == null) return;
    final nameController = TextEditingController(
      text: s['ten_mon']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Môn học'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên môn'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.put('/mon-hoc/$id', {
                  'ten_mon': nameController.text.trim(),
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubject(Map<String, dynamic> s) async {
    final id = s['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa môn học này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await ApiService.delete('/mon-hoc/$id');
    } catch (_) {}
    await _fetchAll();
  }

  Future<void> _editSession(Map<String, dynamic> s) async {
    final id = s['id'];
    if (id == null) return;
    final nameController = TextEditingController(
      text: s['ten_ca']?.toString() ?? '',
    );
    final startController = TextEditingController(
      text: s['gio_bat_dau']?.toString() ?? '',
    );
    final endController = TextEditingController(
      text: s['gio_ket_thuc']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Ca học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Tên ca'),
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: 'Giờ bắt đầu (HH:mm)',
              ),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(
                labelText: 'Giờ kết thúc (HH:mm)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.put('/ca-hoc/$id', {
                  'ten_ca': nameController.text.trim(),
                  'gio_bat_dau': startController.text.trim(),
                  'gio_ket_thuc': endController.text.trim(),
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSession(Map<String, dynamic> s) async {
    final id = s['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa ca học này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await ApiService.delete('/ca-hoc/$id');
    } catch (_) {}
    await _fetchAll();
  }

  Future<void> _editClass(Map<String, dynamic> c) async {
    final id = c['id'];
    if (id == null) return;
    final maController = TextEditingController(
      text: c['ma_lop']?.toString() ?? '',
    );
    final nienController = TextEditingController(
      text: c['nien_khoa']?.toString() ?? '',
    );
    final chuyenController = TextEditingController(
      text: c['chuyen_nganh']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Lớp học'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: maController,
              decoration: const InputDecoration(labelText: 'Mã lớp'),
            ),
            TextField(
              controller: nienController,
              decoration: const InputDecoration(labelText: 'Niên khóa'),
            ),
            TextField(
              controller: chuyenController,
              decoration: const InputDecoration(labelText: 'Chuyên ngành'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.put('/lop-hoc/$id', {
                  'ma_lop': maController.text.trim(),
                  'nien_khoa': nienController.text.trim(),
                  'chuyen_nganh': chuyenController.text.trim(),
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClass(Map<String, dynamic> c) async {
    final id = c['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa lớp học này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await ApiService.delete('/lop-hoc/$id');
    } catch (_) {}
    await _fetchAll();
  }

  Future<void> _editTimeStructure(Map<String, dynamic> t) async {
    final id = t['id'];
    if (id == null) return;
    final namController = TextEditingController(
      text: t['nam_hoc']?.toString() ?? '',
    );
    final hocKyController = TextEditingController(
      text: t['hoc_ky']?.toString() ?? '',
    );
    final soTuanController = TextEditingController(
      text: t['so_tuan']?.toString() ?? '',
    );
    final tuNgayController = TextEditingController(
      text: t['tu_ngay']?.toString() ?? '',
    );
    final denNgayController = TextEditingController(
      text: t['den_ngay']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Cấu trúc thời gian'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namController,
                decoration: const InputDecoration(
                  labelText: 'Năm học (VD: 2026)',
                ),
              ),
              TextField(
                controller: hocKyController,
                decoration: const InputDecoration(labelText: 'Học kỳ'),
              ),
              TextField(
                controller: soTuanController,
                decoration: const InputDecoration(labelText: 'Số tuần'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: tuNgayController,
                decoration: const InputDecoration(
                  labelText: 'Từ ngày (YYYY-MM-DD)',
                ),
              ),
              TextField(
                controller: denNgayController,
                decoration: const InputDecoration(
                  labelText: 'Đến ngày (YYYY-MM-DD)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.put('/cau-truc-cai-dat-thoi-gian/$id', {
                  'nam_hoc': namController.text.trim(),
                  'hoc_ky': hocKyController.text.trim(),
                  'so_tuan': int.tryParse(soTuanController.text.trim()) ?? 0,
                  'tu_ngay': tuNgayController.text.trim(),
                  'den_ngay': denNgayController.text.trim(),
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _fetchAll();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTimeStructure(Map<String, dynamic> t) async {
    final id = t['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa cấu trúc này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    try {
      await ApiService.delete('/cau-truc-cai-dat-thoi-gian/$id');
    } catch (_) {}
    await _fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: AdminLayout(
        title: 'Quản lý Học vụ',
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TabBar(
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.black87,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: const [
                        Tab(text: 'Môn học'),
                        Tab(text: 'Ca học'),
                        Tab(text: 'Lớp học'),
                        Tab(text: 'Cấu trúc thời gian'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSubjectsTab(),
                          _buildSessionsTab(),
                          _buildClassesTab(),
                          _buildTimeStructuresTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addSubject,
              icon: const Icon(Icons.add),
              label: const Text('Thêm môn học'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                              DataColumn(label: Text('Tên môn')),
                              DataColumn(label: Text('Hành động')),
                            ]
                          : const [
                              DataColumn(label: Text('Tên môn')),
                              DataColumn(label: Text('Loại')),
                              DataColumn(label: Text('Tín chỉ')),
                              DataColumn(label: Text('Hành động')),
                            ],
                      rows: subjects.map((s) {
                        if (isCompact) {
                          return DataRow(
                            cells: [
                              DataCell(Text(s['ten_mon']?.toString() ?? '-')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editSubject(s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteSubject(s),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text(s['ten_mon']?.toString() ?? '-')),
                            DataCell(Text(s['loai']?.toString() ?? '-')),
                            DataCell(Text(s['tin_chi']?.toString() ?? '-')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editSubject(s),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteSubject(s),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addSession,
              icon: const Icon(Icons.add),
              label: const Text('Thêm ca học'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                              DataColumn(label: Text('Tên ca')),
                              DataColumn(label: Text('Hành động')),
                            ]
                          : const [
                              DataColumn(label: Text('Tên ca')),
                              DataColumn(label: Text('Giờ bắt đầu')),
                              DataColumn(label: Text('Giờ kết thúc')),
                              DataColumn(label: Text('Hành động')),
                            ],
                      rows: sessions.map((s) {
                        if (isCompact) {
                          return DataRow(
                            cells: [
                              DataCell(Text(s['ten_ca']?.toString() ?? '-')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editSession(s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteSession(s),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text(s['ten_ca']?.toString() ?? '-')),
                            DataCell(Text(s['gio_bat_dau']?.toString() ?? '-')),
                            DataCell(
                              Text(s['gio_ket_thuc']?.toString() ?? '-'),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editSession(s),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteSession(s),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildClassesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addClass,
              icon: const Icon(Icons.add),
              label: const Text('Thêm lớp học'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                              DataColumn(label: Text('Mã lớp')),
                              DataColumn(label: Text('Hành động')),
                            ]
                          : const [
                              DataColumn(label: Text('Mã lớp')),
                              DataColumn(label: Text('Niên khóa')),
                              DataColumn(label: Text('Chuyên ngành')),
                              DataColumn(label: Text('Hành động')),
                            ],
                      rows: classes.map((c) {
                        if (isCompact) {
                          return DataRow(
                            cells: [
                              DataCell(Text(c['ma_lop']?.toString() ?? '-')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editClass(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteClass(c),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text(c['ma_lop']?.toString() ?? '-')),
                            DataCell(Text(c['nien_khoa']?.toString() ?? '-')),
                            DataCell(
                              Text(c['chuyen_nganh']?.toString() ?? '-'),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editClass(c),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteClass(c),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeStructuresTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addTimeStructure,
              icon: const Icon(Icons.add),
              label: const Text('Thêm cấu trúc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                              DataColumn(label: Text('Năm học')),
                              DataColumn(label: Text('Hành động')),
                            ]
                          : const [
                              DataColumn(label: Text('Năm học')),
                              DataColumn(label: Text('Học kỳ')),
                              DataColumn(label: Text('Số tuần')),
                              DataColumn(label: Text('Từ ngày')),
                              DataColumn(label: Text('Đến ngày')),
                              DataColumn(label: Text('Hành động')),
                            ],
                      rows: timeStructures.map((t) {
                        if (isCompact) {
                          return DataRow(
                            cells: [
                              DataCell(Text(t['nam_hoc']?.toString() ?? '-')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editTimeStructure(t),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteTimeStructure(t),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text(t['nam_hoc']?.toString() ?? '-')),
                            DataCell(Text(t['hoc_ky']?.toString() ?? '-')),
                            DataCell(Text(t['so_tuan']?.toString() ?? '-')),
                            DataCell(Text(t['tu_ngay']?.toString() ?? '-')),
                            DataCell(Text(t['den_ngay']?.toString() ?? '-')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editTimeStructure(t),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteTimeStructure(t),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
