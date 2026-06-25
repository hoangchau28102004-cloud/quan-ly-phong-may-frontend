import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/lecturer/booking_history_screen.dart';

const Color kAppBlue = Color(0xFF193D87);

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  void _handleLogout(BuildContext context) {
    // Xóa stack hiện tại và chuyển hẳn về trang Login
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<LoginViewModel>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      appBar: AppBar(
        backgroundColor: kAppBlue,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hồ sơ cá nhân',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Quản lý tài khoản và tùy chọn',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- THẺ THÔNG TIN CÁ NHÂN ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: kAppBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, size: 40, color: kAppBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.hoTen ?? 'Tên Giảng viên',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'teacher@caothang.edu.vn',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- DANH SÁCH MENU OPTION ---
            _buildMenuItem(
              icon: Icons.calendar_month_outlined,
              title: 'Lịch dạy của tôi',
              onTap: () =>
                  Navigator.pop(context), // Bấm vào sẽ lùi về trang Home
            ),
            _buildMenuItem(
              icon: Icons.receipt_long_outlined,
              title: 'Lịch sử mượn phòng',
              badges: [
                _buildBadge(
                  'Chờ duyệt',
                  '2',
                  Colors.orange,
                ), // Bạn có thể lấy số liệu thật từ API sau
                _buildBadge('Đã duyệt', '5', Colors.green),
              ],
              onTap: () {
                // SỬA Ở ĐÂY: Chuyển sang trang Lịch sử
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BookingHistoryScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.warning_amber_rounded,
              title: 'Báo cáo sự cố của tôi',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Cài đặt hệ thống',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // --- NÚT ĐĂNG XUẤT ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () => _handleLogout(context),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm Helper để vẽ từng nút bấm Menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    List<Widget>? badges,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: kAppBlue),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badges != null) ...badges,
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  // Hàm Helper để vẽ các Badge (Chờ duyệt, Đã duyệt)
  Widget _buildBadge(String label, String count, MaterialColor color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color.shade700)),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color.shade900,
            ),
          ),
        ],
      ),
    );
  }
}
