import 'package:flutter/material.dart';
import 'package:flutter_phongmay/presentation/screens/layout/responsive_layout.dart';

class AdminLayout extends StatelessWidget {
  final String title;
  final Widget child;

  const AdminLayout({Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return ResponsiveLayout(
      // ==========================================
      // 1. GIAO DIỆN MOBILE
      // ==========================================
      mobile: Scaffold(
        appBar: AppBar(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation: 0,
        ),
        // Chuyển toàn bộ Sidebar thành Drawer trượt từ mép trái
        drawer: Drawer(
          child: _buildSidebarContent(context, primary),
        ),
        body: Container(
          color: const Color(0xFFF4F5F9),
          padding: const EdgeInsets.all(16.0),
          child: _applyTheme(context, child),
        ),
      ),

      // ==========================================
      // 2. GIAO DIỆN DESKTOP
      // ==========================================
      desktop: Scaffold(
        body: Row(
          children: [
            // Cố định Sidebar bên trái
            SizedBox(
              width: 260,
              child: _buildSidebarContent(context, primary),
            ),
            // Phần content co giãn bên phải
            Expanded(
              child: Column(
                children: [
                  _buildDesktopHeader(context),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF4F5F9),
                      padding: const EdgeInsets.all(20.0),
                      child: _applyTheme(context, child),
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

  // --- Các hàm phụ trợ (Đã tách nhỏ để dễ tái sử dụng) ---

  // Bọc Theme để ghi đè style của ElevatedButton
  Widget _applyTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ),
      child: child,
    );
  }

  // Khối Sidebar (Dùng chung cho cả Drawer trên Mobile và cố định trên Desktop)
  Widget _buildSidebarContent(BuildContext context, Color primary) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần Logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Image.asset(
                      'assets/img/logo.png',
                      width: 36,
                      height: 36,
                      // Phòng hờ nếu chưa có ảnh thì hiện Icon thay thế không bị lỗi đỏ màn hình
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(Icons.computer, size: 36, color: primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'IT Lab',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Danh sách Menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                children: [
                  _buildNavItem(context, Icons.person, 'Quản lý Tài khoản', route: '/admin/users'),
                  _buildNavItem(context, Icons.book, 'Quản lý Học vụ', route: '/admin/academic'),
                  _buildNavItem(context, Icons.desktop_windows, 'Quản lý Phòng máy', route: '/admin/assets'),
                  
                  // ĐÃ THÊM: Tính năng "Phiếu nhập máy" được lôi ra ngoài
                  _buildNavItem(context, Icons.receipt_long, 'Phiếu nhập máy', route: '/admin/import-machine'),
                  
                  _buildNavItem(context, Icons.warning, 'Bảo trì & Sự cố', route: '/admin/incidents'),
                  _buildNavItem(context, Icons.calendar_today, 'Quản lý Lịch', route: '/admin/scheduling'),
                ],
              ),
            ),
            // Nút Đăng xuất
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header thông tin phụ (Chỉ hiển thị trên Desktop)
  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      height: 76,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Admin IT Lab', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('4/6/2026', style: TextStyle(color: Colors.black54)), // TODO: Có thể đổi thành DateTime.now() sau
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Item cho Menu (Giữ nguyên của bạn)
  Widget _buildNavItem(BuildContext context, IconData icon, String text, {String? route}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () {
          if (route != null) {
            // Nếu đang ở mobile, chọn xong menu thì đóng Drawer lại
            if (ResponsiveLayout.isMobile(context)) {
               Navigator.pop(context); 
            }
            Navigator.pushNamed(context, route);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}