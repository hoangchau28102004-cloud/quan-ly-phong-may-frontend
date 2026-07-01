import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key});

  @override
  _AdminCategoryScreenState createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  final Color primaryNavy = const Color(0xFF1D357A);

  List<Map<String, dynamic>> _thietBi = [];
  List<Map<String, dynamic>> _lopHoc = [];
  List<Map<String, dynamic>> _monHoc = [];
  List<Map<String, dynamic>> _caHoc = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final res1 = await ApiService.get('/thiet-bi');
      if (res1.statusCode == 200) {
        final body = ApiService.decodeBody(res1);
        if (body != null && body['success'] == true) {
          _thietBi = List<Map<String, dynamic>>.from(body['data']);
        }
      }

      final res2 = await ApiService.get('/lop-hoc');
      if (res2.statusCode == 200) {
        final body = ApiService.decodeBody(res2);
        if (body != null && body['success'] == true) {
          _lopHoc = List<Map<String, dynamic>>.from(body['data']);
        }
      }

      try {
        final res3 = await ApiService.get('/mon-hoc');
        if (res3.statusCode == 200) {
          final body3 = ApiService.decodeBody(res3);
          if (body3 != null && body3['success'] == true) {
            _monHoc = List<Map<String, dynamic>>.from(body3['data']);
          }
        }
      } catch (_) {}

      try {
        final res4 = await ApiService.get('/ca-hoc');
        if (res4.statusCode == 200) {
          final body4 = ApiService.decodeBody(res4);
          if (body4 != null && body4['success'] == true) {
            _caHoc = List<Map<String, dynamic>>.from(body4['data']);
          }
        }
      } catch (_) {}
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _addCategoryItem(String categoryName) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm $categoryName'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Tên'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              String endpoint = '/thiet-bi';
              Map<String, dynamic> payload = {};
              final key = categoryName.toLowerCase();
              if (key.contains('thiết')) {
                endpoint = '/thiet-bi';
                payload = {'ten_tb': name, 'so_luong_tong': 0};
              } else if (key.contains('lớp') || key.contains('lop')) {
                endpoint = '/lop-hoc';
                payload = {'ma_lop': name};
              } else if (key.contains('môn') || key.contains('mon')) {
                endpoint = '/mon-hoc';
                payload = {'ten_mon': name};
              } else if (key.contains('ca')) {
                endpoint = '/ca-hoc';
                payload = {'ten_ca': name};
              }
              try {
                await ApiService.post(endpoint, payload);
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _loadData();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _editCategoryItem(
    Map<String, dynamic> item,
    String categoryName,
  ) async {
    final id = item['id'];
    if (id == null) return;
    final ctrl = TextEditingController();
    final key = categoryName.toLowerCase();
    String initial = '';
    if (key.contains('thiết')) initial = item['ten_tb']?.toString() ?? '';
    if (key.contains('lớp')) initial = item['ma_lop']?.toString() ?? '';
    if (key.contains('môn')) initial = item['ten_mon']?.toString() ?? '';
    if (key.contains('ca')) initial = item['ten_ca']?.toString() ?? '';
    ctrl.text = initial;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Chỉnh sửa $categoryName'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Tên'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              String endpoint = '/thiet-bi';
              Map<String, dynamic> payload = {};
              if (key.contains('thiết')) {
                endpoint = '/thiet-bi/$id';
                payload = {'ten_tb': name};
              } else if (key.contains('lớp')) {
                endpoint = '/lop-hoc/$id';
                payload = {'ma_lop': name};
              } else if (key.contains('môn')) {
                endpoint = '/mon-hoc/$id';
                payload = {'ten_mon': name};
              } else if (key.contains('ca')) {
                endpoint = '/ca-hoc/$id';
                payload = {'ten_ca': name};
              }
              try {
                await ApiService.put(endpoint, payload);
              } catch (_) {}
              Navigator.of(ctx).pop();
              await _loadData();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategoryItem(
    Map<String, dynamic> item,
    String categoryName,
  ) async {
    final id = item['id'];
    if (id == null) return;
    final ok =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc muốn xóa mục này?'),
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
    final key = categoryName.toLowerCase();
    String endpoint = '/thiet-bi/$id';
    if (key.contains('lớp') || key.contains('lop')) endpoint = '/lop-hoc/$id';
    if (key.contains('môn') || key.contains('mon')) endpoint = '/mon-hoc/$id';
    if (key.contains('ca')) endpoint = '/ca-hoc/$id';
    try {
      await ApiService.delete(endpoint);
    } catch (_) {}
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F9),
        appBar: AppBar(
          title: const Text(
            'Quản Lý Danh Mục Cơ Bản',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: primaryNavy,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(text: 'THIẾT BỊ'),
              Tab(text: 'LỚP HỌC'),
              Tab(text: 'MÔN HỌC'),
              Tab(text: 'CA HỌC'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: TabBarView(
            children: [
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCategoryTab('Thiết Bị', 'Tên thiết bị', _thietBi),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: _lopHoc.length,
                        itemBuilder: (context, index) {
                          final item = _lopHoc[index];
                          return ListTile(title: Text(item['ma_lop'] ?? ''));
                        },
                      ),
                    ),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: _monHoc.length,
                        itemBuilder: (context, index) {
                          final item = _monHoc[index];
                          return ListTile(title: Text(item['ten_mon'] ?? ''));
                        },
                      ),
                    ),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ListView.builder(
                        itemCount: _caHoc.length,
                        itemBuilder: (context, index) {
                          final item = _caHoc[index];
                          return ListTile(
                            title: Text(item['gio_bat_dau'] ?? ''),
                            subtitle: Text(item['gio_ket_thuc'] ?? ''),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(
    String categoryName,
    String columnLabel,
    List<Map<String, dynamic>> data,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 45,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            onPressed: () => _addCategoryItem(categoryName),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              'Thêm $categoryName',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
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
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade100,
                        ),
                        columnSpacing: 24,
                        columns: isCompact
                            ? [
                                const DataColumn(
                                  label: Text(
                                    'ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Thao tác',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ]
                            : [
                                const DataColumn(
                                  label: Text(
                                    'ID',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    columnLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Tổng số lượng',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const DataColumn(
                                  label: Text(
                                    'Thao tác',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                        rows: data.map((item) {
                          if (isCompact) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['id'].toString())),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _editCategoryItem(
                                          item,
                                          categoryName,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteCategoryItem(
                                          item,
                                          categoryName,
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
                              DataCell(Text(item['id'].toString())),
                              DataCell(Text(item['ten_tb'])),
                              DataCell(Text(item['so_luong_tong'].toString())),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () =>
                                          _editCategoryItem(item, categoryName),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteCategoryItem(
                                        item,
                                        categoryName,
                                      ),
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
