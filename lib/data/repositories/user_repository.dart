import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return UserRepository(authRepo);
});

class UserRepository {
  final AuthRepository _authRepo;

  UserRepository(this._authRepo);

  List<UserModel> getAllUsers() => _authRepo.allUsers;

  UserModel? getUserById(String id) {
    try {
      return _authRepo.allUsers.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Advanced peer and skill search:
  /// e.g. "I need a graphic designer in Computer Science 400L"
  List<UserModel> searchUsers({
    String? keyword,
    String? department,
    String? level,
    UserRole? role,
    bool? onlyVerified,
  }) {
    var list = _authRepo.allUsers.where((u) => !u.isBlocked).toList();

    if (role != null) {
      list = list.where((u) => u.role == role).toList();
    }

    if (department != null && department.isNotEmpty && department != 'All Departments') {
      list = list.where((u) => u.department.toLowerCase() == department.toLowerCase()).toList();
    }

    if (level != null && level.isNotEmpty && level != 'All Levels') {
      list = list.where((u) => u.level == level).toList();
    }

    if (onlyVerified == true) {
      list = list.where((u) => u.isVerified).toList();
    }

    if (keyword != null && keyword.trim().isNotEmpty) {
      final q = keyword.toLowerCase().trim();
      list = list.where((u) {
        final matchesName = u.fullName.toLowerCase().contains(q);
        final matchesDept = u.department.toLowerCase().contains(q);
        final matchesBio = u.bio?.toLowerCase().contains(q) ?? false;
        final matchesCompany = u.currentCompany?.toLowerCase().contains(q) ?? false;
        final matchesTitle = u.jobTitle?.toLowerCase().contains(q) ?? false;
        final matchesSkill = u.skills.any((s) => s.toLowerCase().contains(q));
        final matchesLevel = u.level?.toLowerCase().contains(q) ?? false;
        return matchesName || matchesDept || matchesBio || matchesCompany || matchesTitle || matchesSkill || matchesLevel;
      }).toList();
    }

    return list;
  }

  void updateUserProfile(UserModel updatedUser) {
    _authRepo.updateUserLocally(updatedUser);
  }
}
