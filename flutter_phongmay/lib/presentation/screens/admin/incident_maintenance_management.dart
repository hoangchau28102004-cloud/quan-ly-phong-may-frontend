import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/presentation/screens/admin/admin_layout.dart';
import 'package:flutter_phongmay/presentation/screens/layout/responsive_layout.dart';
// Import Tab Nhật ký
import 'package:flutter_phongmay/presentation/screens/admin/maintenance_log_tab.dart'; 

class IncidentMaintenanceManagementScreen extends StatefulWidget {
  const IncidentMaintenanceManagementScreen({super.key});

  @override
  State<IncidentMaintenanceManagementScreen> createState() =>
      _IncidentMaintenanceManagementScreenState();
}

class _IncidentMaintenanceManagementScreenState
    extends State<IncidentMaintenanceManagementScreen> with SingleTickerProviderStateMixin {
  
  late TabController _tabController;

  bool isLoading = true;
  List<dynamic> incidents = [];
  List<dynamic> tickets = [];
  List<dynamic> logs = []; // Đã khởi tạo mảng rỗng để tránh lỗi Null

  List<dynamic> computers = [];
  List<dynamic> users = [];

  String _incidentStatusFilter = 'all';
  String _ticketStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Đổi thành 3 Tab
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final iRes = await ApiService.get('/bao-cao-su-co');
      final tRes = await ApiService.get('/phieu-bao-tri');
      
      // Gọi API lấy Nhật ký
      dynamic lRes;
      try { lRes = await ApiService.get('/nhat-ky-sua-chua'); } catch (e) { debugPrint('Lỗi tải nhật ký: $e'); }

      dynamic cRes, uRes;
      try { cRes = await ApiService.get('/may-tinh'); } catch (e) { debugPrint('Lỗi tải máy: $e'); }
      try { uRes = await ApiService.get('/nguoi-dung'); } catch (e) { debugPrint('Lỗi tải người dùng: $e'); }

      setState(() {
        incidents = ApiService.decodeBody(iRes)?['data'] ?? [];
        tickets = ApiService.decodeBody(tRes)?['data'] ?? [];
        logs = (lRes != null) ? (ApiService.decodeBody(lRes)?['data'] ?? []) : []; // Ép kiểu an toàn chống Null
        computers = (cRes != null) ? (ApiService.decodeBody(cRes)?['data'] ?? []) : [];
        users = (uRes != null) ? (ApiService.decodeBody(uRes)?['data'] ?? []) : [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e'), backgroundColor: Colors.red));
      }
    }
    setState(() => isLoading = false);
  }

  InputDecoration _customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade400)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
    );
  }

  List<DropdownMenuItem<int>> _safeMap(List<dynamic> list, String emptyText, String Function(dynamic) labelMapper) {
    final items = <DropdownMenuItem<int>>[
      DropdownMenuItem(value: null, child: Text(emptyText, style: const TextStyle(color: Colors.grey))),
    ];
    items.addAll(list.map<DropdownMenuItem<int>>(
      (item) => DropdownMenuItem(value: item['id'] as int?, child: Text(labelMapper(item))),
    ));
    return items;
  }

  int? _getValidId(dynamic id, List<dynamic> list) {
    if (id == null) return null;
    final parsedId = int.tryParse(id.toString());
    if (parsedId != null && list.any((e) => e['id'] == parsedId)) return parsedId;
    return null;
  }

  String _normalizeLoaiBaoTri(String? val) {
    if (val == null) return 'Sửa chữa';
    final lower = val.toLowerCase();
    if (lower.contains('thay')) return 'Thay thế';
    if (lower.contains('vệ sinh') || lower.contains('bảo dưỡng')) return 'Vệ sinh';
    return 'Sửa chữa';
  }

  String _normalizeTrangThaiPhieu(String? val) {
    if (val == null) return 'pending';
    final lower = val.toLowerCase();
    if (lower.contains('progress')) return 'in_progress';
    if (lower.contains('complet') || lower.contains('hoàn')) return 'completed';
    return 'pending';
  }

  void _openTicketModal({Map<String, dynamic>? incidentItem, Map<String, dynamic>? ticketItem}) {
    bool isFromApprove = incidentItem != null && ticketItem == null;

    int? selectedIncidentId = _getValidId(ticketItem?['ma_bao_cao_su_co'] ?? incidentItem?['id'], incidents);
    int? selectedAssigneeId = _getValidId(ticketItem?['ma_nguoi_phu_trach'], users);

    final cachXuLyCtrl = TextEditingController(text: ticketItem?['cach_xu_ly'] ?? '');
    final chiPhiCtrl = TextEditingController(text: (ticketItem?['chi_phi'] ?? 0).toString());
    
    String loaiBaoTri = _normalizeLoaiBaoTri(ticketItem?['loai_bao_tri']);
    String trangThai = _normalizeTrangThaiPhieu(ticketItem?['trang_thai']);

    DateTime? startDate = ticketItem?['ngay_bat_dau'] != null ? DateTime.tryParse(ticketItem!['ngay_bat_dau'].toString()) : DateTime.now();
    DateTime? endDate = ticketItem?['ngay_ket_thuc'] != null ? DateTime.tryParse(ticketItem!['ngay_ket_thuc'].toString()) : null;

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 20),
            child: DraggableScrollableSheet(
              initialChildSize: 0.85, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
              builder: (_, scrollController) => SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 50, height: 6, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 24),
                    Text(
                      ticketItem == null ? 'Duyệt & Tạo Phiếu Bảo Trì' : 'Cập nhật Phiếu', 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)
                    ),
                    const SizedBox(height: 24),
                    
                    DropdownButtonFormField<int>(
                      isExpanded: true, initialValue: selectedIncidentId, 
                      decoration: _customInputDecoration('Sự cố liên quan (*)').copyWith(fillColor: Colors.grey.shade100, filled: true),
                      items: _safeMap(incidents, 'Không có sự cố nào', (i) => 'ID: ${i['id']} - ${i['tieu_de']}'),
                      onChanged: null, 
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            isExpanded: true, initialValue: selectedAssigneeId, 
                            decoration: _customInputDecoration('Người phụ trách').copyWith(fillColor: isFromApprove ? Colors.grey.shade100 : Colors.white, filled: isFromApprove),
                            items: _safeMap(users, 'Chưa phân công', (u) => u['ho_ten']),
                            onChanged: isFromApprove ? null : (v) => setModalState(() => selectedAssigneeId = v),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true, initialValue: loaiBaoTri, 
                            decoration: _customInputDecoration('Loại bảo trì').copyWith(fillColor: isFromApprove ? Colors.grey.shade100 : Colors.white, filled: isFromApprove),
                            items: const [
                              DropdownMenuItem(value: 'Sửa chữa', child: Text('Sửa chữa')),
                              DropdownMenuItem(value: 'Thay thế', child: Text('Thay thế linh kiện')),
                              DropdownMenuItem(value: 'Vệ sinh', child: Text('Vệ sinh/Bảo dưỡng')),
                            ],
                            onChanged: isFromApprove ? null : (v) => setModalState(() => loaiBaoTri = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: isFromApprove ? null : () async {
                              final d = await showDatePicker(context: context, initialDate: startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                              if (d != null) setModalState(() => startDate = d);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isFromApprove ? Colors.grey.shade100 : Colors.transparent, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                              child: Text(startDate != null ? 'Bắt đầu: ${DateFormat('dd/MM/yyyy').format(startDate!)}' : 'Ngày bắt đầu', style: const TextStyle(fontSize: 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: isFromApprove ? null : () async {
                              final d = await showDatePicker(context: context, initialDate: endDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                              if (d != null) setModalState(() => endDate = d);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isFromApprove ? Colors.grey.shade100 : Colors.transparent, border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                              child: Text(endDate != null ? 'Hoàn thành: ${DateFormat('dd/MM/yyyy').format(endDate!)}' : 'Ngày hoàn thành', style: const TextStyle(fontSize: 14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: chiPhiCtrl, keyboardType: TextInputType.number, readOnly: isFromApprove,
                            decoration: _customInputDecoration('Chi phí (VNĐ)').copyWith(fillColor: isFromApprove ? Colors.grey.shade100 : Colors.white, filled: isFromApprove)
                          )
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true, initialValue: trangThai, 
                            decoration: _customInputDecoration('Trạng thái').copyWith(fillColor: isFromApprove ? Colors.grey.shade100 : Colors.white, filled: isFromApprove),
                            items: const [
                              DropdownMenuItem(value: 'pending', child: Text('Chưa xử lý')),
                              DropdownMenuItem(value: 'in_progress', child: Text('Đang tiến hành')),
                              DropdownMenuItem(value: 'completed', child: Text('Đã hoàn tất')),
                            ],
                            onChanged: isFromApprove ? null : (v) => setModalState(() => trangThai = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: cachXuLyCtrl, decoration: _customInputDecoration('Cách xử lý / Ghi chú'), maxLines: 2),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          if (selectedIncidentId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn Sự cố!'), backgroundColor: Colors.red)); return; }
                          final payload = {
                            'ma_bao_cao_su_co': selectedIncidentId, 'ma_nguoi_phu_trach': selectedAssigneeId, 'loai_bao_tri': loaiBaoTri,
                            'ngay_bat_dau': startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : null,
                            'ngay_ket_thuc': endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : null,
                            'cach_xu_ly': cachXuLyCtrl.text, 'chi_phi': double.tryParse(chiPhiCtrl.text) ?? 0, 'trang_thai': trangThai,
                          };
                          
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            if (ticketItem == null) { 
                              await ApiService.post('/phieu-bao-tri', payload); 
                              if (isFromApprove) {
                                await ApiService.put('/bao-cao-su-co/${incidentItem['id']}', {
                                  'tieu_de': incidentItem['tieu_de'],
                                  'ma_may_tinh': incidentItem['ma_may_tinh'],
                                  'loai_su_co': incidentItem['loai_su_co'],
                                  'muc_do': incidentItem['muc_do'],
                                  'trang_thai': 'in_progress', 
                                  'mo_ta': incidentItem['mo_ta']
                                });
                              }
                              messenger.showSnackBar(const SnackBar(content: Text('Duyệt sự cố & Tạo phiếu thành công!'), backgroundColor: Colors.green));
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx); 
                              await _loadData();
                              _tabController.animateTo(1); 
                            } else { 
                              await ApiService.put('/phieu-bao-tri/${ticketItem['id']}', payload); 

                              final originalIncident = incidents.firstWhere((inc) => inc['id'] == selectedIncidentId, orElse: () => null);
                              if (originalIncident != null) {
                                String newIncidentStatus = originalIncident['trang_thai'];
                                if (trangThai == 'completed') newIncidentStatus = 'closed';
                                else if (trangThai == 'in_progress') newIncidentStatus = 'in_progress';
                                else if (trangThai == 'pending') newIncidentStatus = 'open';

                                if (newIncidentStatus != originalIncident['trang_thai']) {
                                  await ApiService.put('/bao-cao-su-co/$selectedIncidentId', {
                                    'tieu_de': originalIncident['tieu_de'],
                                    'ma_may_tinh': originalIncident['ma_may_tinh'],
                                    'loai_su_co': originalIncident['loai_su_co'],
                                    'muc_do': originalIncident['muc_do'],
                                    'trang_thai': newIncidentStatus, 
                                    'mo_ta': originalIncident['mo_ta']
                                  });
                                }
                              }
                              messenger.showSnackBar(const SnackBar(content: Text('Cập nhật phiếu và đồng bộ sự cố thành công!'), backgroundColor: Colors.green));
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx); 
                              _loadData();
                            }
                          } catch (e) {
                            messenger.showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
                          }
                        },
                        child: Text(ticketItem == null ? 'DUYỆT & TẠO PHIẾU' : 'CẬP NHẬT', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteItem(String endpoint, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'), content: const Text('Bạn có chắc chắn muốn xóa mục này khỏi hệ thống?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
    if (confirm == true) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ApiService.delete('$endpoint/$id');
        messenger.showSnackBar(const SnackBar(content: Text('Xóa thành công!'), backgroundColor: Colors.green));
        _loadData();
      } catch(e) {
        messenger.showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Quản lý Bảo trì',
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue.shade800, unselectedLabelColor: Colors.grey, indicatorColor: Colors.blue.shade800,
                tabs: const [
                  Tab(text: 'Sự cố', icon: Icon(Icons.warning_amber_rounded)),
                  Tab(text: 'Phiếu bảo trì', icon: Icon(Icons.build_circle_outlined)),
                  Tab(text: 'Nhật ký', icon: Icon(Icons.history_edu)),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildIncidentsTab(), 
                        _buildTicketsTab(),
                        // Truyền dữ liệu sang Tab Nhật ký để diệt lỗi Null
                        MaintenanceLogTab(logs: logs, tickets: tickets, reloadCallback: _loadData),
                      ]
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: BÁO CÁO SỰ CỐ ---
  Widget _buildIncidentsTab() {
    final filteredIncidents = incidents.where((inc) {
      if (_incidentStatusFilter == 'all') return true;
      return inc['trang_thai'] == _incidentStatusFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _incidentStatusFilter,
                icon: const Icon(Icons.filter_list, size: 20, color: Colors.grey),
                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                  DropdownMenuItem(value: 'open', child: Text('Đang mở')),
                  DropdownMenuItem(value: 'in_progress', child: Text('Đang sửa chữa')),
                  DropdownMenuItem(value: 'closed', child: Text('Đã khắc phục')),
                ],
                onChanged: (val) => setState(() => _incidentStatusFilter = val!),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: filteredIncidents.isEmpty
                ? Center(child: Text('Không có báo cáo sự cố nào.', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)))
                : ListView.builder(
                    itemCount: filteredIncidents.length,
                    itemBuilder: (ctx, i) {
                      final inc = filteredIncidents[i];
                      Color statusColor = inc['trang_thai'] == 'closed' ? Colors.green : (inc['trang_thai'] == 'in_progress' ? Colors.orange : Colors.red);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12), elevation: 1.5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('${inc['tieu_de']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(inc['trang_thai'].toString().toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(children: [Icon(Icons.computer, size: 16, color: Colors.blueGrey.shade400), const SizedBox(width: 8), Text('Máy: ${inc['ten_may'] ?? 'N/A'} - ${inc['ten_phong'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w500))]),
                              const SizedBox(height: 6),
                              Row(children: [Icon(Icons.person, size: 16, color: Colors.blueGrey.shade400), const SizedBox(width: 8), Text('Người báo: ${inc['nguoi_bao_cao'] ?? 'Ẩn danh'}')]),
                              const SizedBox(height: 6),
                              Row(children: [Icon(Icons.warning, size: 16, color: inc['muc_do'] == 'high' ? Colors.red : Colors.orange), const SizedBox(width: 8), Text('Mức độ: ${inc['muc_do']} | Loại: ${inc['loai_su_co']}')]),
                              
                              if (inc['trang_thai'] == 'open') ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _openTicketModal(incidentItem: inc),
                                      icon: const Icon(Icons.check_circle, size: 16),
                                      label: const Text('Duyệt'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _deleteItem('/bao-cao-su-co', inc['id']),
                                      icon: const Icon(Icons.delete, size: 16),
                                      label: const Text('Xóa'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: PHIẾU BẢO TRÌ ---
  Widget _buildTicketsTab() {
    final filteredTickets = tickets.where((tic) {
      if (_ticketStatusFilter == 'all') return true;
      return tic['trang_thai'] == _ticketStatusFilter;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10), color: Colors.white),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _ticketStatusFilter,
                    icon: const Icon(Icons.filter_list, size: 20, color: Colors.grey),
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                      DropdownMenuItem(value: 'pending', child: Text('Chưa xử lý')),
                      DropdownMenuItem(value: 'in_progress', child: Text('Đang tiến hành')),
                      DropdownMenuItem(value: 'completed', child: Text('Đã hoàn tất')),
                    ],
                    onChanged: (val) => setState(() => _ticketStatusFilter = val!),
                  ),
                ),
              ),
              if (!ResponsiveLayout.isMobile(context))
                ElevatedButton.icon(
                  onPressed: () => _openTicketModal(),
                  icon: const Icon(Icons.add), label: const Text('Tạo Phiếu bảo trì'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: filteredTickets.isEmpty
                ? Center(child: Text('Chưa có phiếu bảo trì nào.', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)))
                : ListView.builder(
                    itemCount: filteredTickets.length,
                    itemBuilder: (ctx, i) {
                      final tic = filteredTickets[i];
                      Color statusColor = tic['trang_thai'] == 'completed' ? Colors.green : (tic['trang_thai'] == 'in_progress' ? Colors.orange : Colors.grey);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12), elevation: 1.5, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('Phiếu #${tic['id']} - ${tic['loai_bao_tri']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(tic['trang_thai'].toString().toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.grey), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    onSelected: (value) {
                                      if (value == 'edit') { _openTicketModal(ticketItem: tic); }
                                      if (value == 'delete') { _deleteItem('/phieu-bao-tri', tic['id']); }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Sửa phiếu')])),
                                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Xóa', style: TextStyle(color: Colors.red))])),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text('Lỗi: ${tic['ten_su_co'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Row(children: [Icon(Icons.engineering, size: 16, color: Colors.blueGrey.shade400), const SizedBox(width: 8), Text('Phụ trách: ${tic['nguoi_phu_trach'] ?? 'Chưa phân công'}')]),
                              const SizedBox(height: 6),
                              Builder(
                                builder: (context) {
                                  final double chiPhi = double.tryParse(tic['chi_phi']?.toString() ?? '0') ?? 0.0;
                                  final String formattedChiPhi = NumberFormat.currency(locale: 'vi', symbol: '').format(chiPhi).trim();
                                  return Text('Chi phí: $formattedChiPhi VNĐ', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}