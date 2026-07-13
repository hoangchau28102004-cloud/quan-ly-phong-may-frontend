import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';

const Color kAppBlue = Color(0xFF193D87);

class SelectMachineToBorrowScreen extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  const SelectMachineToBorrowScreen({super.key, required this.ticketData});

  @override
  State<SelectMachineToBorrowScreen> createState() =>
      _SelectMachineToBorrowScreenState();
}

class _SelectMachineToBorrowScreenState
    extends State<SelectMachineToBorrowScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _availableMachines = [];
  List<Map<String, dynamic>> _rooms = [];
  
  // 🚀 THÊM: Biến quản lý bộ lọc phòng máy
  String _selectedRoomFilter = 'Tất cả';
  List<String> _availableRoomsList = ['Tất cả'];
  
  // Set lưu trữ ID của các máy được tick chọn
  final Set<int> _selectedMachineIds = {};
  
  late int _requiredQuantity;

  @override
  void initState() {
    super.initState();
    // Lấy số lượng máy yêu cầu từ form Bước 1 truyền sang
    _requiredQuantity = widget.ticketData['so_luong'] as int;
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch danh sách phòng (để lấy tên phòng hiển thị cho đẹp)
      final rResp = await ApiService.get('/phong-may');
      if (rResp.statusCode == 200) {
        final rBody = ApiService.decodeBody(rResp);
        _rooms = List<Map<String, dynamic>>.from(rBody['data'] ?? rBody ?? []);
      }

      // 2. Fetch danh sách máy tính
      final cResp = await ApiService.get('/may-tinh');
      if (cResp.statusCode == 200) {
        final cBody = ApiService.decodeBody(cResp);
        final allMachines = List<Map<String, dynamic>>.from(cBody['data'] ?? cBody ?? []);

        // NGHIỆP VỤ QUAN TRỌNG: Chỉ lấy những máy đang 'active'
        _availableMachines = allMachines.where((m) {
          final status = (m['trang_thai'] ?? '').toString().toLowerCase();
          return status == 'active';
        }).toList();

        // 🚀 THÊM: Tạo danh sách các phòng máy (bỏ trùng lặp) để đưa lên thanh Filter
        final Set<String> roomNames = {};
        for (var m in _availableMachines) {
          final room = _rooms.firstWhere(
            (r) => r['id'].toString() == m['ma_phong'].toString(),
            orElse: () => {},
          );
          roomNames.add(room['ten_phong'] ?? 'Khác');
        }
        _availableRoomsList = ['Tất cả', ...roomNames.toList()];
      }
    } catch (e) {
      debugPrint('Lỗi fetch data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // Hàm xử lý khi ấn Nút Submit
  Future<void> _submitBorrowTicket() async {
    setState(() => _isSubmitting = true);

    // Chuẩn bị Payload bắn lên Backend
    final payload = {
      ...widget.ticketData, // Bung toàn bộ data từ Bước 1 vào đây
      'may_tinh_ids': _selectedMachineIds.toList(), // Gắn thêm mảng ID máy tính
    };

    try {
        final res = await ApiService.post('/borrow-return/muon-may', payload);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo phiếu mượn & xuất máy thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          // Trở về trang Dashboard của Admin (Pop về root)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        throw Exception('Lỗi tạo phiếu từ Server');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo phiếu mượn. Vui lòng thử lại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Biến kiểm tra xem đã chọn đủ số lượng chưa
    bool isEnough = _selectedMachineIds.length == _requiredQuantity;

    // 🚀 THÊM: Lọc danh sách máy tính theo phòng đã chọn trên thanh Filter
    final filteredMachines = _availableMachines.where((m) {
      if (_selectedRoomFilter == 'Tất cả') return true;
      final room = _rooms.firstWhere(
        (r) => r['id'].toString() == m['ma_phong'].toString(),
        orElse: () => {},
      );
      final rName = room['ten_phong'] ?? 'Khác';
      return rName == _selectedRoomFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        title: const Text('Chọn máy tính xuất kho', style: TextStyle(fontSize: 18)),
        backgroundColor: kAppBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAppBlue))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thanh Header báo cáo tiến độ chọn máy
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Số lượng cần mượn', style: TextStyle(color: Colors.black54)),
                          Text(
                            'Đã chọn: ${_selectedMachineIds.length} / $_requiredQuantity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isEnough ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (isEnough)
                        const Icon(Icons.check_circle, color: Colors.green, size: 30),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 🚀 THÊM: Thanh trượt ngang (ChoiceChip) chọn bộ lọc phòng máy
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _availableRoomsList.length,
                    itemBuilder: (context, index) {
                      final roomName = _availableRoomsList[index];
                      final isSelected = _selectedRoomFilter == roomName;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            roomName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: kAppBlue,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? kAppBlue : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                _selectedRoomFilter = roomName;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Danh sách máy tính (Đã áp dụng biến lọc filteredMachines)
                Expanded(
                  child: filteredMachines.isEmpty
                      ? const Center(child: Text('Không có máy tính nào phù hợp.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          itemCount: filteredMachines.length,
                          itemBuilder: (context, index) {
                            final m = filteredMachines[index];
                            final machineId = (m['id'] as num).toInt();
                            
                            // Tìm tên phòng
                            final room = _rooms.firstWhere(
                              (r) => r['id'].toString() == m['ma_phong'].toString(),
                              orElse: () => {},
                            );
                            final roomName = room['ten_phong'] ?? 'Chưa xếp phòng';
                            
                            bool isSelected = _selectedMachineIds.contains(machineId);

                            return Card(
                              elevation: isSelected ? 2 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected ? kAppBlue : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: CheckboxListTile(
                                activeColor: kAppBlue,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                title: Text(
                                  m['ma_may'] ?? 'N/A',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('📍 $roomName\n⚙️ ${m['bo_xu_ly'] ?? '-'} | ${m['ram'] ?? '-'}'),
                                value: isSelected,
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      // Kiểm tra nếu chọn quá số lượng thì báo lỗi
                                      if (_selectedMachineIds.length >= _requiredQuantity) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Chỉ được chọn tối đa $_requiredQuantity máy!'),
                                            backgroundColor: Colors.orange,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        _selectedMachineIds.add(machineId);
                                      }
                                    } else {
                                      _selectedMachineIds.remove(machineId);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      
      // Bottom Navigation Bar chứa nút Submit
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isEnough ? kAppBlue : Colors.grey, // Đủ máy mới đổi màu xanh
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: (!isEnough || _isSubmitting) ? null : _submitBorrowTicket,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Xác nhận tạo Phiếu Mượn',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}