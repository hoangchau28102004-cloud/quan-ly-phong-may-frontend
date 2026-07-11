import 'package:flutter/material.dart';
import '../../data/datasources/api_service.dart'; 

class AdminAssignMachineDialog extends StatefulWidget {
  final int phieuId;
  final int requiredQuantity;

  const AdminAssignMachineDialog({
    super.key,
    required this.phieuId,
    required this.requiredQuantity,
  });

  @override
  State<AdminAssignMachineDialog> createState() => _AdminAssignMachineDialogState();
}

class _AdminAssignMachineDialogState extends State<AdminAssignMachineDialog> {
  List<dynamic> _availableMachines = [];
  final List<int> _selectedMachineIds = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchAvailableMachines();
  }

  Future<void> _fetchAvailableMachines() async {
    try {
      // Gọi API lấy danh sách máy rảnh
      final response = await ApiService.get('/borrow/available-machines');
      final decoded = ApiService.decodeBody(response);
      
      if (decoded != null && decoded['success'] == true) {
        if (mounted) {
          setState(() {
            _availableMachines = decoded['data'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception(decoded?['message'] ?? 'Lấy dữ liệu thất bại');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách máy: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _approveAndAssign() async {
    if (_selectedMachineIds.length != widget.requiredQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn đúng ${widget.requiredQuantity} máy để cấp phát!'), 
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      // Gọi API duyệt phiếu và cấp phát máy
      final response = await ApiService.post('/borrow/approve/${widget.phieuId}', {
        'machineIds': _selectedMachineIds,
      });
      final decoded = ApiService.decodeBody(response);
      
      if (decoded != null && decoded['success'] == true) {
        if (!mounted) return;
        Navigator.pop(context, true); // Đóng Dialog và trả về cờ "true"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã duyệt và cấp máy thành công!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception(decoded?['message'] ?? 'Lỗi hệ thống');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cấp phát thiết bị', style: TextStyle(color: Color(0xFF193D87), fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Yêu cầu: ${widget.requiredQuantity}', style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold)),
                Text('Đã chọn: ${_selectedMachineIds.length}', style: TextStyle(fontSize: 14, color: _selectedMachineIds.length == widget.requiredQuantity ? Colors.green : Colors.black87, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF193D87)))
            : _availableMachines.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Hiện không có máy tính nào rảnh trong kho!', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                    itemCount: _availableMachines.length,
                    itemBuilder: (context, index) {
                      final machine = _availableMachines[index];
                      final mId = machine['id'] as int;
                      final isSelected = _selectedMachineIds.contains(mId);

                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(machine['ten_may'] ?? 'Không tên', style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text('Mã: ${machine['ma_may']} - Kho: ${machine['ten_phong']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        value: isSelected,
                        activeColor: const Color(0xFF193D87),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              if (_selectedMachineIds.length < widget.requiredQuantity) {
                                _selectedMachineIds.add(mId);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã chọn đủ số lượng yêu cầu!'), duration: Duration(seconds: 1)),
                                );
                              }
                            } else {
                              _selectedMachineIds.remove(mId);
                            }
                          });
                        },
                      );
                    },
                  ),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF193D87),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: _isSubmitting ? null : _approveAndAssign,
          child: _isSubmitting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Xác nhận & Cấp máy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ],
    );
  }
}