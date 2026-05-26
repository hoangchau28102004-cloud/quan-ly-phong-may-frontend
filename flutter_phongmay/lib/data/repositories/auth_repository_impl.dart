import 'package:flutter_phongmay/data/datasources/auth_service.dart';
import 'package:flutter_phongmay/domain/entities/user_entity.dart';
import 'package:flutter_phongmay/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl(this.authService);

  @override
  Future<UserEntity> login(String taiKhoan, String matKhau) async {
    final result = await authService.login(taiKhoan, matKhau);
    if (result['success'] == true) {
      final userModel = result['user'];
      return UserEntity(
        id: userModel.id,
        taiKhoan: userModel.taiKhoan,
        hoTen: userModel.hoTen,
        email: userModel.email,
        vaiTroId: userModel.vaiTroId,
        lopHocId: userModel.lopHocId,
      );
    }
    throw Exception(result['message'] ?? 'Đăng nhập thất bại');
  }

  @override
  Future<void> logout() async {
    // TODO: Implement logout
  }

  @override
  Future<bool> isLoggedIn() async {
    // TODO: Implement isLoggedIn
    return false;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // TODO: Implement getCurrentUser
    return null;
  }
}
