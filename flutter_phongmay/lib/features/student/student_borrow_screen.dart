import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ), // Ép vuông góc
      ),
      body: Column(
        children: [
          // 1. Thanh tìm kiếm vuông vức
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Tìm kiếm thiết bị phòng máy...',
                prefixIcon: Icon(Icons.search, color: primaryNavy),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero, // 0px border radius
                  borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: primaryNavy, width: 2),
                ),
              ),
            ),
          ),

          // 2. Danh sách thiết bị dạng GridView (Lưới) vuông vức
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: _equipmentList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // Chia làm 2 cột
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75, // Tỷ lệ khung thẻ hiển thị
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
                            borderRadius: BorderRadius.zero, // Thẻ vuông vức
                          ),
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ảnh minh họa thiết bị (Khung vuông)
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
                              // Tên thiết bị
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
                              // Số lượng còn lại trong kho
                              Text(
                                'Còn lại: ${item['so_luong_con']}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Bộ điều khiển số lượng mượn
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

          // 3. Nút gửi yêu cầu mượn dính sát đáy (Full-width)
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
                      borderRadius: BorderRadius.zero, // Ép vuông góc tuyệt đối
                    ),
                  ),
                  onPressed: () {
                    // Xử lý logic thu thập các item có selected_qty > 0
                    // Gọi API lưu dữ liệu vào bảng phieu_muon
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
