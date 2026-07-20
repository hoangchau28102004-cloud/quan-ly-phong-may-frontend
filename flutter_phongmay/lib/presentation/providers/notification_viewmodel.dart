import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> notifications = [];
  bool isLoading = false;
  String errorMessage = '';

  int get unreadCount => notifications.where((item) => !item.isRead).length;

  Future<void> loadNotifications(int userId) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      notifications = await _repository.fetchNotifications(userId);
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId, int userId) async {
    final updated = await _repository.markAsRead(notificationId, userId);
    if (!updated) {
      return;
    }

    final index = notifications.indexWhere(
      (element) => element.id == notificationId,
    );
    if (index >= 0) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
}
