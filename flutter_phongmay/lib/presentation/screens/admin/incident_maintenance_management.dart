import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

class IncidentMaintenanceScreen extends StatefulWidget {
  const IncidentMaintenanceScreen({super.key});

  @override
  State<IncidentMaintenanceScreen> createState() =>
      _IncidentMaintenanceScreenState();
}

class _IncidentMaintenanceScreenState extends State<IncidentMaintenanceScreen> {
  bool loading = true;
  List<Map<String, dynamic>> incidents = [];
  List<Map<String, dynamic>> tickets = [];
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> computers = [];
  String active = 'incidents';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      List<Map<String, dynamic>> iData = [];
      List<Map<String, dynamic>> tData = [];
      List<Map<String, dynamic>> rData = [];
      List<Map<String, dynamic>> cData = [];

      final iResp = await ApiService.get(
        '/bao-cao-su-co?orderBy=created_at&descending=true',
      );
      if (iResp.statusCode == 200) {
        final body = ApiService.decodeBody(iResp);
        if (body != null && body['success'] == true) {
          iData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final tResp = await ApiService.get(
        '/phieu-bao-tri?orderBy=created_at&descending=true',
      );
      if (tResp.statusCode == 200) {
        final body = ApiService.decodeBody(tResp);
        if (body != null && body['success'] == true) {
          tData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final rResp = await ApiService.get('/phong-may');
      if (rResp.statusCode == 200) {
        final body = ApiService.decodeBody(rResp);
        if (body != null && body['success'] == true) {
          rData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final cResp = await ApiService.get('/may-tinh');
      if (cResp.statusCode == 200) {
        final body = ApiService.decodeBody(cResp);
        if (body != null && body['success'] == true) {
          cData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      setState(() {
        incidents = iData;
        tickets = tData;
        rooms = rData;
        computers = cData;
      });
    } catch (_) {}
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AdminLayout(
        title: 'Quản lý Bảo trì',
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
                      'Quản lý Bảo trì & Sự cố',
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
                        Tab(text: 'Báo cáo Sự cố'),
                        Tab(text: 'Phiếu Bảo trì'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [_buildIncidentsTab(), _buildTicketsTab()],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildIncidentsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addIncident,
              icon: const Icon(Icons.add),
              label: const Text('Báo cáo sự cố'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
                                DataColumn(label: Text('Tiêu đề')),
                                DataColumn(label: Text('Ngày')),
                                DataColumn(label: Text('Hành động')),
                              ]
                            : const [
                                DataColumn(label: Text('Tiêu đề')),
                                DataColumn(label: Text('Loại')),
                                DataColumn(label: Text('Phòng')),
                                DataColumn(label: Text('Máy')),
                                DataColumn(label: Text('Ngày')),
                                DataColumn(label: Text('Trạng thái')),
                                DataColumn(label: Text('Hành động')),
                              ],
                        rows: incidents.map((i) {
                          if (isCompact) {
                            return DataRow(
                              cells: [
                                DataCell(Text(i['tieu_de']?.toString() ?? '-')),
                                DataCell(
                                  Text(i['created_at']?.toString() ?? '-'),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editIncident(i),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _deleteIncident(i),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return DataRow(
                            cells: [
                              DataCell(Text(i['tieu_de']?.toString() ?? '-')),
                              DataCell(Text(i['loai']?.toString() ?? '-')),
                              DataCell(Text(i['phong']?.toString() ?? '-')),
                              DataCell(Text(i['may']?.toString() ?? '-')),
                              DataCell(
                                Text(i['created_at']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Text(i['trang_thai']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editIncident(i),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteIncident(i),
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
        ),
      ],
    );
  }

  Widget _buildTicketsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _createTicket,
              icon: const Icon(Icons.add),
              label: const Text('Tạo phiếu bảo trì'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
                                DataColumn(label: Text('Loại bảo trì')),
                                DataColumn(label: Text('Ngày bắt đầu')),
                                DataColumn(label: Text('Hành động')),
                              ]
                            : const [
                                DataColumn(label: Text('Loại bảo trì')),
                                DataColumn(label: Text('Ngày bắt đầu')),
                                DataColumn(label: Text('Ngày kết thúc')),
                                DataColumn(label: Text('Chi phí')),
                                DataColumn(label: Text('Trạng thái')),
                                DataColumn(label: Text('Hành động')),
                              ],
                        rows: tickets.map((t) {
                          if (isCompact) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(t['loai_bao_tri']?.toString() ?? '-'),
                                ),
                                DataCell(
                                  Text(t['ngay_bat_dau']?.toString() ?? '-'),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editTicket(t),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _deleteTicket(t),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(t['loai_bao_tri']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Text(t['ngay_bat_dau']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Text(t['ngay_ket_thuc']?.toString() ?? '-'),
                              ),
                              DataCell(Text(t['chi_phi']?.toString() ?? '-')),
                              DataCell(
                                Text(t['trang_thai']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editTicket(t),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteTicket(t),
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
        ),
      ],
    );
  }

  Future<void> _addIncident() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final typeController = TextEditingController();
    int? selectedRoomId = rooms.isNotEmpty
        ? (rooms.first['id'] as num?)?.toInt()
        : null;
    int? selectedComputerId = computers.isNotEmpty
        ? (computers.first['id'] as num?)?.toInt()
        : null;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Báo cáo sự cố'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              const SizedBox(height: 8),
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
                value: selectedComputerId,
                items: computers
                    .map(
                      (c) => DropdownMenuItem(
                        value: (c['id'] as num?)?.toInt(),
                        child: Text(
                          c['ma_may']?.toString() ??
                              c['ma_may']?.toString() ??
                              '-',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedComputerId = v,
                decoration: const InputDecoration(labelText: 'Máy'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Loại'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
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
              final t = titleController.text.trim();
              final d = descController.text.trim();
              final l = typeController.text.trim();
              if (t.isEmpty) return;
              try {
                await ApiService.post('/bao-cao-su-co', {
                  'tieu_de': t,
                  'mo_ta': d,
                  'loai': l,
                  'phong_id': selectedRoomId,
                  'may_id': selectedComputerId,
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

  Future<void> _createTicket() async {
    final loaiController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final chiPhiController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo phiếu bảo trì'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: loaiController,
              decoration: const InputDecoration(labelText: 'Loại bảo trì'),
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: 'Ngày bắt đầu (YYYY-MM-DD)',
              ),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(
                labelText: 'Ngày kết thúc (YYYY-MM-DD)',
              ),
            ),
            TextField(
              controller: chiPhiController,
              decoration: const InputDecoration(labelText: 'Chi phí'),
              keyboardType: TextInputType.number,
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
              final loai = loaiController.text.trim();
              final start = startController.text.trim();
              final end = endController.text.trim();
              final chi = int.tryParse(chiPhiController.text.trim()) ?? 0;
              if (loai.isEmpty) return;
              try {
                await ApiService.post('/phieu-bao-tri', {
                  'loai_bao_tri': loai,
                  'ngay_bat_dau': start,
                  'ngay_ket_thuc': end,
                  'chi_phi': chi,
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

  Future<void> _editIncident(Map<String, dynamic> i) async {
    final id = i['id'];
    if (id == null) return;
    final titleController = TextEditingController(
      text: i['tieu_de']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: i['mo_ta']?.toString() ?? '',
    );
    final typeController = TextEditingController(
      text: i['loai']?.toString() ?? '',
    );
    int? selectedRoomId =
        (i['phong_id'] as num?)?.toInt() ?? (i['phong'] as int?);
    int? selectedComputerId =
        (i['may_id'] as num?)?.toInt() ?? (i['may'] as int?);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa báo cáo sự cố'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
              ),
              const SizedBox(height: 8),
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
                value: selectedComputerId,
                items: computers
                    .map(
                      (c) => DropdownMenuItem(
                        value: (c['id'] as num?)?.toInt(),
                        child: Text(c['ma_may']?.toString() ?? '-'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedComputerId = v,
                decoration: const InputDecoration(labelText: 'Máy'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Loại'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
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
                await ApiService.put('/bao-cao-su-co/$id', {
                  'tieu_de': titleController.text.trim(),
                  'mo_ta': descController.text.trim(),
                  'loai': typeController.text.trim(),
                  'phong_id': selectedRoomId,
                  'may_id': selectedComputerId,
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

  Future<void> _deleteIncident(Map<String, dynamic> i) async {
    final id = i['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa báo cáo này?'),
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
      await ApiService.delete('/bao-cao-su-co/$id');
    } catch (_) {}
    await _load();
  }

  Future<void> _editTicket(Map<String, dynamic> t) async {
    final id = t['id'];
    if (id == null) return;
    final loaiController = TextEditingController(
      text: t['loai_bao_tri']?.toString() ?? '',
    );
    final startController = TextEditingController(
      text: t['ngay_bat_dau']?.toString() ?? '',
    );
    final endController = TextEditingController(
      text: t['ngay_ket_thuc']?.toString() ?? '',
    );
    final chiController = TextEditingController(
      text: t['chi_phi']?.toString() ?? '0',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa phiếu bảo trì'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: loaiController,
              decoration: const InputDecoration(labelText: 'Loại bảo trì'),
            ),
            TextField(
              controller: startController,
              decoration: const InputDecoration(
                labelText: 'Ngày bắt đầu (YYYY-MM-DD)',
              ),
            ),
            TextField(
              controller: endController,
              decoration: const InputDecoration(
                labelText: 'Ngày kết thúc (YYYY-MM-DD)',
              ),
            ),
            TextField(
              controller: chiController,
              decoration: const InputDecoration(labelText: 'Chi phí'),
              keyboardType: TextInputType.number,
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
                await ApiService.put('/phieu-bao-tri/$id', {
                  'loai_bao_tri': loaiController.text.trim(),
                  'ngay_bat_dau': startController.text.trim(),
                  'ngay_ket_thuc': endController.text.trim(),
                  'chi_phi': int.tryParse(chiController.text.trim()) ?? 0,
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

  Future<void> _deleteTicket(Map<String, dynamic> t) async {
    final id = t['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa phiếu này?'),
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
      await ApiService.delete('/phieu-bao-tri/$id');
    } catch (_) {}
    await _load();
  }
}
