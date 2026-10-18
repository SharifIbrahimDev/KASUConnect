import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/mock_data_seed.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return AuthRepository(firestoreService: firestore);
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CurrentUserNotifier(repo);
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repo;
  StreamSubscription<UserModel?>? _sub;

  CurrentUserNotifier(this._repo) : super(_repo.currentUser) {
    _sub = _repo.userStream.listen((user) {
      state = user;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
  final FirestoreService? _firestoreService;

  // In-memory users store initialized with MockDataSeed
  final List<UserModel> _allUsers = List.from(MockDataSeed.users);

  // Default active user is Student Fatima Bello (student_1)
  UserModel? _currentUser;
  final ValueNotifier<UserModel?> _userNotifier = ValueNotifier<UserModel?>(null);
  final StreamController<UserModel?> _userStreamController = StreamController<UserModel?>.broadcast();

  AuthRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService {
    _currentUser = _allUsers.firstWhere((u) => u.id == 'student_1');
    _userNotifier.value = _currentUser;

    // Listen to Firebase Auth state changes
    if (Firebase.apps.isNotEmpty) {
      try {
        FirebaseAuth.instance.authStateChanges().listen((fbUser) async {
          if (fbUser != null) {
            final profile = await _firestoreService?.getUser(fbUser.uid);
            if (profile != null) {
              _currentUser = profile;
              final idx = _allUsers.indexWhere((u) => u.id == profile.id);
              if (idx != -1) {
                _allUsers[idx] = profile;
              } else {
                _allUsers.add(profile);
              }
              _notifyUser();
            }
          }
        });
      } catch (e) {
        debugPrint('FirebaseAuth listener notice: $e');
      }
    }
  }

  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get userStream => _userStreamController.stream;

  void _notifyUser() {
    _userNotifier.value = _currentUser;
    if (!_userStreamController.isClosed) {
      _userStreamController.add(_currentUser);
    }
  }

  List<UserModel> get allUsers => List.unmodifiable(_allUsers);

  Future<UserModel> signIn(String email, String password) async {
    // 1. Try signing in through Firebase Auth
    if (Firebase.apps.isNotEmpty) {
      try {
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final uid = cred.user?.uid;
        if (uid != null) {
          final remoteProfile = await _firestoreService?.getUser(uid);
          if (remoteProfile != null) {
            _currentUser = remoteProfile;
            final idx = _allUsers.indexWhere((u) => u.id == remoteProfile.id);
            if (idx != -1) {
              _allUsers[idx] = remoteProfile;
            } else {
              _allUsers.add(remoteProfile);
            }
            _notifyUser();
            return remoteProfile;
          }
        }
      } catch (e) {
        debugPrint('Firebase Auth sign in notice (fallback to demo accounts): $e');
      }
    }

    // 2. Fallback to demo account matching
    final match = _allUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      orElse: () {
        return UserModel(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          email: email.trim(),
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
    _notifyUser();
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
    String userId = 'student_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Create user in Firebase Auth
    if (Firebase.apps.isNotEmpty) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (cred.user != null) {
          userId = cred.user!.uid;
          await cred.user!.updateDisplayName(fullName);
        }
      } catch (e) {
        debugPrint('Firebase Auth registerStudent notice: $e');
      }
    }

    final newUser = UserModel(
      id: userId,
      email: email.trim(),
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
    _notifyUser();

    // 2. Sync to Cloud Firestore
    await _firestoreService?.syncUser(newUser);
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
    String userId = 'alumni_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Create user in Firebase Auth
    if (Firebase.apps.isNotEmpty) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        if (cred.user != null) {
          userId = cred.user!.uid;
          await cred.user!.updateDisplayName(fullName);
        }
      } catch (e) {
        debugPrint('Firebase Auth registerAlumni notice: $e');
      }
    }

    final newUser = UserModel(
      id: userId,
      email: email.trim(),
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
    _notifyUser();

    // 2. Sync to Cloud Firestore
    await _firestoreService?.syncUser(newUser);
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
    _notifyUser();
    return selected;
  }

  Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Firebase Auth signOut notice: $e');
      }
    }
    _currentUser = null;
    _notifyUser();
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
      _notifyUser();
    }
    _firestoreService?.syncUser(updated);
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
        _notifyUser();
      }
      _firestoreService?.syncUser(updated);
    }
  }

  void toggleBlockUser(String userId) {
    final idx = _allUsers.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      final user = _allUsers[idx];
      final updated = user.copyWith(isBlocked: !user.isBlocked);
      _allUsers[idx] = updated;
      _firestoreService?.syncUser(updated);
    }
  }
}
