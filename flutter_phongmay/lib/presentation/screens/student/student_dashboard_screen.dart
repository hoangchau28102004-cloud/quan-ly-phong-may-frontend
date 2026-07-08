import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_dashboard_viewmodel.dart';
import '../../providers/login_viewmodel.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Bóc token và userId từ lúc sinh viên đăng nhập
      final loginVm = context.read<LoginViewModel>();
      final userId = loginVm.currentUser?.id;
      final token = loginVm.token ?? '';

      if (userId != null) {
        // Truyền thẳng vào hàm
        context.read<StudentDashboardViewModel>().loadAll(userId, token); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentDashboardViewModel>();
    
    // Lấy thông tin User từ LoginViewModel
    final loginVm = context.watch<LoginViewModel>();
    final userName = loginVm.currentUser?.hoTen ?? 'Sinh viên';
    final userEmail = loginVm.currentUser?.email ?? 'sv@caothang.edu.vn';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // KHÔNG CÓ NÚT QUÉT QR HAY BỘ LỌC THỨ Ở MÀN HÌNH TỔNG QUAN NÀY
      body: vm.loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)))
          : Column(
              children: [
                // 1. Header bo góc Avatar hình vuông
                _buildHeader(userName, userEmail),
                
                // 2. Phần nội dung cuộn được ở dưới
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatisticsGrid(vm),
                        const SizedBox(height: 24),
                        
                        _buildSectionTitle('Buổi học sắp tới'),
                        _buildUpcomingList(vm.upcoming),
                        
                        const SizedBox(height: 24),
                        
                        _buildSectionTitle('Điểm danh gần đây'),
                        _buildRecentAttendance(vm.recentAttendance),
                        
                        const SizedBox(height: 24), 
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ==========================================
  // WIDGET COMPONENTS
  // ==========================================

  Widget _buildHeader(String name, String email) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A), // Màu xanh Cao Thắng
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar hình vuông bo góc giống Giảng viên
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF1E3A8A),
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin Tên & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Ôm sát nội dung
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(StudentDashboardViewModel vm) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _statCard('Lớp học phần', vm.coursesCount.toString(), Icons.book_outlined, Colors.blue),
        _statCard('Buổi sắp tới', vm.upcoming.length.toString(), Icons.schedule_outlined, Colors.orange),
        _statCard('Điểm danh', vm.recentAttendance.length.toString(), Icons.check_circle_outline, Colors.green),
        _statCard('Sự cố mở', vm.recentIncidents.length.toString(), Icons.warning_amber_rounded, Colors.red),
      ],
    );
  }

  Widget _statCard(String title, String count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildUpcomingList(List<dynamic> upcomingList) {
    if (upcomingList.isEmpty) return _emptyState('Không có lịch học sắp tới.');
    return Column(
      children: upcomingList.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.timer_outlined, color: Colors.orange.shade700),
            ),
            title: Text(item['ten_mon'] ?? 'Chưa rõ', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Thời gian: ${item['thoi_gian']} | Phòng: ${item['phong']}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentAttendance(List<dynamic> recentList) {
    if (recentList.isEmpty) return _emptyState('Chưa có bản ghi điểm danh.');
    return Column(
      children: recentList.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.qr_code_scanner, color: Colors.green),
            ),
            title: Text(item['ten_mon'] ?? 'Chưa rõ', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Trạng thái: ${item['trang_thai']} - ${item['thoi_gian']}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(message, style: TextStyle(color: Colors.grey.shade500), textAlign: TextAlign.center),
    );
  }
}