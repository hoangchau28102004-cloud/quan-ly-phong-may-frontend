import 'dart:convert';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/data/models/user_model.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Dùng trực tiếp ApiService.post thay vì khai báo http lằng nhằng
      final response = await ApiService.post('/login', {
        'tai_khoan': username, 
        'mat_khau': password
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'user': UserModel.fromJson(data['data'])};
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Đăng nhập thất bại',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Không thể kết nối đến server. Kiểm tra lại mạng.',
      };
    }
  }
}