import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/notification_viewmodel.dart';
import 'package:flutter_phongmay/presentation/screens/student/student_borrow_screen.dart';
import 'package:flutter_phongmay/presentation/screens/profile/profile_screen.dart';
import '../student/student_dashboard_screen.dart';
import '../shared/notification_screen.dart'; // 🚀 IMPORT MÀN HÌNH THONG BAO

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final Color primaryNavy = const Color(0xFF1D357A);

  final List<Widget> _screens = [
    const StudentDashboardScreen(),
    const StudentBorrowScreen(),
    const NotificationScreen(), // 🚀 Vị trí số 2 (Tab thứ 3)
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loginVm = context.read<LoginViewModel>();
      final userId = loginVm.currentUser?.id;
      if (userId != null) {
        context.read<NotificationViewModel>().loadNotifications(userId);
      }
    });

    // 🚀 LẮNG NGHE REALTIME (Dành cho Giảng Viên)
    // TODO: Nối Socket.io ở đây để nghe sự kiện từ Backend. Ví dụ:
    // socket.on('room_booking_approved', (data) {
    //   _showNotificationPopup('Duyệt mượn phòng', 'Yêu cầu mượn phòng ${data.maPhong} đã được duyệt');
    // });
    // socket.on('fast_booking_success', (data) {
    //   _showNotificationPopup('Mượn phòng khẩn cấp', 'Bạn đã mượn thành công phòng ${data.maPhong} không cần chờ duyệt');
    // });
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
        backgroundColor: primaryNavy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Xem',
          textColor: Colors.white,
          onPressed: () {
            // Chuyển hướng tới tab Thông báo
            setState(() => _currentIndex = 2);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationNavIcon(int unreadCount, bool active) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active ? Icons.notifications : Icons.notifications_none_outlined),
        if (unreadCount > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationViewModel>().unreadCount;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: primaryNavy,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Mượn thiết bị',
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationNavIcon(unreadCount, false),
            activeIcon: _buildNotificationNavIcon(unreadCount, true),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
