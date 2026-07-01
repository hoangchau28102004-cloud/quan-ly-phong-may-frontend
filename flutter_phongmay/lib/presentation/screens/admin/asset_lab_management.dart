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
  List<Map<String, dynamic>> computers = [];
  int? filterRoomId;
  String filterStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      List<Map<String, dynamic>> rData = [];
      List<Map<String, dynamic>> cData = [];

      final rResp = await ApiService.get('/phong-may');
      if (rResp.statusCode == 200) {
        final body = ApiService.decodeBody(rResp);
        if (body != null) {
          if (body is List) {
            rData = List<Map<String, dynamic>>.from(body);
          } else if (body['success'] == true) {
            rData = List<Map<String, dynamic>>.from(body['data'] ?? []);
          } else if (body['data'] != null) {
            rData = List<Map<String, dynamic>>.from(body['data'] ?? []);
          }
        }
      }

      final cResp = await ApiService.get('/may-tinh');
      if (cResp.statusCode == 200) {
        final body = ApiService.decodeBody(cResp);
        if (body != null) {
          if (body is List) {
            cData = List<Map<String, dynamic>>.from(body);
          } else if (body['success'] == true) {
            cData = List<Map<String, dynamic>>.from(body['data'] ?? []);
          } else if (body['data'] != null) {
            cData = List<Map<String, dynamic>>.from(body['data'] ?? []);
          }
        }
      }

      setState(() {
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
        title: 'Quản lý Phòng máy & Tài sản',
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.all(12.0),
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
                        Tab(text: 'Phòng máy', icon: Icon(Icons.meeting_room)),
                        Tab(text: 'Máy tính', icon: Icon(Icons.computer)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [_buildRoomsTab(), _buildComputersTab()],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ===================== LOGIC THÊM/SỬA/XÓA PHÒNG MÁY =====================
  Future<void> _addRoom() async {
    final tenController = TextEditingController();
    final maController = TextEditingController();
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tenController.text.trim().isEmpty) return;
              bool success = false;
              try {
                final resp = await ApiService.post('/phong-may', {
                  'ten_phong': tenController.text.trim(),
                  'ma_phong': maController.text.trim(),
                });
                final body = ApiService.decodeBody(resp);
                success =
                    resp.statusCode == 200 ||
                    resp.statusCode == 201 ||
                    (body != null && body['success'] == true);
              } catch (_) {
                success = false;
              }
              Navigator.of(ctx).pop();
              await _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Thêm phòng thành công.'
                          : 'Không thể thêm phòng. Vui lòng thử lại.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              bool success = false;
              try {
                final resp = await ApiService.put('/phong-may/$id', {
                  'ten_phong': tenController.text.trim(),
                  'ma_phong': maController.text.trim(),
                });
                final body = ApiService.decodeBody(resp);
                success =
                    resp.statusCode == 200 ||
                    resp.statusCode == 201 ||
                    (body != null && body['success'] == true);
              } catch (_) {
                success = false;
              }
              Navigator.of(ctx).pop();
              await _load();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Cập nhật phòng thành công.'
                          : 'Không thể cập nhật phòng. Vui lòng thử lại.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
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
    bool success = false;
    try {
      final resp = await ApiService.delete('/phong-may/$id');
      final body = ApiService.decodeBody(resp);
      success =
          resp.statusCode == 200 ||
          resp.statusCode == 201 ||
          (body != null && body['success'] == true);
    } catch (_) {
      success = false;
    }
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Xóa phòng thành công.'
                : 'Không thể xóa phòng. Vui lòng thử lại.',
          ),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  // ===================== LOGIC SỬA MÁY TÍNH =====================
  Future<void> _editComputer(Map<String, dynamic> c) async {
    final id = c['id'];
    if (id == null) return;

    final maController = TextEditingController(
      text: c['ma_may']?.toString() ?? c['ten_may']?.toString() ?? '',
    );
    int? selectedRoomId =
        (c['phong_id'] as num?)?.toInt() ??
        (c['ma_phong'] as num?)?.toInt() ??
        (rooms.isNotEmpty ? (rooms.first['id'] as num?)?.toInt() : null);
    String selectedStatus =
        c['trang_thai']?.toString().toLowerCase() ?? 'active';
    
    // Bóc tách dữ liệu cấu hình ĐÃ GỘP từ máy tính đổ vào Giao diện
    String oldCpu = c['bo_xu_ly']?.toString() ?? '';
    String cpuBrand = oldCpu.toLowerCase().contains('amd')
        ? 'AMD'
        : (oldCpu.toLowerCase().contains('apple') ? 'Apple' : 'Intel');
    final cpuDetailCtrl = TextEditingController(
      text: oldCpu
          .replaceAll(RegExp(r'intel|amd|apple', caseSensitive: false), '')
          .trim(),
    );

    String oldRam = c['ram']?.toString() ?? '';
    String ramCapacity = [
      '4GB',
      '8GB',
      '16GB',
      '32GB',
      '64GB',
    ].firstWhere((cap) => oldRam.contains(cap), orElse: () => '8GB');
    final ramBrandCtrl = TextEditingController(
      text: oldRam.replaceAll(ramCapacity, '').trim(),
    );

    String oldStorage = c['ssd']?.toString() ?? c['hdd']?.toString() ?? '';
    String storageType = oldStorage.toLowerCase().contains('hdd')
        ? 'HDD'
        : 'SSD';
    String storageCapacity = [
      '128GB',
      '256GB',
      '512GB',
      '1TB',
      '2TB',
    ].firstWhere((cap) => oldStorage.contains(cap), orElse: () => '512GB');

    String oldGpu = c['card_do_hoa']?.toString() ?? 'Card Onboard';
    String gpuType =
        ['Card Onboard', 'NVIDIA GeForce', 'AMD Radeon'].contains(oldGpu)
        ? oldGpu
        : 'Khác';

    final mainboardCtrl = TextEditingController(
      text: c['bo_mach_chu']?.toString() ?? '',
    );
    final keyboardCtrl = TextEditingController(
      text: c['ban_phim']?.toString() ?? '',
    );
    final mouseCtrl = TextEditingController(text: c['chuot']?.toString() ?? '');
    final monitorCtrl = TextEditingController(
      text: c['man_hinh']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Chỉnh sửa Máy tính'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'THÔNG TIN CHUNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    TextField(
                      controller: maController,
                      decoration: const InputDecoration(
                        labelText: 'Mã máy (Bắt buộc)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      initialValue: selectedRoomId,
                      items: rooms
                          .map(
                            (r) => DropdownMenuItem(
                              value: (r['id'] as num?)?.toInt(),
                              child: Text(r['ten_phong'] ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedRoomId = v),
                      decoration: const InputDecoration(labelText: 'Phòng'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue:
                          [
                            'active',
                            'draft',
                            'maintenance',
                          ].contains(selectedStatus)
                          ? selectedStatus
                          : 'active',
                      items: const [
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Active (Đang dùng)'),
                        ),
                        DropdownMenuItem(
                          value: 'draft',
                          child: Text('Draft (Bản nháp)'),
                        ),
                        DropdownMenuItem(
                          value: 'maintenance',
                          child: Text('Bảo trì'),
                        ),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => selectedStatus = v ?? 'active'),
                      decoration: const InputDecoration(
                        labelText: 'Trạng thái',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // =================== GIAO DIỆN CẤU HÌNH MỚI ===================
                    const Text(
                      'CẤU HÌNH PHẦN CỨNG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Hãng CPU',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: cpuBrand,
                            items: ['Intel', 'AMD', 'Apple', 'Khác']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => cpuBrand = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: cpuDetailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Thế hệ / Mã CPU',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ramBrandCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Hãng RAM',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Dung lượng',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: ramCapacity,
                            items: ['4GB', '8GB', '16GB', '32GB', '64GB']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => ramCapacity = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Card đồ họa',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: gpuType,
                      items:
                          [
                                'Card Onboard',
                                'NVIDIA GeForce',
                                'AMD Radeon',
                                'Khác',
                              ]
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (v) => setDialogState(() => gpuType = v!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: mainboardCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bo mạch chủ',
                        hintText: 'VD: H610M',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: monitorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Màn hình',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Ổ cứng',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: storageType,
                            items: ['SSD', 'HDD']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => storageType = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Dung lượng',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: storageCapacity,
                            items: ['128GB', '256GB', '512GB', '1TB', '2TB']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => storageCapacity = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: keyboardCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bàn phím',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: mouseCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Chuột',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final maMay = maController.text.trim();
                  if (maMay.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lỗi: Bạn chưa nhập Mã Máy!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  try {
                    // GHÉP CHUỖI CẤU HÌNH TỪ GIAO DIỆN (Đã bỏ OS)
                    String finalCpu = '$cpuBrand ${cpuDetailCtrl.text.trim()}'
                        .trim();
                    String finalRam = '${ramBrandCtrl.text.trim()} $ramCapacity'
                        .trim();
                    String finalGhiChu =
                        'Bo mạch chủ: ${mainboardCtrl.text.trim()} | Bàn phím: ${keyboardCtrl.text.trim()} | Chuột: ${mouseCtrl.text.trim()}';
                    
                    // CHỈ GỌI DUY NHẤT 1 API SỬA MÁY TÍNH
                    final compRes = await ApiService.put('/may-tinh/$id', {
                      'ma_may': maMay,
                      'ten_may': maMay,
                      'ma_phong': selectedRoomId,
                      'trang_thai': selectedStatus,

                      // Cập nhật thẳng cấu hình vào máy tính
                      'bo_xu_ly': finalCpu,
                      'ram': finalRam,
                      'hdd': storageType == 'HDD' ? storageCapacity : null,
                      'ssd': storageType == 'SSD' ? storageCapacity : null,
                      'card_do_hoa': gpuType,
                      'man_hinh': monitorCtrl.text.trim().isEmpty
                          ? null
                          : monitorCtrl.text.trim(),
                      'bo_mach_chu': mainboardCtrl.text.trim().isEmpty
                          ? null
                          : mainboardCtrl.text.trim(),
                      'ban_phim': keyboardCtrl.text.trim().isEmpty
                          ? null
                          : keyboardCtrl.text.trim(),
                      'chuot': mouseCtrl.text.trim().isEmpty
                          ? null
                          : mouseCtrl.text.trim(),
                      'ghi_chu': finalGhiChu,
                    });

                    if (compRes.statusCode == 200 ||
                        compRes.statusCode == 201) {
                      Navigator.of(ctx).pop();
                      await _load();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sửa máy tính thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      final errBody = ApiService.decodeBody(compRes);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'LỖI SERVER: ${errBody?['error'] ?? errBody?['message'] ?? compRes.statusCode}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('LỖI KẾT NỐI: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
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

  // ===================== SƠ ĐỒ PHÒNG =====================
  void _showRoomMap() {
    if (rooms.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có phòng máy nào!')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn phòng xem sơ đồ'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final r = rooms[index];
                return ListTile(
                  leading: const Icon(
                    Icons.room_preferences,
                    color: Colors.blue,
                  ),
                  title: Text(r['ten_phong'] ?? ''),
                  onTap: () {
                    Navigator.pop(context);
                    _openMapLayout(r);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _openMapLayout(Map<String, dynamic> room) {
    final roomId = room['id'];
    final bool isKho = room['ten_phong'].toString().toLowerCase().contains(
      'kho',
    );

    // Lọc máy tính theo phòng
    final roomComputers = computers
        .where((c) => c['ma_phong']?.toString() == roomId?.toString())
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sơ đồ: ${room['ten_phong']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: roomComputers.isEmpty
                      ? const Center(
                          child: Text('Phòng này chưa có máy tính nào.'),
                        )
                      : isKho
                      ? ListView.builder(
                          itemCount: roomComputers.length,
                          itemBuilder: (ctx, i) =>
                              _buildComputerTile(roomComputers[i], room),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 150,
                                childAspectRatio: 1,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: roomComputers.length,
                          itemBuilder: (ctx, i) =>
                              _buildComputerGridItem(roomComputers[i], room),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComputerGridItem(
    Map<String, dynamic> c,
    Map<String, dynamic> room,
  ) {
    bool isActive = (c['trang_thai'] ?? 'active') == 'active';
    final cpu = c['bo_xu_ly'] ?? '-';
    final ram = c['ram'] ?? '-';

    return InkWell(
      onTap: () => _showComputerDetails(c, room['ten_phong']),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade50 : Colors.red.shade50,
          border: Border.all(
            color: isActive ? Colors.blue : Colors.red,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.computer,
              size: 30,
              color: isActive ? Colors.blue : Colors.red,
            ),
            const SizedBox(height: 5),
            Text(
              c['ma_may']?.toString() ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
            const SizedBox(height: 5),
            Text(
              'CPU: $cpu',
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'RAM: $ram',
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComputerTile(Map<String, dynamic> c, Map<String, dynamic> room) {
    final cpu = c['bo_xu_ly'] ?? '-';
    final ram = c['ram'] ?? '-';
    final storage = c['ssd'] ?? c['hdd'] ?? '-';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.computer, color: Colors.blue),
        title: Text(c['ma_may'] ?? ''),
        subtitle: Text('CPU: $cpu | RAM: $ram | Lưu trữ: $storage'),
        onTap: () => _showComputerDetails(c, room['ten_phong']),
      ),
    );
  }

  // ===================== GIAO DIỆN PHÒNG MÁY =====================
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
          child: ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final r = rooms[index];
              final soMayThucTe = computers
                  .where(
                    (c) => c['ma_phong']?.toString() == r['id']?.toString(),
                  )
                  .length;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(
                      Icons.meeting_room,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  title: Text(
                    r['ten_phong']?.toString() ?? '-',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Mã: ${r['ma_phong'] ?? '-'} • Đang có: $soMayThucTe máy',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => _editRoom(r),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteRoom(r),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===================== GIAO DIỆN MÁY TÍNH =====================
  Widget _buildComputersTab() {
    final filteredComputers = computers.where((c) {
      bool matchRoom =
          filterRoomId == null ||
          c['ma_phong']?.toString() == filterRoomId?.toString();
      String status = c['trang_thai']?.toString() ?? 'active';
      bool matchStatus =
          filterStatus == 'Tất cả' ||
          status.toLowerCase() == filterStatus.toLowerCase();
      return matchRoom && matchStatus;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Giao diện Lọc
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: filterRoomId,
                    hint: const Text(
                      'Tất cả phòng',
                      style: TextStyle(fontSize: 14),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text(
                          'Tất cả phòng',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      ...rooms.map(
                        (r) => DropdownMenuItem<int?>(
                          value: (r['id'] as num?)?.toInt(),
                          child: Text(
                            r['ten_phong']?.toString() ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => filterRoomId = val),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: filterStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'Tất cả',
                        child: Text(
                          'Mọi trạng thái',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text(
                          'Active (Đang dùng)',
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'draft',
                        child: Text(
                          'Draft (Bản nháp)',
                          style: TextStyle(fontSize: 14, color: Colors.orange),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text(
                          'Bảo trì',
                          style: TextStyle(fontSize: 14, color: Colors.red),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => filterStatus = val ?? 'Tất cả'),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (filteredComputers.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Không tìm thấy máy tính nào phù hợp với bộ lọc.',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

        if (filteredComputers.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: filteredComputers.length,
              itemBuilder: (context, index) {
                final c = filteredComputers[index];
                final room = rooms.firstWhere(
                  (r) => r['id']?.toString() == c['ma_phong']?.toString(),
                  orElse: () => {},
                );

                final cpu = c['bo_xu_ly'] ?? 'N/A';
                final ram = c['ram'] ?? 'N/A';
                final storage = c['ssd'] ?? c['hdd'] ?? 'N/A';
                final roomName =
                    c['ten_phong'] ?? room['ten_phong'] ?? 'Chưa xếp';
                bool isActive =
                    (c['trang_thai'] ?? 'active').toString().toLowerCase() ==
                    'active';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showComputerDetails(c, roomName),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.desktop_windows,
                                    color: Colors.blue.shade700,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    c['ma_may']?.toString() ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editComputer(c);
                                  } else if (value == 'qr')
                                    _showComputerQr(c);
                                  else if (value == 'delete')
                                    _deleteComputer(c);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Sửa'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'qr',
                                    child: Row(
                                      children: [
                                        Icon(Icons.qr_code, size: 20),
                                        SizedBox(width: 8),
                                        Text('Mã QR'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Xóa',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 10, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '📍 $roomName',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  c['trang_thai']?.toString().toUpperCase() ??
                                      'ACTIVE',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.green.shade800
                                        : Colors.red.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildTechBadge(Icons.memory, cpu),
                              _buildTechBadge(Icons.memory_outlined, ram),
                              _buildTechBadge(Icons.save, storage),
                            ],
                          ),
                        ],
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

  Widget _buildTechBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  // ===================== BOTTOM SHEET CHI TIẾT =====================
  void _showComputerDetails(Map<String, dynamic> c, String roomName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chi tiết Máy Tính',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Mã máy', c['ma_may']),
                  _buildDetailRow('Phòng', roomName),
                  _buildDetailRow(
                    'Trạng thái',
                    c['trang_thai']?.toString().toUpperCase() ?? 'ACTIVE',
                  ),
                  const Divider(height: 30),
                  Text(
                    'Cấu hình chi tiết',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow('CPU', c['bo_xu_ly']),
                  _buildDetailRow('RAM', c['ram']),
                  _buildDetailRow('Ổ cứng', c['ssd'] ?? c['hdd']),
                  _buildDetailRow('VGA/GPU', c['card_do_hoa']),
                  _buildDetailRow('Bo mạch chủ', c['bo_mach_chu']),
                  _buildDetailRow('Màn hình', c['man_hinh']),
                  _buildDetailRow('Bàn phím', c['ban_phim']),
                  _buildDetailRow('Chuột', c['chuot']),
                  _buildDetailRow('Ghi chú', c['ghi_chu']),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}