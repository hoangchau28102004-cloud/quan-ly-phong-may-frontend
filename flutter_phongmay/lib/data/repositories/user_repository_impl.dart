import 'package:flutter_phongmay/data/datasources/api_service.dart';
import 'package:flutter_phongmay/data/models/user_model.dart';
import 'package:flutter_phongmay/domain/entities/user_entity.dart';
import 'package:flutter_phongmay/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl();

  // ĐÃ XÓA HÀM _hashPassword gây lỗi mã hóa kép ở đây

  @override
  Future<UserEntity> createUser(UserEntity user, String password) async {
    final body = {
      'ho_ten': user.hoTen,
      'email': user.email,
      'so_dien_thoai': user.soDienThoai,
      'ma_vai_tro': user.vaiTroId,
      'lop_hoc_id': user.lopHocId,
      'gioi_tinh': user.gioiTinh,
      'ngay_sinh': user.ngaySinh,
      // Gửi thẳng mật khẩu lên, Backend Node.js sẽ lo phần mã hóa Bcrypt
      'mat_khau': password,
    };

    final resp = await ApiService.post('/users', body);
    final decoded = ApiService.decodeBody(resp);

    if ((resp.statusCode == 200 || resp.statusCode == 201) &&
        decoded != null &&
        decoded['success'] == true) {
      final id = decoded['id'];
      if (id != null) {
        final all = await fetchUsers();
        final created = all.firstWhere(
          (u) => u.id == id,
          orElse: () => throw Exception('Created user not found'),
        );
        return created;
      }
      throw Exception('User created but id not returned');
    }
    throw Exception(decoded?['message'] ?? 'Failed to create user');
  }

  @override
  Future<List<UserEntity>> fetchUsers() async {
    final resp = await ApiService.get('/users');
    final decoded = ApiService.decodeBody(resp);
    if (resp.statusCode == 200 &&
        decoded != null &&
        decoded['success'] == true) {
      final data = List<Map<String, dynamic>>.from(decoded['data'] ?? []);
      return data
          .map(
            (e) => UserModel.fromJson(Map<String, dynamic>.from(e)).toEntity(),
          )
          .toList();
    }
    throw Exception(decoded?['message'] ?? 'Failed to fetch users');
  }

  @override
  Future<void> resetPassword(int userId) async {
    // Gửi thẳng chuỗi '123'
    final temp = '123';
    final resp = await ApiService.put('/users/$userId/reset-password', {
      'mat_khau': temp, // Backend sẽ nhận '123' và mã hóa bằng Bcrypt
    });

    final decoded = ApiService.decodeBody(resp);
    if (resp.statusCode != 200 ||
        decoded == null ||
        decoded['success'] != true) {
      throw Exception(decoded?['message'] ?? 'Failed to reset password');
    }
  }

  @override
  Future<void> toggleUserStatus(int userId, bool active) async {
    final resp = await ApiService.put('/users/$userId/status', {
      'active': active,
    });
    final decoded = ApiService.decodeBody(resp);
    if (resp.statusCode != 200 ||
        decoded == null ||
        decoded['success'] != true) {
      throw Exception(decoded?['message'] ?? 'Failed to toggle user status');
    }
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final body = {
      'ho_ten': user.hoTen,
      'ma_vai_tro': user.vaiTroId,
      'so_dien_thoai': user.soDienThoai,
      'gioi_tinh': user.gioiTinh,
      'ngay_sinh': user.ngaySinh,
      'lop_hoc_id': user.lopHocId,
    };
    final resp = await ApiService.put('/users/${user.id}', body);
    final decoded = ApiService.decodeBody(resp);
    if (resp.statusCode != 200 ||
        decoded == null ||
        decoded['success'] != true) {
      throw Exception(decoded?['message'] ?? 'Failed to update user');
    }
  }

  @override
  Future<void> deleteUser(int userId) async {
    final resp = await ApiService.delete('/users/$userId');
    final decoded = ApiService.decodeBody(resp);
    if (resp.statusCode != 200 ||
        decoded == null ||
        decoded['success'] != true) {
      throw Exception(decoded?['message'] ?? 'Failed to delete user');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRoles() async {
    final resp = await ApiService.get('/roles');
    final decoded = ApiService.decodeBody(resp);
    if (resp.statusCode == 200 &&
        decoded != null &&
        decoded['success'] == true) {
      final data = List<Map<String, dynamic>>.from(decoded['data'] ?? []);
      return data;
    }
    throw Exception(decoded?['message'] ?? 'Failed to fetch roles');
  }
}
