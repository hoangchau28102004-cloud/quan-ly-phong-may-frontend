import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

class StudentBorrowScreen extends StatefulWidget {
  const StudentBorrowScreen({super.key});

  @override
  State<StudentBorrowScreen> createState() => _StudentBorrowScreenState();
}

class _StudentBorrowScreenState extends State<StudentBorrowScreen> {
  final Color primaryNavy = const Color(0xFF1D357A);

  List<Map<String, dynamic>> _equipmentList = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/thiet-bi');
      if (res.statusCode == 200) {
        final body = ApiService.decodeBody(res);
        if (body != null && body['success'] == true) {
          _equipmentList = List<Map<String, dynamic>>.from(body['data']);
          for (var e in _equipmentList) {
            e['selected_qty'] = 0;
          }
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text(
          'Đăng Ký Mượn Thiết Bị',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryNavy,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Tìm kiếm thiết bị phòng máy...',
                prefixIcon: Icon(Icons.search, color: primaryNavy),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: primaryNavy, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: _equipmentList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                      itemBuilder: (context, index) {
                        final item = _equipmentList[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFD1D5DB),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 90,
                                color: const Color(0xFFE5E7EB),
                                child: Icon(
                                  Icons.hardware_outlined,
                                  size: 40,
                                  color: primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['ten_tb'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Còn lại: ${item['so_luong_con']}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (item['selected_qty'] > 0) {
                                        setState(() => item['selected_qty']--);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: primaryNavy),
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        size: 16,
                                        color: primaryNavy,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item['selected_qty']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (item['selected_qty'] <
                                          item['so_luong_con']) {
                                        setState(() => item['selected_qty']++);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: primaryNavy,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () async {
                    final selected = _equipmentList
                        .where((e) => (e['selected_qty'] as int? ?? 0) > 0)
                        .toList();
                    if (selected.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Vui lòng chọn thiết bị trước khi gửi yêu cầu',
                          ),
                        ),
                      );
                      return;
                    }
                    await showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xác nhận'),
                        content: Text(
                          'Bạn có chắc muốn gửi yêu cầu mượn ${selected.length} mục không?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Gửi yêu cầu (giả lập) thành công',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Gửi'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Gửi Yêu Cầu Mượn Thiết Bị',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
