import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/notification_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/layout/responsive_layout.dart';
import '../shared/notification_screen.dart'; // 🚀 IMPORT MÀN HÌNH THONG BAO

class AdminLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AdminLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  Timer? _notifPollTimer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<LoginViewModel>().currentUser?.id;
      if (userId != null) {
        context.read<NotificationViewModel>().loadNotifications(userId);
      }
    });
    // 🚀 LẮNG NGHE REALTIME (Dành cho Admin)
    // TODO: Nối Socket.io ở đây để nghe sự kiện từ Backend. Ví dụ:
    // socket.on('new_incident_reported', (data) {
    //   _showNotificationPopup('Sự cố mới', 'Sinh viên vừa báo lỗi ở phòng ${data.maPhong}');
    // });
    // socket.on('new_fast_booking_alert', (data) {
    //   _showNotificationPopup('Cảnh báo mượn gấp', 'GV ${data.tenGV} vừa mượn thẳng phòng ${data.maPhong}');
    // });

    // Temporary polling fallback: refresh notifications periodically so admin UI
    // sees newly created reports (replace with socket push for production).
    _notifPollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      final userId = context.read<LoginViewModel>().currentUser?.id;
      if (userId != null) {
        context.read<NotificationViewModel>().loadNotifications(userId);
      }
    });
  }

  @override
  void dispose() {
    _notifPollTimer?.cancel();
    super.dispose();
  }

  // 🚀 HÀM HIỂN THỊ POPUP TỪ TRÊN XUỐNG
  void _showNotificationPopup(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
        behavior: SnackBarBehavior.floating, // Nổi lên
        margin: EdgeInsets.only(
          top: 50,
          left: 16,
          right: 16,
          bottom:
              MediaQuery.of(context).size.height -
              150, // Ép nhảy lên sát mép trên
        ),
        backgroundColor: const Color(0xFF0F3E99),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Xem',
          textColor: Colors.white,
          onPressed: () {
            // Admin không xài Tab, nên push thẳng sang màn hình Thông Báo
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

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
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          elevation: 0,
          actions: widget.actions,
        ),
        drawer: Drawer(child: _buildSidebarContent(context, primary)),
        body: Container(
          color: const Color(0xFFF4F5F9),
          padding: const EdgeInsets.all(16.0),
          child: _applyTheme(context, widget.child),
        ),
      ),

      // ==========================================
      // 2. GIAO DIỆN DESKTOP
      // ==========================================
      desktop: Scaffold(
        body: Row(
          children: [
            SizedBox(width: 260, child: _buildSidebarContent(context, primary)),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopHeader(context),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF4F5F9),
                      padding: const EdgeInsets.all(20.0),
                      child: _applyTheme(context, widget.child),
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
                Image.asset(
                  'assets/img/logo.png',
                  width: 45,
                  height: 45,
                  errorBuilder: (c, e, s) =>
                      Icon(Icons.school, size: 40, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRƯỜNG CĐ KỸ THUẬT CAO THẮNG',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                      Text(
                        'IT Lab Room Management',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                _buildNavItem(
                  context,
                  Icons.person,
                  'Quản lý Tài khoản',
                  '/admin/users',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.book,
                  'Quản lý Học vụ',
                  '/admin/academic',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.desktop_windows,
                  'Quản lý Phòng máy',
                  '/admin/assets',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.receipt_long,
                  'Phiếu nhập máy',
                  '/admin/import-machine',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.swap_horiz,
                  'Điều chuyển máy',
                  '/admin/transfer',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.warning,
                  'Bảo trì & Sự cố',
                  '/admin/incidents',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.calendar_today,
                  'Quản lý Lịch',
                  '/admin/scheduling',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.devices,
                  'Quản lý mượn máy / Thiết bị',
                  '/admin/borrow',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.assignment_return,
                  'Quản lý trả máy / Thiết bị',
                  '/admin/return',
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  Icons.qr_code_scanner,
                  'Quét mã máy',
                  '/admin/scan-qr',
                  currentRoute,
                ),
              ],
            ),
          ),

          // 🚀 THÊM MỚI: Mục Thông báo dành riêng cho Admin trong Menu
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Consumer<NotificationViewModel>(
              builder: (context, viewModel, child) {
                final unreadCount = viewModel.unreadCount;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFF0F3E99),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: const Text(
                    'Thông báo',
                    style: TextStyle(
                      color: Color(0xFF0F3E99),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    if (ResponsiveLayout.isMobile(context)) {
                      Navigator.pop(context);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: InkWell(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String text,
    String route,
    String? currentRoute,
  ) {
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
          Text(
            widget.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (widget.actions != null) ...widget.actions!,
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Admin IT Lab',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
