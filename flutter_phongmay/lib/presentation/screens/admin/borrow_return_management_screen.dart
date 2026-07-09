import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';
import '../../widgets/admin_assign_machine_dialog.dart'; // 🚀 Import Widget Popup duyệt máy
import 'package:intl/intl.dart';

class BorrowReturnManagementScreen extends StatefulWidget {
  const BorrowReturnManagementScreen({super.key});

  @override
  State<BorrowReturnManagementScreen> createState() => _BorrowReturnManagementScreenState();
}

class _BorrowReturnManagementScreenState extends State<BorrowReturnManagementScreen> {
  bool isLoading = true;
  List<dynamic> borrows = [];
  List<dynamic> returns = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final resM = await ApiService.get('/muon-may');
      final resT = await ApiService.get('/tra-may');
      
      if (mounted) {
        setState(() {
          borrows = ApiService.decodeBody(resM)?['data'] ?? [];
          returns = ApiService.decodeBody(resT)?['data'] ?? [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        debugPrint('Lỗi tải dữ liệu: $e');
      }
    }
  }

  // 🚀 LOGIC MỚI: Xử lý hiển thị Popup cho Admin chọn máy cấp phát
  Future<void> _handleApproveBorrow(dynamic item) async {
    bool? isAssigned = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Bắt buộc thao tác, không cho bấm ra ngoài để tắt
      builder: (context) => AdminAssignMachineDialog(
        phieuId: item['id'], 
        requiredQuantity: item['so_luong'] ?? 1, // Lấy số lượng GV yêu cầu, mặc định là 1 nếu null
      ),
    );

    // Nếu Admin cấp máy thành công -> Tải lại danh sách
    if (isAssigned == true) {
      _loadData();
    }
  }

  // Cập nhật trạng thái phiếu mượn (Dùng cho nút Hủy/Từ chối)
  Future<void> _updateBorrow(int id, String status) async {
    try {
      await ApiService.put('/muon-may/$id', {'trang_thai': status});
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật phiếu mượn!'), backgroundColor: Colors.green));
      _loadData();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  // Xác nhận trả (Cập nhật phiếu mượn gốc thành 'Đã trả')
  Future<void> _confirmReturn(int returnId, int? borrowId) async {
    if (borrowId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phiếu trả này không liên kết với phiếu mượn nào!'), backgroundColor: Colors.orange));
      return;
    }
    try {
      await ApiService.put('/tra-may/$returnId', {'ma_phieu_muon_id': borrowId});
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xác nhận thu hồi máy thành công!'), backgroundColor: Colors.green));
      _loadData();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'đang mượn': return Colors.orange;
      case 'đã duyệt': return Colors.blue;
      case 'đã trả': return Colors.green;
      case 'từ chối': return Colors.red;
      default: return Colors.blueGrey;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'N/A';
    try {
      DateTime dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (e) {
      return isoDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AdminLayout(
        title: 'Quản lý Mượn / Trả máy',
        child: Column(
          children: [
            // ==========================================
            // TABBAR BO TRÒN (KIỂU iOS)
            // ==========================================
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 50,
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(25)),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                labelColor: Colors.blue.shade800,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: 'Danh Sách Phiếu Mượn'), Tab(text: 'Lịch Sử Trả Máy')],
              ),
            ),
            
            // ==========================================
            // NỘI DUNG TỪNG TAB
            // ==========================================
            Expanded(
              child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    children: [
                      _buildBorrowList(),
                      _buildReturnList(),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================================
  // TAB 1: DANH SÁCH MƯỢN MÁY
  // =======================================================================
  Widget _buildBorrowList() {
    if (borrows.isEmpty) return _buildEmptyState('Chưa có yêu cầu mượn máy nào!');
    
    return ListView.builder(
      itemCount: borrows.length,
      itemBuilder: (context, index) {
        final item = borrows[index];
        final status = item['trang_thai'] ?? 'Chưa rõ';
        final List machines = item['danh_sach_may'] ?? [];
        
        return _buildCardWrapper(
          type: 'muon',
          status: status,
          title: 'Mã phiếu: ${item['ma_phieu_muon']} - ${item['ten_nguoi_muon'] ?? 'Ẩn danh'}',
          date: 'Ngày mượn: ${_formatDate(item['ngay_muon'])}',
          department: item['ten_phong_ban'],
          reason: item['ly_do_muon'],
          machines: machines,
          actions: (status == 'Đang mượn' || status == 'Chờ duyệt') ? [
            // NÚT TỪ CHỐI
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red, 
                side: const BorderSide(color: Colors.red), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () => _updateBorrow(item['id'], 'Từ chối'),
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Hủy / Từ chối'),
            ),
            const SizedBox(width: 12),
            
            // 🚀 NÚT DUYỆT & CẤP MÁY
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700, 
                foregroundColor: Colors.white, 
                elevation: 0, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              onPressed: () => _handleApproveBorrow(item), // Đổi hàm thực thi ở đây
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Duyệt & Cấp máy'),
            ),
          ] : [],
        );
      },
    );
  }

  // =======================================================================
  // TAB 2: LỊCH SỬ TRẢ MÁY
  // =======================================================================
  Widget _buildReturnList() {
    if (returns.isEmpty) return _buildEmptyState('Chưa có lịch sử trả máy nào!');
    
    return ListView.builder(
      itemCount: returns.length,
      itemBuilder: (context, index) {
        final item = returns[index];
        final List machines = item['danh_sach_may'] ?? [];
        
        return _buildCardWrapper(
          type: 'tra',
          status: 'Hoàn tất',
          title: 'Mã phiếu trả: ${item['ma_phieu_tra']} - ${item['ten_nguoi_tra'] ?? 'Ẩn danh'}',
          date: 'Thời gian trả: ${_formatDate(item['thoi_gian_tra'])}',
          department: 'Liên kết phiếu mượn: ${item['ma_phieu_goc'] ?? 'N/A'}',
          reason: item['ghi_chu'],
          machines: machines,
          actions: [
            // Nút Xác nhận trả (Sẽ update phiếu mượn gốc)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _confirmReturn(item['id'], item['ma_phieu_muon']),
              icon: const Icon(Icons.inventory, size: 18),
              label: const Text('Ghi nhận đã thu máy vào Kho'),
            ),
          ],
        );
      },
    );
  }

  // =======================================================================
  // WIDGET DÙNG CHUNG: THẺ BO GÓC CAO CẤP
  // =======================================================================
  Widget _buildCardWrapper({required String type, required String status, required String title, required String date, String? department, String? reason, required List machines, required List<Widget> actions}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          
          leading: CircleAvatar(
            backgroundColor: (type == 'muon' ? _getStatusColor(status) : Colors.blueGrey).withOpacity(0.15),
            radius: 24,
            child: Icon(type == 'muon' ? Icons.upload_rounded : Icons.download_rounded, color: type == 'muon' ? _getStatusColor(status) : Colors.blueGrey),
          ),
          
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1D357A))),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: (type == 'muon' ? _getStatusColor(status) : Colors.green).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, color: type == 'muon' ? _getStatusColor(status) : Colors.green, fontWeight: FontWeight.bold)),
                ),
                Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          
          children: [
            const Divider(height: 1),
            Container(
              color: const Color(0xFFF9FAFC),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (department != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('🏢 Khoa/Phòng: $department', style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (reason != null && reason.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text('📝 Lý do / Ghi chú: $reason', style: const TextStyle(fontStyle: FontStyle.italic))),
                  
                  const Text('💻 Danh sách máy tính:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 8),
                  
                  if (machines.isEmpty) const Text('  (Không có dữ liệu máy)'),
                  ...machines.map((m) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.computer, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${m['ten_may'] ?? 'N/A'} (Mã: ${m['ma_may'] ?? 'N/A'})', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (m['tinh_trang'] != null) Text('Tình trạng: ${m['tinh_trang']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              if (m['ghi_chu_ct'] != null) Text('Ghi chú: ${m['ghi_chu_ct']}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            
            if (actions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.white,
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}