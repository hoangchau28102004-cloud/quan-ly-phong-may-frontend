import 'package:flutter/material.dart';
import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/data/models/user_model.dart';
import 'package:flutter_phongmay/data/datasources/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _token;
  bool isLoading = false;
  UserModel? currentUser;
  String? get token => _token;
  Future<String?> handleLogin(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }

    isLoading = true;
    notifyListeners();

    final result = await _authService.login(username, password);

    isLoading = false;
    if (result['success'] == true) {
      final token = result['token']?.toString();
      if (token != null && token.isNotEmpty) {
        _token = token;
        ApiService.token = token;
      } else {
        _token = null;
        ApiService.token = null;
      }
      currentUser = result['user'];
      notifyListeners();
      return null; // Trả về null nghĩa là thành công, không có lỗi
    } else {
      notifyListeners();
      return result['message']; // Trả về câu thông báo lỗi
    }
  }
}
