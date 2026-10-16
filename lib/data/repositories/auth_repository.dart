import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/mock_data_seed.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CurrentUserNotifier(repo);
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repo;

  CurrentUserNotifier(this._repo) : super(_repo.currentUser) {
    _repo.userStream.listen((user) {
      state = user;
    });
  }

  Future<void> signIn(String email, String password) async {
    final user = await _repo.signIn(email, password);
    state = user;
  }

  Future<void> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String matricNumber,
    required String faculty,
    required String department,
    required String level,
    required List<String> skills,
    String? bio,
  }) async {
    final user = await _repo.registerStudent(
      fullName: fullName,
      email: email,
      password: password,
      matricNumber: matricNumber,
      faculty: faculty,
      department: department,
      level: level,
      skills: skills,
      bio: bio,
    );
    state = user;
  }

  Future<void> registerAlumni({
    required String fullName,
    required String email,
    required String password,
    required String alumniId,
    required String graduationYear,
    required String faculty,
    required String department,
    required String currentCompany,
    required String jobTitle,
    required List<String> skills,
    required bool isMentor,
    String? mentorBio,
    String? bio,
  }) async {
    final user = await _repo.registerAlumni(
      fullName: fullName,
      email: email,
      password: password,
      alumniId: alumniId,
      graduationYear: graduationYear,
      faculty: faculty,
      department: department,
      currentCompany: currentCompany,
      jobTitle: jobTitle,
      skills: skills,
      isMentor: isMentor,
      mentorBio: mentorBio,
      bio: bio,
    );
    state = user;
  }

  Future<void> switchDemoRole(UserRole role) async {
    final user = await _repo.switchDemoRole(role);
    state = user;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = null;
  }

  void updateProfile(UserModel updatedUser) {
    _repo.updateUserLocally(updatedUser);
    state = updatedUser;
  }
}

class AuthRepository {
  // In-memory users store initialized with MockDataSeed
  final List<UserModel> _allUsers = List.from(MockDataSeed.users);

  // Default active user is Student Fatima Bello (student_1)
  UserModel? _currentUser;
  final ValueNotifier<UserModel?> _userNotifier = ValueNotifier<UserModel?>(null);

  AuthRepository() {
    _currentUser = _allUsers.firstWhere((u) => u.id == 'student_1');
    _userNotifier.value = _currentUser;
  }

  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get userStream => Stream.periodic(
        const Duration(milliseconds: 300),
        (_) => _currentUser,
      ).distinct();

  List<UserModel> get allUsers => List.unmodifiable(_allUsers);

  Future<UserModel> signIn(String email, String password) async {
    // Check if user exists in mock seed
    final match = _allUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () {
        // Fallback demo user if typed
        return UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          fullName: email.split('@').first.replaceAll('.', ' ').toUpperCase(),
          role: email.contains('alumni')
              ? UserRole.alumni
              : email.contains('admin')
                  ? UserRole.admin
                  : UserRole.student,
          faculty: 'Faculty of Science',
          department: 'Computer Science',
          level: '300L',
          skills: ['Coding', 'Communication'],
          verificationStatus: VerificationStatus.verified,
          createdAt: DateTime.now(),
        );
      },
    );

    if (!_allUsers.any((u) => u.id == match.id)) {
      _allUsers.add(match);
    }

    _currentUser = match;
    _userNotifier.value = match;
    return match;
  }

  Future<UserModel> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String matricNumber,
    required String faculty,
    required String department,
    required String level,
    required List<String> skills,
    String? bio,
  }) async {
    final newUser = UserModel(
      id: 'student_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      role: UserRole.student,
      matricNumber: matricNumber,
      faculty: faculty,
      department: department,
      level: level,
      skills: skills,
      bio: bio ?? 'KASU Student in $department',
      verificationStatus: VerificationStatus.pending, // Pending admin approval
      createdAt: DateTime.now(),
    );

    _allUsers.add(newUser);
    _currentUser = newUser;
    _userNotifier.value = newUser;
    return newUser;
  }

  Future<UserModel> registerAlumni({
    required String fullName,
    required String email,
    required String password,
    required String alumniId,
    required String graduationYear,
    required String faculty,
    required String department,
    required String currentCompany,
    required String jobTitle,
    required List<String> skills,
    required bool isMentor,
    String? mentorBio,
    String? bio,
  }) async {
    final newUser = UserModel(
      id: 'alumni_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      role: UserRole.alumni,
      alumniId: alumniId,
      graduationYear: graduationYear,
      faculty: faculty,
      department: department,
      currentCompany: currentCompany,
      jobTitle: jobTitle,
      skills: skills,
      isMentor: isMentor,
      mentorBio: mentorBio,
      isAvailableForMentorship: isMentor,
      bio: bio ?? 'KASU Alumni ($graduationYear) • $jobTitle at $currentCompany',
      verificationStatus: VerificationStatus.pending, // Pending admin approval
      createdAt: DateTime.now(),
    );

    _allUsers.add(newUser);
    _currentUser = newUser;
    _userNotifier.value = newUser;
    return newUser;
  }

  Future<UserModel> switchDemoRole(UserRole role) async {
    UserModel selected;
    switch (role) {
      case UserRole.student:
        selected = _allUsers.firstWhere((u) => u.id == 'student_1');
        break;
      case UserRole.alumni:
        selected = _allUsers.firstWhere((u) => u.id == 'alumni_1');
        break;
      case UserRole.admin:
        selected = _allUsers.firstWhere((u) => u.id == 'admin_1');
        break;
    }
    _currentUser = selected;
    _userNotifier.value = selected;
    return selected;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userNotifier.value = null;
  }

  void updateUserLocally(UserModel updated) {
    final idx = _allUsers.indexWhere((u) => u.id == updated.id);
    if (idx != -1) {
      _allUsers[idx] = updated;
    } else {
      _allUsers.add(updated);
    }
    if (_currentUser?.id == updated.id) {
      _currentUser = updated;
      _userNotifier.value = updated;
    }
  }

  void verifyUser(String userId, bool approve) {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final user = _allUsers[idx];
      final updated = user.copyWith(
        verificationStatus: approve ? VerificationStatus.verified : VerificationStatus.rejected,
      );
      _allUsers[idx] = updated;
      if (_currentUser?.id == userId) {
        _currentUser = updated;
        _userNotifier.value = updated;
      }
    }
  }

  void toggleBlockUser(String userId) {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final user = _allUsers[idx];
      _allUsers[idx] = user.copyWith(isBlocked: !user.isBlocked);
    }
  }
}
