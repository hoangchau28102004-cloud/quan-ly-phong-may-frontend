import 'package:flutter/material.dart';
import 'profile_history_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final Color primaryNavy = const Color(0xFF1D357A);
  final Color lightBg = const Color(0xFFF4F5F9);
  final Color borderColor = const Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: const Text(
          'Tài Khoản Người Dùng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryNavy,
        elevation: 0,
        automaticallyImplyLeading: false, 
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: primaryNavy,
            padding: const EdgeInsets.only(
              bottom: 30.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                  ),
                  child: Center(
                    child: Text(
                      'C',
                      style: TextStyle(
                        fontSize: 32,
                        color: primaryNavy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Châu Lâm Vũ Hoàng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'MSSV: 0306231094',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Khoa: Công Nghệ Thông Tin',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    Icons.history_toggle_off,
                    'Lịch sử hoạt động (Mượn thiết bị / Sự cố)',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.lock_open_outlined,
                    'Thay đổi mật khẩu',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline,
                    'Trợ giúp & Hỗ trợ',
                  ),
                  _buildMenuItem(
                    context,
                    Icons.info_outline,
                    'Thông tin phiên bản app',
                  ),
                ],
              ),
            ),
          ),

          Padding(
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
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'ĐĂNG XUẤT TÀI KHOẢN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.zero, 
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 4.0,
        ),
        leading: Icon(icon, color: primaryNavy),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            fontSize: 14,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        onTap: onTap ?? () {},
      ),
    );
  }
}