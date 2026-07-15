import 'package:flutter_phongmay/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> fetchUsers();
  Future<UserEntity> createUser(UserEntity user, String password);
  Future<void> deleteUser(int userId);
  Future<void> updateUser(UserEntity user);
  Future<void> toggleUserStatus(int userId, bool active);
  Future<void> resetPassword(int userId);
  Future<List<Map<String, dynamic>>> fetchRoles();
}
