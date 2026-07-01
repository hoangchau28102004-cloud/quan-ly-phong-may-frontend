import 'package:flutter/material.dart';
import 'package:flutter_phongmay/presentation/screens/layout/responsive_layout.dart';

class AdminLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions; // THÊM DÒNG NÀY ĐỂ NHẬN ICON TỪ BÊN NGOÀI

  const AdminLayout({super.key, required this.title, required this.child, this.actions});

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
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          elevation: 0,
          actions: actions, // HIỂN THỊ ICON Ở MOBILE
        ),
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
            SizedBox(
              width: 260,
              child: _buildSidebarContent(context, primary),
            ),
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

  Widget _applyTheme(BuildContext context, Widget child) {
    return Theme(
      data: Theme.of(context).copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(foregroundColor: Colors.white),
        ),
      ),
      child: child,
    );
  }

  Widget _buildSidebarContent(BuildContext context, Color primary) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Image.asset('assets/img/logo.png', width: 45, height: 45, errorBuilder: (c, e, s) => Icon(Icons.school, size: 40, color: primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TRƯỜNG CĐ KỸ THUẬT CAO THẮNG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primary)),
                      Text('IT Lab Room Management', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: [
                _buildNavItem(context, Icons.person, 'Quản lý Tài khoản', '/admin/users', currentRoute),
                _buildNavItem(context, Icons.book, 'Quản lý Học vụ', '/admin/academic', currentRoute),
                _buildNavItem(context, Icons.desktop_windows, 'Quản lý Phòng máy', '/admin/assets', currentRoute),
                _buildNavItem(context, Icons.receipt_long, 'Phiếu nhập máy', '/admin/import-machine', currentRoute),
                _buildNavItem(context, Icons.swap_horiz, 'Điều chuyển máy', '/admin/transfer', currentRoute),
                _buildNavItem(context, Icons.warning, 'Bảo trì & Sự cố', '/admin/incidents', currentRoute),
                _buildNavItem(context, Icons.calendar_today, 'Quản lý Lịch', '/admin/scheduling', currentRoute),
                _buildNavItem(context, Icons.swap_horiz, 'Mượn & Trả máy', '/admin/borrow-return', currentRoute),
                _buildNavItem(context, Icons.qr_code_scanner, 'Quét mã máy', '/admin/scan-qr', currentRoute),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Đăng xuất', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String text, String route, String? currentRoute) {
    bool isSelected = (currentRoute == route);
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () {
          if (ResponsiveLayout.isMobile(context)) Navigator.pop(context);
          if (!isSelected) Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? primary : Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  color: isSelected ? primary : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      height: 76,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Row(
            children: [
              // HIỂN THỊ ICON Ở DESKTOP
              if (actions != null) ...actions!,
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Admin IT Lab', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('4/6/2026', style: TextStyle(color: Colors.black54)),
                ],
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
    );
  }
}