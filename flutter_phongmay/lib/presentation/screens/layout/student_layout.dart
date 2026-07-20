import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phongmay/presentation/providers/login_viewmodel.dart';
import 'package:flutter_phongmay/presentation/providers/notification_viewmodel.dart';
import '../student/student_dashboard_screen.dart';
import '../student/student_schedule_screen.dart';
import '../student/student_profile_screen.dart';
import '../shared/notification_screen.dart'; // 🚀 IMPORT MÀN HÌNH THONG BAO

class StudentLayout extends StatefulWidget {
  const StudentLayout({super.key});

  @override
  State<StudentLayout> createState() => _StudentLayoutState();
}

class _StudentLayoutState extends State<StudentLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentDashboardScreen(),
    const StudentScheduleScreen(),
    const NotificationScreen(), // 🚀 Vị trí số 2 (Tab thứ 3)
    const StudentProfileScreen(),
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

    // 🚀 LẮNG NGHE REALTIME (Dành cho Sinh Viên)
    // TODO: Nối Socket.io ở đây để nghe sự kiện từ Backend. Ví dụ:
    // socket.on('incident_approved', (data) {
    //   _showNotificationPopup('Báo cáo sự cố', 'Admin đã duyệt báo cáo sự cố máy ${data.maMay}');
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
        backgroundColor: const Color(0xFF1E3A8A),
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
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Tổng quan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Lịch học',
            ),
            // 🚀 THÊM MỚI TAB THÔNG BÁO
            BottomNavigationBarItem(
              icon: _buildNotificationNavIcon(unreadCount, false),
              activeIcon: _buildNotificationNavIcon(unreadCount, true),
              label: 'Thông báo',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}
