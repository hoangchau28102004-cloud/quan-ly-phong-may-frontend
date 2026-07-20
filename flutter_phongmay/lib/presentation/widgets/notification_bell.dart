import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/shared/notification_screen.dart';
import '../providers/notification_viewmodel.dart';

class NotificationBell extends StatelessWidget {
  final int?
  unreadCount; // Số thông báo chưa đọc (nếu muốn dùng value override)

  const NotificationBell({super.key, this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final badgeCount =
        unreadCount ?? context.watch<NotificationViewModel>().unreadCount;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            size: 28,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
        ),
        if (badgeCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
