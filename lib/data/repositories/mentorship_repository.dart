import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mentorship_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_seed.dart';
import 'auth_repository.dart';

final mentorshipRepositoryProvider = Provider<MentorshipRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return MentorshipRepository(authRepo);
});

final mentorshipListProvider = StateNotifierProvider<MentorshipNotifier, List<MentorshipModel>>((ref) {
  final repo = ref.watch(mentorshipRepositoryProvider);
  return MentorshipNotifier(repo);
});

class MentorshipNotifier extends StateNotifier<List<MentorshipModel>> {
  final MentorshipRepository _repo;
  StreamSubscription? _sub;

  MentorshipNotifier(this._repo) : super(_repo.allRequests) {
    _sub = _repo.stream.listen((requests) {
      state = requests;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void sendRequest({
    required UserModel student,
    required UserModel alumni,
    required String message,
    required String fieldOfInterest,
  }) {
    _repo.sendRequest(
      student: student,
      alumni: alumni,
      message: message,
      fieldOfInterest: fieldOfInterest,
    );
    state = _repo.allRequests;
  }

  void respondToRequest({
    required String requestId,
    required bool accept,
    String? responseNote,
  }) {
    _repo.respondToRequest(
      requestId: requestId,
      accept: accept,
      responseNote: responseNote,
    );
    state = _repo.allRequests;
  }
}

class MentorshipRepository {
  final AuthRepository _authRepo;
  final List<MentorshipModel> _requests = List.from(MockDataSeed.mentorshipRequests);
  final ValueNotifier<List<MentorshipModel>> _notifier = ValueNotifier([]);

  final StreamController<List<MentorshipModel>> _streamController = StreamController<List<MentorshipModel>>.broadcast();

  MentorshipRepository(this._authRepo) {
    _notifier.value = List.unmodifiable(_requests);
  }

  Stream<List<MentorshipModel>> get stream => _streamController.stream;

  void _notify() {
    final list = List<MentorshipModel>.unmodifiable(_requests);
    _notifier.value = list;
    if (!_streamController.isClosed) {
      _streamController.add(list);
    }
  }

  List<MentorshipModel> get allRequests => List.unmodifiable(_requests);

  List<UserModel> getAvailableMentors({String? department, String? search}) {
    var mentors = _authRepo.allUsers.where((u) {
      return u.isAlumni && u.isVerified && (u.isAvailableForMentorship || u.isMentor);
    }).toList();

    if (department != null && department.isNotEmpty && department != 'All Departments') {
      mentors = mentors.where((m) => m.department == department).toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      mentors = mentors.where((m) {
        return m.fullName.toLowerCase().contains(q) ||
            (m.jobTitle?.toLowerCase().contains(q) ?? false) ||
            (m.currentCompany?.toLowerCase().contains(q) ?? false) ||
            m.skills.any((s) => s.toLowerCase().contains(q));
      }).toList();
    }

    return List.unmodifiable(mentors);
  }

  List<MentorshipModel> getRequestsForStudent(String studentId) {
    return _requests.where((r) => r.studentId == studentId).toList();
  }

  List<MentorshipModel> getRequestsForAlumni(String alumniId) {
    return _requests.where((r) => r.alumniId == alumniId).toList();
  }

  MentorshipModel sendRequest({
    required UserModel student,
    required UserModel alumni,
    required String message,
    required String fieldOfInterest,
  }) {
    final req = MentorshipModel(
      id: 'ment_${DateTime.now().millisecondsSinceEpoch}',
      studentId: student.id,
      studentName: student.fullName,
      studentDepartment: student.department,
      studentLevel: student.level,
      studentAvatar: student.avatarUrl,
      alumniId: alumni.id,
      alumniName: alumni.fullName,
      alumniJobTitle: alumni.jobTitle,
      alumniCompany: alumni.currentCompany,
      alumniAvatar: alumni.avatarUrl,
      message: message,
      fieldOfInterest: fieldOfInterest,
      status: MentorshipStatus.pending,
      createdAt: DateTime.now(),
    );

    _requests.insert(0, req);
    _notify();
    return req;
  }

  void respondToRequest({
    required String requestId,
    required bool accept,
    String? responseNote,
  }) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(
        status: accept ? MentorshipStatus.accepted : MentorshipStatus.declined,
        alumniResponseNote: responseNote,
        updatedAt: DateTime.now(),
      );
      _notify();
    }
  }

  bool hasPendingOrActiveRequest(String studentId, String alumniId) {
    return _requests.any((r) =>
        r.studentId == studentId &&
        r.alumniId == alumniId &&
        (r.status == MentorshipStatus.pending || r.status == MentorshipStatus.accepted));
  }
}
