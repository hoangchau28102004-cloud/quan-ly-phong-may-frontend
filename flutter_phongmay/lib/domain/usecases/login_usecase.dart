import 'package:flutter_phongmay/domain/entities/user_entity.dart';
import 'package:flutter_phongmay/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase(this.authRepository);

  Future<UserEntity> call(String taiKhoan, String matKhau) async {
    if (taiKhoan.isEmpty || matKhau.isEmpty) {
      throw Exception('Tài khoản và mật khẩu không được để trống');
    }
    return await authRepository.login(taiKhoan, matKhau);
  }
}
