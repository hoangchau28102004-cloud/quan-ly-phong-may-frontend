import 'package:flutter/material.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';
import 'package:flutter_phongmay/presentation/screens/layout/responsive_layout.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class TransferMachineScreen extends StatefulWidget {
  const TransferMachineScreen({super.key});

  @override
  _TransferMachineScreenState createState() => _TransferMachineScreenState();
}

class _TransferMachineScreenState extends State<TransferMachineScreen> {
  List<dynamic> allMachines = [];
  List<dynamic> rooms = [];
  List<dynamic> history = [];

  List<int> selectedIds = [];
  int? sourceRoomId;
  int? targetRoomId;
  final reasonCtrl = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // TẢI DỮ LIỆU TỪ BACKEND
  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final mRes = await ApiService.get('/may-tinh');
      final rRes = await ApiService.get('/phong-may');
      final hRes = await ApiService.get('/transfer-history');

      setState(() {
        allMachines = ApiService.decodeBody(mRes)?['data'] ?? [];
        rooms = ApiService.decodeBody(rRes)?['data'] ?? [];
        history = ApiService.decodeBody(hRes)?['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  // HÀM XỬ LÝ KHI BẤM NÚT "ĐIỀU CHUYỂN"
  Future<void> _handleTransfer() async {
    if (selectedIds.isEmpty || targetRoomId == null || sourceRoomId == null) {
      return;
    }

    // GỌI ĐÚNG API BACKEND
    final res = await ApiService.post('/transfer', {
      'may_tinh_ids': selectedIds,
      'ma_phong_cu': sourceRoomId,
      'ma_phong_moi': targetRoomId,
      'ly_do': reasonCtrl.text,
    });

    final body = ApiService.decodeBody(res);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Điều chuyển thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        selectedIds.clear();
        reasonCtrl.clear();
      });
      _loadData();
    } else {
      final errorMsg =
          body?['message'] ?? body?['error'] ?? 'Lỗi HTTP ${res.statusCode}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Điều chuyển máy',
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobile: _buildContent(),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildTransferForm()),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: _buildHistoryTable()),
                ],
              ),
            ),
    );
  }

  // GIAO DIỆN MOBILE
  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTransferForm(),
        const SizedBox(height: 20),
        _buildHistoryTable(),
      ],
    );
  }

  // GIAO DIỆN FORM ĐIỀU CHUYỂN
  Widget _buildTransferForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin điều chuyển',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Từ phòng cũ',
                border: OutlineInputBorder(),
              ),
              items: rooms
                  .map<DropdownMenuItem<int>>(
                    (r) => DropdownMenuItem(
                      value: (r['id'] as num).toInt(),
                      child: Text(r['ten_phong'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                sourceRoomId = v;
                selectedIds.clear();
              }),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Đến phòng mới',
                border: OutlineInputBorder(),
              ),
              items: rooms
                  .map<DropdownMenuItem<int>>(
                    (r) => DropdownMenuItem(
                      value: (r['id'] as num).toInt(),
                      child: Text(r['ten_phong'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => targetRoomId = v),
            ),
            const SizedBox(height: 15),

            const Text(
              'Danh sách máy:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView(
                // Đã sửa thành ma_phong
                children: allMachines
                    .where(
                      (m) => (m['ma_phong'] as num?)?.toInt() == sourceRoomId,
                    )
                    .map<Widget>(
                      (m) => CheckboxListTile(
                        title: Text(m['ma_may'].toString()),
                        subtitle: Text(m['ten_may'].toString()),
                        value: selectedIds.contains((m['id'] as num).toInt()),
                        onChanged: (v) => setState(
                          () => v!
                              ? selectedIds.add((m['id'] as num).toInt())
                              : selectedIds.remove((m['id'] as num).toInt()),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Lý do điều chuyển',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: (selectedIds.isEmpty || targetRoomId == null)
                    ? null
                    : _handleTransfer,
                icon: const Icon(Icons.swap_horiz),
                label: Text('ĐIỀU CHUYỂN ${selectedIds.length} MÁY'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HÀM TỰ ĐỘNG DỊCH ID PHÒNG SANG TÊN PHÒNG CHO BẢNG LỊCH SỬ ĐẸP MẮT
  String _getRoomName(dynamic roomId) {
    if (roomId == null) return '-';
    final room = rooms.firstWhere(
      (r) => r['id'].toString() == roomId.toString(),
      orElse: () => {},
    );
    return room['ten_phong']?.toString() ?? 'Phòng ID: $roomId';
  }

  // GIAO DIỆN BẢNG LỊCH SỬ
  Widget _buildHistoryTable() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử điều chuyển',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Chưa có dữ liệu điều chuyển nào.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey.shade100,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Mã máy',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Từ phòng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Đến phòng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Lý do',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Thời gian',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: history
                          .map(
                            (h) => DataRow(
                              cells: [
                                DataCell(
                                  Text(h['may_tinh_ids']?.toString() ?? 'N/A'),
                                ),
                                // Đã áp dụng DB MỚI: ma_phong_cu, ma_phong_moi
                                DataCell(Text(_getRoomName(h['ma_phong_cu']))),
                                DataCell(Text(_getRoomName(h['ma_phong_moi']))),
                                DataCell(Text(h['ly_do']?.toString() ?? '')),
                                DataCell(
                                  Text(h['created_at']?.toString() ?? ''),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
