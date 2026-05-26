import 'package:flutter_phongmay/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String taiKhoan, String matKhau);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getCurrentUser();
}
