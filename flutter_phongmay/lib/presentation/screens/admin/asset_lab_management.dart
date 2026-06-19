import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';

class AssetLabManagementScreen extends StatefulWidget {
  const AssetLabManagementScreen({super.key});

  @override
  State<AssetLabManagementScreen> createState() =>
      _AssetLabManagementScreenState();
}

class _AssetLabManagementScreenState extends State<AssetLabManagementScreen> {
  bool loading = true;
  List<Map<String, dynamic>> rooms = [];
  List<Map<String, dynamic>> hardware = [];
  List<Map<String, dynamic>> computers = [];

  String activeTab = 'rooms';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      List<Map<String, dynamic>> rData = [];
      List<Map<String, dynamic>> hData = [];
      List<Map<String, dynamic>> cData = [];

      final rResp = await ApiService.get('/phong-may');
      if (rResp.statusCode == 200) {
        final body = ApiService.decodeBody(rResp);
        if (body != null && body['success'] == true) {
          rData = List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }

      final hResp = await ApiService.get('/cau-hinh-may-tinh');
      if (hResp.statusCode == 200) {
        final body = ApiService.decodeBody(hResp);
        if (body != null && body['success'] == true) {
          hData = List<Map<String, dynamic>>.from(body['data'] ?? []);
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
        rooms = rData;
        hardware = hData;
        computers = cData;
      });
    } catch (_) {}
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: AdminLayout(
        title: 'Quản lý Phòng máy & Tài sản',
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
                        Tab(text: 'Phòng máy'),
                        Tab(text: 'Cấu hình'),
                        Tab(text: 'Máy tính'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildRoomsTab(),
                          _buildHardwareTab(),
                          _buildComputersTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _addRoom() async {
    final tenController = TextEditingController();
    final maController = TextEditingController();
    final soMayController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Phòng máy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tenController,
              decoration: const InputDecoration(labelText: 'Tên phòng'),
            ),
            TextField(
              controller: maController,
              decoration: const InputDecoration(labelText: 'Mã phòng'),
            ),
            TextField(
              controller: soMayController,
              decoration: const InputDecoration(labelText: 'Số máy'),
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
              final ten = tenController.text.trim();
              final ma = maController.text.trim();
              final so = int.tryParse(soMayController.text.trim()) ?? 0;
              if (ten.isEmpty) return;
              try {
                await ApiService.post('/phong-may', {
                  'ten_phong': ten,
                  'ma_phong': ma,
                  'so_may': so,
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

  Future<void> _addHardware() async {
    final cpuController = TextEditingController();
    final ramController = TextEditingController();
    final oController = TextEditingController();
    final gpuController = TextEditingController();
    final osController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Cấu hình máy tính'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cpuController,
                decoration: const InputDecoration(labelText: 'CPU'),
              ),
              TextField(
                controller: ramController,
                decoration: const InputDecoration(labelText: 'RAM'),
              ),
              TextField(
                controller: oController,
                decoration: const InputDecoration(labelText: 'Ổ cứng'),
              ),
              TextField(
                controller: gpuController,
                decoration: const InputDecoration(labelText: 'GPU'),
              ),
              TextField(
                controller: osController,
                decoration: const InputDecoration(labelText: 'Hệ điều hành'),
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
              final cpu = cpuController.text.trim();
              final ram = ramController.text.trim();
              final o = oController.text.trim();
              final gpu = gpuController.text.trim();
              final os = osController.text.trim();
              if (cpu.isEmpty) return;
              try {
                await ApiService.post('/cau-hinh-may-tinh', {
                  'bo_xu_ly': cpu,
                  'ram': ram,
                  'o_cung': o,
                  'gpu': gpu,
                  'he_dieu_hanh': os,
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

  Future<void> _addComputer() async {
    final maController = TextEditingController();
    final ipController = TextEditingController();
    final macController = TextEditingController();
    int? selectedRoomId = rooms.isNotEmpty
        ? (rooms.first['id'] as num?)?.toInt()
        : null;
    int? selectedHardwareId = hardware.isNotEmpty
        ? (hardware.first['id'] as num?)?.toInt()
        : null;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm Máy tính'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: maController,
                decoration: const InputDecoration(labelText: 'Mã máy'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedRoomId,
                items: rooms
                    .map(
                      (r) => DropdownMenuItem(
                        value: (r['id'] as num?)?.toInt(),
                        child: Text(r['ten_phong'] ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedRoomId = v,
                decoration: const InputDecoration(labelText: 'Phòng'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedHardwareId,
                items: hardware
                    .map(
                      (h) => DropdownMenuItem(
                        value: (h['id'] as num?)?.toInt(),
                        child: Text(h['bo_xu_ly'] ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedHardwareId = v,
                decoration: const InputDecoration(labelText: 'Cấu hình'),
              ),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: 'IP'),
              ),
              TextField(
                controller: macController,
                decoration: const InputDecoration(labelText: 'MAC'),
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
              final ma = maController.text.trim();
              final ip = ipController.text.trim();
              final mac = macController.text.trim();
              if (ma.isEmpty || selectedRoomId == null) return;
              try {
                await ApiService.post('/may-tinh', {
                  'ma_may': ma,
                  'phong_may_id': selectedRoomId,
                  'cau_hinh_id': selectedHardwareId,
                  'ip': ip,
                  'mac': mac,
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

  Future<void> _editRoom(Map<String, dynamic> r) async {
    final id = r['id'];
    if (id == null) return;
    final tenController = TextEditingController(
      text: r['ten_phong']?.toString() ?? '',
    );
    final maController = TextEditingController(
      text: r['ma_phong']?.toString() ?? '',
    );
    final soMayController = TextEditingController(
      text: r['so_may']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Phòng máy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tenController,
              decoration: const InputDecoration(labelText: 'Tên phòng'),
            ),
            TextField(
              controller: maController,
              decoration: const InputDecoration(labelText: 'Mã phòng'),
            ),
            TextField(
              controller: soMayController,
              decoration: const InputDecoration(labelText: 'Số máy'),
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
                await ApiService.put('/phong-may/$id', {
                  'ten_phong': tenController.text.trim(),
                  'ma_phong': maController.text.trim(),
                  'so_may': int.tryParse(soMayController.text.trim()) ?? 0,
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

  Future<void> _deleteRoom(Map<String, dynamic> r) async {
    final id = r['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa phòng này?'),
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
      await ApiService.delete('/phong-may/$id');
    } catch (_) {}
    await _load();
  }

  Future<void> _editHardware(Map<String, dynamic> h) async {
    final id = h['id'];
    if (id == null) return;
    final cpuController = TextEditingController(
      text: h['bo_xu_ly']?.toString() ?? '',
    );
    final ramController = TextEditingController(
      text: h['ram']?.toString() ?? '',
    );
    final oController = TextEditingController(
      text: h['o_cung']?.toString() ?? '',
    );
    final gpuController = TextEditingController(
      text: h['gpu']?.toString() ?? '',
    );
    final osController = TextEditingController(
      text: h['he_dieu_hanh']?.toString() ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Cấu hình'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cpuController,
                decoration: const InputDecoration(labelText: 'CPU'),
              ),
              TextField(
                controller: ramController,
                decoration: const InputDecoration(labelText: 'RAM'),
              ),
              TextField(
                controller: oController,
                decoration: const InputDecoration(labelText: 'Ổ cứng'),
              ),
              TextField(
                controller: gpuController,
                decoration: const InputDecoration(labelText: 'GPU'),
              ),
              TextField(
                controller: osController,
                decoration: const InputDecoration(labelText: 'Hệ điều hành'),
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
                await ApiService.put('/cau-hinh-may-tinh/$id', {
                  'bo_xu_ly': cpuController.text.trim(),
                  'ram': ramController.text.trim(),
                  'o_cung': oController.text.trim(),
                  'gpu': gpuController.text.trim(),
                  'he_dieu_hanh': osController.text.trim(),
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

  Future<void> _deleteHardware(Map<String, dynamic> h) async {
    final id = h['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa cấu hình này?'),
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
      await ApiService.delete('/cau-hinh-may-tinh/$id');
    } catch (_) {}
    await _load();
  }

  Future<void> _editComputer(Map<String, dynamic> c) async {
    final id = c['id'];
    if (id == null) return;
    final maController = TextEditingController(
      text: c['ma_may']?.toString() ?? '',
    );
    final ipController = TextEditingController(text: c['ip']?.toString() ?? '');
    final macController = TextEditingController(
      text: c['mac']?.toString() ?? '',
    );
    int? selectedRoomId = rooms.isNotEmpty
        ? (rooms.first['id'] as num?)?.toInt()
        : null;
    int? selectedHardwareId = hardware.isNotEmpty
        ? (hardware.first['id'] as num?)?.toInt()
        : null;
    selectedRoomId = (c['phong_may_id'] as num?)?.toInt() ?? selectedRoomId;
    selectedHardwareId =
        (c['cau_hinh_id'] as num?)?.toInt() ?? selectedHardwareId;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chỉnh sửa Máy tính'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: maController,
                decoration: const InputDecoration(labelText: 'Mã máy'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedRoomId,
                items: rooms
                    .map(
                      (r) => DropdownMenuItem(
                        value: (r['id'] as num?)?.toInt(),
                        child: Text(r['ten_phong'] ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedRoomId = v,
                decoration: const InputDecoration(labelText: 'Phòng'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: selectedHardwareId,
                items: hardware
                    .map(
                      (h2) => DropdownMenuItem(
                        value: (h2['id'] as num?)?.toInt(),
                        child: Text(h2['bo_xu_ly'] ?? ''),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedHardwareId = v,
                decoration: const InputDecoration(labelText: 'Cấu hình'),
              ),
              TextField(
                controller: ipController,
                decoration: const InputDecoration(labelText: 'IP'),
              ),
              TextField(
                controller: macController,
                decoration: const InputDecoration(labelText: 'MAC'),
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
                await ApiService.put('/may-tinh/$id', {
                  'ma_may': maController.text.trim(),
                  'phong_may_id': selectedRoomId,
                  'cau_hinh_id': selectedHardwareId,
                  'ip': ipController.text.trim(),
                  'mac': macController.text.trim(),
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

  Future<void> _deleteComputer(Map<String, dynamic> c) async {
    final id = c['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa máy tính này?'),
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
      await ApiService.delete('/may-tinh/$id');
    } catch (_) {}
    await _load();
  }

  Future<void> _showRoomMap() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sơ đồ phòng'),
        content: const Text('Hiển thị sơ đồ phòng chưa được triển khai.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _showComputerQr(Map<String, dynamic> c) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR Máy tính'),
        content: Text('Mã máy: ${c['ma_may'] ?? '-'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addRoom,
              icon: const Icon(Icons.add),
              label: const Text('Thêm phòng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showRoomMap,
              icon: const Icon(Icons.grid_view),
              label: const Text('Xem sơ đồ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
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
                                DataColumn(label: Text('Tên phòng')),
                                DataColumn(label: Text('Hành động')),
                              ]
                            : const [
                                DataColumn(label: Text('Tên phòng')),
                                DataColumn(label: Text('Mã phòng')),
                                DataColumn(label: Text('Số máy')),
                                DataColumn(label: Text('Hành động')),
                              ],
                        rows: rooms.map((r) {
                          if (isCompact) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(r['ten_phong']?.toString() ?? '-'),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editRoom(r),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _deleteRoom(r),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return DataRow(
                            cells: [
                              DataCell(Text(r['ten_phong']?.toString() ?? '-')),
                              DataCell(Text(r['ma_phong']?.toString() ?? '-')),
                              DataCell(Text((r['so_may']?.toString() ?? '-'))),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editRoom(r),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteRoom(r),
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

  Widget _buildHardwareTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addHardware,
              icon: const Icon(Icons.add),
              label: const Text('Thêm cấu hình'),
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
                                DataColumn(label: Text('CPU')),
                                DataColumn(label: Text('Hành động')),
                              ]
                            : const [
                                DataColumn(label: Text('CPU')),
                                DataColumn(label: Text('RAM')),
                                DataColumn(label: Text('Ổ cứng')),
                                DataColumn(label: Text('GPU')),
                                DataColumn(label: Text('HĐH')),
                                DataColumn(label: Text('Hành động')),
                              ],
                        rows: hardware.map((h) {
                          if (isCompact) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(h['bo_xu_ly']?.toString() ?? '-'),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editHardware(h),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _deleteHardware(h),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return DataRow(
                            cells: [
                              DataCell(Text(h['bo_xu_ly']?.toString() ?? '-')),
                              DataCell(Text(h['ram']?.toString() ?? '-')),
                              DataCell(Text(h['o_cung']?.toString() ?? '-')),
                              DataCell(Text(h['gpu']?.toString() ?? '-')),
                              DataCell(
                                Text(h['he_dieu_hanh']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editHardware(h),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () => _deleteHardware(h),
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

  Widget _buildComputersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _addComputer,
              icon: const Icon(Icons.add),
              label: const Text('Thêm máy tính'),
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
                                DataColumn(label: Text('Mã máy')),
                                DataColumn(label: Text('Trạng thái')),
                                DataColumn(label: Text('Hành động')),
                              ]
                            : const [
                                DataColumn(label: Text('Mã máy')),
                                DataColumn(label: Text('Phòng')),
                                DataColumn(label: Text('IP')),
                                DataColumn(label: Text('MAC')),
                                DataColumn(label: Text('Trạng thái')),
                                DataColumn(label: Text('Hành động')),
                              ],
                        rows: computers.map((c) {
                          if (isCompact) {
                            return DataRow(
                              cells: [
                                DataCell(Text(c['ma_may']?.toString() ?? '-')),
                                DataCell(
                                  Text(c['trang_thai']?.toString() ?? '-'),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editComputer(c),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.qr_code),
                                        onPressed: () => _showComputerQr(c),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return DataRow(
                            cells: [
                              DataCell(Text(c['ma_may']?.toString() ?? '-')),
                              DataCell(Text(c['ten_phong']?.toString() ?? '-')),
                              DataCell(Text(c['ip']?.toString() ?? '-')),
                              DataCell(Text(c['mac']?.toString() ?? '-')),
                              DataCell(
                                Text(c['trang_thai']?.toString() ?? '-'),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => _editComputer(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.qr_code),
                                      onPressed: () => _showComputerQr(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteComputer(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteComputer(c),
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
}
