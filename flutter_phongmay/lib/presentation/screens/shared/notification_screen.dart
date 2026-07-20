import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../presentation/providers/notification_viewmodel.dart';
import '../../../presentation/providers/login_viewmodel.dart';
import '../../../data/models/notification_model.dart';
import '../../../presentation/screens/admin/incident_maintenance_management.dart'; 
import '../../../presentation/screens/admin/scheduling_management.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Avoid calling notifyListeners during build — schedule after frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final loginVm = context.read<LoginViewModel>();
        final userId = loginVm.currentUser?.id;
        if (userId != null) {
          debugPrint('NotificationScreen: loadNotifications userId=$userId');
          context.read<NotificationViewModel>().loadNotifications(userId);
        } else {
          debugPrint(
            'NotificationScreen: currentUser.id is null, notifications not loaded',
          );
        }
      });
      _initialized = true;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'system':
        return Icons.build_circle;
      case 'booking':
        return Icons.event_available;
      case 'incident_update':
      case 'incident':
        return Icons.report_problem;
      case 'booking_request':
        return Icons.event_note;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          'Thông báo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F3E99),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage.isNotEmpty) {
            return Center(
              child: Text('Có lỗi xảy ra: ${viewModel.errorMessage}'),
            );
          }

          if (viewModel.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: viewModel.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = viewModel.notifications[index];
              final isUnread = !notif.isRead;
              return _buildNotificationCard(notif, isUnread);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn chưa có thông báo nào.',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notif, bool isUnread) {
    return InkWell(
      onTap: () async {
        // 1. Lấy thông tin user hiện tại
        final user = context.read<LoginViewModel>().currentUser;
        if (user == null) return;

        // 2. Đánh dấu đã đọc nếu thông báo chưa đọc
        if (!notif.isRead) {
          await context.read<NotificationViewModel>().markAsRead(notif.id, user.id);
        }

        // 3. Nếu là Admin thì thực hiện dịch chuyển
        // Lưu ý: Mình đang giả định vaiTroId của Admin là 1.
        // Nếu database của bạn lưu Admin là ID khác (ví dụ 2 hoặc 3), hãy sửa số 1 thành số đó nhé.
        if (user.vaiTroId == 1) { 
          switch (notif.type) { 
            case 'incident':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const IncidentMaintenanceManagementScreen(), 
                ),
              );
              break;
            case 'booking':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SchedulingManagementScreen(), 
                ),
              );
              break;
          }
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? Colors.blue.shade200 : Colors.grey.shade200,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isUnread
                  ? const Color(0xFF0F3E99)
                  : Colors.grey.shade300,
              child: Icon(
                _getIconForType(notif.type),
                color: isUnread ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                      color: isUnread ? Colors.black87 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(notif.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}