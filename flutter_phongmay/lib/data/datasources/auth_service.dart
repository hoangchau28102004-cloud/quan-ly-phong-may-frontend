import 'dart:convert';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/data/models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Dùng trực tiếp ApiService.post thay vì khai báo http lằng nhằng
      final requestBody = {'email': username, 'mat_khau': password};

      // Debug: in ra request và response để kiểm tra lỗi kết nối/format
      // (xóa hoặc tắt in ra khi đã debug xong)
      // ignore: avoid_print
      print('AuthService.login -> Request: $requestBody');

      final response = await ApiService.post('/login', requestBody);

      // ignore: avoid_print
      print('AuthService.login -> Status: ${response.statusCode}');
      // ignore: avoid_print
      print('AuthService.login -> Body: ${response.body}');

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Normalize backend response keys so the frontend model parsing
        // doesn't crash if the server returns different field names.
        final raw = data['data'] as Map<String, dynamic>? ?? {};
        final userJson = Map<String, dynamic>.from(raw);

        // Ensure `tai_khoan` exists (some backends return `email` instead)
        if ((userJson['tai_khoan'] == null ||
                userJson['tai_khoan'].toString().isEmpty) &&
            userJson['email'] != null) {
          userJson['tai_khoan'] = userJson['email'];
        }

        // Accept `ma_vai_tro` as an alias for `vai_tro_id`
        if (userJson['vai_tro_id'] == null && userJson['ma_vai_tro'] != null) {
          userJson['vai_tro_id'] = userJson['ma_vai_tro'];
        }

        final token = data['token']?.toString();
        if (token != null && token.isNotEmpty) {
          ApiService.token = token;
        }

        // Debug: show normalized user payload
        // ignore: avoid_print
        print('AuthService.login -> Normalized user JSON: $userJson');

        return {
          'success': true,
          'user': UserModel.fromJson(userJson),
          'token': token,
        };
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Đăng nhập thất bại',
      };
    } catch (e) {
      // ignore: avoid_print
      print('AuthService.login -> Exception: $e');
      return {
        'success': false,
        'message': 'Không thể kết nối đến server. Kiểm tra lại mạng.',
      };
    }
  }
}
