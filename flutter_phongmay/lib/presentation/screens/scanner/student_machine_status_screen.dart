import 'package:flutter/material.dart';
import '../student/student_report_incident_screen.dart';

class StudentMachineStatusScreen extends StatelessWidget {
  final String qrData;
  final Map<String, dynamic> machineData;
  final String schedulePurpose;

  const StudentMachineStatusScreen({
    super.key,
    required this.qrData,
    required this.machineData,
    required this.schedulePurpose,
  });

  final Color primaryNavy = const Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Nhận máy thực hành', style: TextStyle(fontSize: 18)),
        backgroundColor: primaryNavy,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildSuccessHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thiết bị bạn chuẩn bị sử dụng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMachineInfoCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Lưu ý từ phòng máy',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildWarningCard(),
                ],
              ),
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Điểm danh thành công!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mã thiết bị: $qrData',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool get _isUnavailable {
    final status = machineData['trang_thai']?.toString().toLowerCase() ?? '';
    return status.contains('hư') ||
        status.contains('bảo trì') ||
        status.contains('mượn');
  }

  String get _unavailableMessage {
    final status = machineData['trang_thai']?.toString().toLowerCase() ?? '';
    final purpose = schedulePurpose.isNotEmpty ? schedulePurpose : 'học/thi';

    if (status.contains('hư')) {
      return 'Máy này đang bị hư. Vui lòng sang máy khác để $purpose.';
    }
    if (status.contains('bảo trì')) {
      return 'Máy này đang trong trạng thái bảo trì. Vui lòng sang máy khác để $purpose.';
    }
    if (status.contains('mượn')) {
      return 'Máy này đang được mượn. Vui lòng sang máy khác để $purpose.';
    }
    return 'Máy này không thể sử dụng. Vui lòng sang máy khác để $purpose.';
  }

  Widget _buildMachineInfoCard() {
    String viTri = machineData['vi_tri']?.toString() ?? 'Chưa cập nhật';
    String tenMay = machineData['ten_may']?.toString() ?? 'Máy tính';
    String cpu = machineData['bo_xu_ly']?.toString() ?? 'Đang cập nhật';
    String ram = machineData['ram']?.toString() ?? 'Đang cập nhật';
    String monitor = machineData['man_hinh']?.toString() ?? 'Đang cập nhật';
    String boMachChu =
        machineData['bo_mach_chu']?.toString() ?? 'Đang cập nhật';
    String hdd = machineData['hdd']?.toString() ?? 'Đang cập nhật';
    String ssd = machineData['ssd']?.toString() ?? 'Đang cập nhật';
    String trangThai = machineData['trang_thai']?.toString() ?? 'Chưa cập nhật';
    String phuKien =
        '${machineData['ban_phim'] ?? ''} / ${machineData['chuot'] ?? ''}';
    if (phuKien == ' / ') phuKien = 'Đang cập nhật';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSpecRow(Icons.computer, 'Vị trí / Tên', '$viTri - $tenMay'),
            const Divider(height: 24),
            _buildSpecRow(Icons.memory, 'Bộ xử lý (CPU)', cpu),
            const Divider(height: 24),
            _buildSpecRow(Icons.storage, 'RAM', ram),
            const Divider(height: 24),
            _buildSpecRow(Icons.monitor, 'Màn hình', monitor),
            const Divider(height: 24),
            _buildSpecRow(
              Icons.settings_input_component,
              'Bo mạch chủ',
              boMachChu,
            ),
            const Divider(height: 24),
            _buildSpecRow(Icons.sd_storage, 'HDD', hdd),
            const Divider(height: 24),
            _buildSpecRow(Icons.storage_outlined, 'SSD', ssd),
            const Divider(height: 24),
            _buildSpecRow(Icons.info_outline, 'Trạng thái', trangThai),
            const Divider(height: 24),
            _buildSpecRow(Icons.mouse, 'Ngoại vi', phuKien),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
    return Card(
      elevation: 0,
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kiểm tra trước khi dùng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vui lòng kiểm tra kỹ tình trạng máy, chuột, bàn phím. Nếu phát hiện hư hỏng hoặc mất cắp, hãy ấn "Báo cáo sự cố" ngay lập tức để tránh chịu trách nhiệm đền bù.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade900,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Máy hoạt động tốt - Vào học',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  // 🚀 ĐÃ BỌC THÉP ÉP KIỂU INT AN TOÀN
                  final int safeMachineId =
                      int.tryParse(machineData['id']?.toString() ?? '') ?? 0;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentReportIncidentScreen(
                        machineId: safeMachineId,
                        machineName:
                            machineData['ten_may']?.toString() ?? 'Máy tính',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Báo cáo sự cố / Thiếu thiết bị',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
