import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

class SchedulingManagementScreen extends StatefulWidget {
  const SchedulingManagementScreen({super.key});

  @override
  State<SchedulingManagementScreen> createState() =>
      _SchedulingManagementScreenState();
}

class _SchedulingManagementScreenState
    extends State<SchedulingManagementScreen> {
  bool loading = true;
  List<Map<String, dynamic>> schedules = [];
  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> caList = [];
  List<Map<String, dynamic>> classList = [];
  String active = 'schedule';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      List<Map<String, dynamic>> sData = [];
      List<Map<String, dynamic>> bData = [];
      List<Map<String, dynamic>> rData = [];
      List<Map<String, dynamic>> caData = [];
      List<Map<String, dynamic>> cData = [];

      final sResp = await ApiService.get(
        '/lich-su-dung-phong-may?orderBy=ngay_hoc_cu_the',
      );
      if (sResp.statusCode == 200) {
        final body = ApiService.decodeBody(sResp);
        if (body != null && body['success'] == true) {
          sData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final bResp = await ApiService.get('/dat-phong-may?orderBy=ngay_dat');
      if (bResp.statusCode == 200) {
        final body = ApiService.decodeBody(bResp);
        if (body != null && body['success'] == true) {
          bData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final rResp = await ApiService.get('/phong-may');
      if (rResp.statusCode == 200) {
        final body = ApiService.decodeBody(rResp);
        if (body != null && body['success'] == true) {
          rData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final caResp = await ApiService.get('/ca-hoc');
      if (caResp.statusCode == 200) {
        final body = ApiService.decodeBody(caResp);
        if (body != null && body['success'] == true) {
          caData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final lResp = await ApiService.get('/lop-hoc');
      if (lResp.statusCode == 200) {
        final body = ApiService.decodeBody(lResp);
        if (body != null && body['success'] == true) {
          cData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      setState(() {
        schedules = sData;
        bookings = bData;
        rooms = rData;
        caList = caData;
        classList = cData;
      });
    } catch (_) {}
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AdminLayout(
        title: 'Quản lý Lịch phòng',
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
                    const Text(
                      'Quản lý Lịch Phòng máy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TabBar(
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Colors.black87,
                      indicatorColor: Theme.of(context).primaryColor,
                      tabs: const [
                        Tab(text: 'Lịch Phòng máy'),
                        Tab(text: 'Yêu cầu Đặt phòng'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [_buildScheduleTab(), _buildBookingsTab()],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addSchedule,
              icon: const Icon(Icons.add),
              label: const Text('Xếp lịch mới'),
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
                  // ensure minWidth is finite; fallback to screen width
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
                              DataColumn(label: Text('Phòng')),
                              DataColumn(label: Text('Ngày')),
                              DataColumn(label: Text('Hành động')),
                            ]
                          : const [
                              DataColumn(label: Text('Phòng')),
                              DataColumn(label: Text('Lớp học phần')),
                              DataColumn(label: Text('Ngày')),
                              DataColumn(label: Text('Ca')),
                              DataColumn(label: Text('Tiết')),
                              DataColumn(label: Text('Loại lịch')),
                              DataColumn(label: Text('Hành động')),
                            ],
                      rows: schedules.map((s) {
                        if (isCompact) {
                          return DataRow(
                            cells: [
                              DataCell(Text(s['phong']?.toString() ?? '-')),
                              DataCell(
                                Text(s['ngay_hoc_cu_the']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editSchedule(s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteSchedule(s),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text(s['phong']?.toString() ?? '-')),
                            DataCell(
                              Text(s['lop_hoc_phan']?.toString() ?? '-'),
                            ),
                            DataCell(
                              Text(s['ngay_hoc_cu_the']?.toString() ?? '-'),
                            ),
                            DataCell(Text(s['ca_hoc']?.toString() ?? '-')),
                            DataCell(Text(s['tiet']?.toString() ?? '-')),
                            DataCell(Text(s['loai_lich']?.toString() ?? '-')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editSchedule(s),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteSchedule(s),
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

  Widget _buildBookingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
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
                              DataColumn(label: Text('Người đặt')),
                              DataColumn(label: Text('Phòng')),
                              DataColumn(label: Text('Hành động')),
                            ]
                          : const [
                              DataColumn(label: Text('Người đặt')),
                              DataColumn(label: Text('Phòng')),
                              DataColumn(label: Text('Ngày đặt')),
                              DataColumn(label: Text('Ngày sử dụng')),
                              DataColumn(label: Text('Mục đích')),
                              DataColumn(label: Text('Trạng thái')),
                              DataColumn(label: Text('Hành động')),
                            ],
                      rows: bookings.map((b) {
                        if (isCompact) {
                          return DataRow(
                            cells: [
                              DataCell(Text(b['nguoi_dat']?.toString() ?? '-')),
                              DataCell(Text(b['phong']?.toString() ?? '-')),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () => _approveBooking(b),
                                      child: const Text('Duyệt'),
                                    ),
                                    TextButton(
                                      onPressed: () => _rejectBooking(b),
                                      child: const Text('Từ chối'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return DataRow(
                          cells: [
                            DataCell(Text(b['nguoi_dat']?.toString() ?? '-')),
                            DataCell(Text(b['phong']?.toString() ?? '-')),
                            DataCell(Text(b['ngay_dat']?.toString() ?? '-')),
                            DataCell(
                              Text(b['ngay_su_dung']?.toString() ?? '-'),
                            ),
                            DataCell(Text(b['muc_dich']?.toString() ?? '-')),
                            DataCell(Text(b['trang_thai']?.toString() ?? '-')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () => _approveBooking(b),
                                    child: const Text('Duyệt'),
                                  ),
                                  TextButton(
                                    onPressed: () => _rejectBooking(b),
                                    child: const Text('Từ chối'),
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

  Future<void> _addSchedule() async {
    int? selectedRoomId = rooms.isNotEmpty
        ? (rooms.first['id'] as num?)?.toInt()
        : null;
    int? selectedClassId = classList.isNotEmpty
        ? (classList.first['id'] as num?)?.toInt()
        : null;
    int? selectedCaId = caList.isNotEmpty
        ? (caList.first['id'] as num?)?.toInt()
        : null;
    final tietController = TextEditingController();
    final loaiController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xếp lịch mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedRoomId,
                items: rooms
                    .map(
                      (r) => DropdownMenuItem(
                        value: (r['id'] as num?)?.toInt(),
                        child: Text(r['ten_phong']?.toString() ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedRoomId = v,
                decoration: const InputDecoration(labelText: 'Phòng'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedClassId,
                items: classList
                    .map(
                      (c) => DropdownMenuItem(
                        value: (c['id'] as num?)?.toInt(),
                        child: Text(
                          c['ma_lop']?.toString() ??
                              c['ma_lop']?.toString() ??
                              '-',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedClassId = v,
                decoration: const InputDecoration(labelText: 'Lớp học phần'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedCaId,
                items: caList
                    .map(
                      (c) => DropdownMenuItem(
                        value: (c['id'] as num?)?.toInt(),
                        child: Text(c['ten_ca']?.toString() ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedCaId = v,
                decoration: const InputDecoration(labelText: 'Ca'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tietController,
                decoration: const InputDecoration(labelText: 'Tiết'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: loaiController,
                decoration: const InputDecoration(labelText: 'Loại lịch'),
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
              final phongId = selectedRoomId;
              final lopId = selectedClassId;
              final caId = selectedCaId;
              final tiet = tietController.text.trim();
              final loai = loaiController.text.trim();
              if (phongId == null) return;
              try {
                await ApiService.post('/lich-su-dung-phong-may', {
                  'phong_id': phongId,
                  'lop_hoc_phan_id': lopId,
                  'ca_hoc_id': caId,
                  'tiet': tiet,
                  'loai_lich': loai,
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _load();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _editSchedule(Map<String, dynamic> s) async {
    final id = s['id'];
    if (id == null) return;
    int? selectedRoomId =
        (s['phong_id'] as num?)?.toInt() ?? (s['phong_id'] as int?);
    int? selectedClassId =
        (s['lop_hoc_phan_id'] as num?)?.toInt() ??
        (s['lop_hoc_phan_id'] as int?);
    int? selectedCaId =
        (s['ca_hoc_id'] as num?)?.toInt() ?? (s['ca_hoc_id'] as int?);
    final tietController = TextEditingController(
      text: s['tiet']?.toString() ?? '',
    );
    final loaiController = TextEditingController(
      text: s['loai_lich']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa lịch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedRoomId,
                items: rooms
                    .map(
                      (r) => DropdownMenuItem(
                        value: (r['id'] as num?)?.toInt(),
                        child: Text(r['ten_phong']?.toString() ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedRoomId = v,
                decoration: const InputDecoration(labelText: 'Phòng'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedClassId,
                items: classList
                    .map(
                      (c) => DropdownMenuItem(
                        value: (c['id'] as num?)?.toInt(),
                        child: Text(c['ma_lop']?.toString() ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedClassId = v,
                decoration: const InputDecoration(labelText: 'Lớp học phần'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedCaId,
                items: caList
                    .map(
                      (c) => DropdownMenuItem(
                        value: (c['id'] as num?)?.toInt(),
                        child: Text(c['ten_ca']?.toString() ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedCaId = v,
                decoration: const InputDecoration(labelText: 'Ca'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: tietController,
                decoration: const InputDecoration(labelText: 'Tiết'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: loaiController,
                decoration: const InputDecoration(labelText: 'Loại lịch'),
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
                await ApiService.put('/lich-su-dung-phong-may/$id', {
                  'phong_id': selectedRoomId,
                  'lop_hoc_phan_id': selectedClassId,
                  'ca_hoc_id': selectedCaId,
                  'tiet': tietController.text.trim(),
                  'loai_lich': loaiController.text.trim(),
                });
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _load();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSchedule(Map<String, dynamic> s) async {
    final id = s['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa lịch này?'),
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
      await ApiService.delete('/lich-su-dung-phong-may/$id');
    } catch (_) {}
    await _load();
  }

  Future<void> _approveBooking(Map<String, dynamic> b) async {
    final id = b['id'];
    if (id == null) return;
    try {
      await ApiService.put('/dat-phong-may/$id', {'trang_thai': 'duyet'});
    } catch (_) {}
    await _load();
  }

  Future<void> _rejectBooking(Map<String, dynamic> b) async {
    final id = b['id'];
    if (id == null) return;
    try {
      await ApiService.put('/dat-phong-may/$id', {'trang_thai': 'tu_choi'});
    } catch (_) {}
    await _load();
  }
}
