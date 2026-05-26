import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({Key? key}) : super(key: key);

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
            onPressed: () {},
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
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.grey.shade100,
                ),
                columns: [
                  const DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      columnLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'Tổng số lượng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const DataColumn(
                    label: Text(
                      'Thao tác',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: data.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Text(item['id'].toString())),
                      DataCell(Text(item['ten_tb'])),
                      DataCell(Text(item['so_luong_tong'].toString())),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {},
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
        ),
      ],
    );
  }
}
