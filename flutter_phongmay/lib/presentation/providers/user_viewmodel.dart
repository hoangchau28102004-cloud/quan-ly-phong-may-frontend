import 'package:flutter/material.dart';
import 'package:flutter_phongmay/domain/entities/user_entity.dart';
import 'package:flutter_phongmay/domain/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository repository;

  List<UserEntity> users = [];
  List<Map<String, dynamic>> roles = [];
  bool loading = false;
  String error = '';

  UserViewModel({required this.repository});

  Future<void> fetchUsers() async {
    loading = true;
    error = '';
    notifyListeners();
    try {
      users = await repository.fetchUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoles() async {
    try {
      roles = await repository.fetchRoles();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleStatus(int userId, bool active) async {
    try {
      await repository.toggleUserStatus(userId, active);
      await fetchUsers();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> resetPassword(int userId) async {
    try {
      await repository.resetPassword(userId);
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<UserEntity?> createUser(UserEntity user, String password) async {
    try {
      final created = await repository.createUser(user, password);
      await fetchUsers();
      return created;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> updateUser(UserEntity user) async {
    try {
      await repository.updateUser(user);
      await fetchUsers();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await repository.deleteUser(userId);
      await fetchUsers();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
