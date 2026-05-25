import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  UserModel? currentUser;

  Future<String?> handleLogin(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return "Vui lòng nhập đầy đủ thông tin";
    }

    isLoading = true;
    notifyListeners();

    final result = await _authService.login(username, password);

    isLoading = false;
    if (result['success'] == true) {
      currentUser = result['user'];
      notifyListeners();
      return null; // Trả về null nghĩa là thành công, không có lỗi
    } else {
      notifyListeners();
      return result['message']; // Trả về câu thông báo lỗi
    }
  }
}
