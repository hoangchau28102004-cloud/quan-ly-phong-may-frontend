import 'package:flutter/foundation.dart';
import '../datasources/api_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  Future<List<NotificationModel>> fetchNotifications(int userId) async {
    final endpoint = '/notifications?ma_nguoi_dung=$userId';
    final requestUrl = '${ApiService.baseUrl}$endpoint';
    debugPrint('Notifications GET -> $requestUrl');

    final response = await ApiService.get(endpoint);
    final decoded = ApiService.decodeBody(response);

    debugPrint(
      'Notifications GET status=${response.statusCode} body=${response.body}',
    );

    if (response.statusCode != 200) {
      final message =
          decoded?['message']?.toString() ?? 'Không thể tải thông báo';
      throw Exception(message);
    }

    final data = decoded?['data'] as List<dynamic>? ?? [];
    return data
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<bool> markAsRead(int notificationId, int userId) async {
    final endpoint = '/notifications/$notificationId/read';
    final requestUrl = '${ApiService.baseUrl}$endpoint';
    debugPrint(
      'Notifications PUT -> $requestUrl body={ma_nguoi_dung: $userId}',
    );

    final response = await ApiService.put(endpoint, {'ma_nguoi_dung': userId});
    final decoded = ApiService.decodeBody(response);

    debugPrint(
      'Notifications PUT status=${response.statusCode} body=${response.body}',
    );

    if (response.statusCode != 200) {
      return false;
    }

    return decoded?['success'] == true;
  }
}
