import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/job_model.dart';
import '../models/report_model.dart';
import '../services/mock_data_seed.dart';
import 'auth_repository.dart';
import 'job_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final jobRepo = ref.watch(jobRepositoryProvider);
  return AdminRepository(authRepo, jobRepo);
});

class AdminRepository {
  final AuthRepository _authRepo;
  final JobRepository _jobRepo;

  final List<ReportModel> _reports = List.from(MockDataSeed.reports);
  final ValueNotifier<List<ReportModel>> _reportsNotifier = ValueNotifier([]);

  AdminRepository(this._authRepo, this._jobRepo) {
    _reportsNotifier.value = List.unmodifiable(_reports);
  }

  Stream<List<ReportModel>> get reportsStream => Stream.periodic(
        const Duration(milliseconds: 500),
        (_) => List<ReportModel>.unmodifiable(_reports),
      ).distinct();

  List<ReportModel> get reports => List.unmodifiable(_reports);

  // Verification Queue
  List<UserModel> getPendingVerificationUsers() {
    return _authRepo.allUsers
        .where((u) => u.verificationStatus == VerificationStatus.pending)
        .toList();
  }

  void approveUserVerification(String userId) {
    _authRepo.verifyUser(userId, true);
  }

  void rejectUserVerification(String userId) {
    _authRepo.verifyUser(userId, false);
  }

  // Job Moderation (Scam Protection)
  List<JobModel> getPendingJobs() {
    return _jobRepo.getPendingJobs();
  }

  void approveJob(String jobId) {
    _jobRepo.approveJob(jobId);
  }

  void rejectJob(String jobId) {
    _jobRepo.rejectJob(jobId);
  }

  // User Moderation
  List<UserModel> getAllUsers() {
    return _authRepo.allUsers;
  }

  void toggleBlockUser(String userId) {
    _authRepo.toggleBlockUser(userId);
  }

  // Reporting System
  void submitReport({
    required UserModel reporter,
    required String targetType,
    required String targetId,
    required String targetTitle,
    required String reason,
    String? details,
  }) {
    final rep = ReportModel(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      reporterId: reporter.id,
      reporterName: reporter.fullName,
      targetType: targetType,
      targetId: targetId,
      targetTitle: targetTitle,
      reason: reason,
      details: details,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _reports.insert(0, rep);
    _reportsNotifier.value = List.unmodifiable(_reports);
  }

  void resolveReport(String reportId, String status) {
    final idx = _reports.indexWhere((r) => r.id == reportId);
    if (idx != -1) {
      _reports[idx] = _reports[idx].copyWith(status: status);
      _reportsNotifier.value = List.unmodifiable(_reports);
    }
  }

  // Admin summary statistics
  Map<String, int> getAdminStats() {
    final allUsers = _authRepo.allUsers;
    final allJobs = _jobRepo.allJobs;
    return {
      'totalStudents': allUsers.where((u) => u.isStudent).length,
      'totalAlumni': allUsers.where((u) => u.isAlumni).length,
      'pendingVerifications': allUsers.where((u) => u.verificationStatus == VerificationStatus.pending).length,
      'activeJobs': allJobs.where((j) => j.status == JobStatus.approved).length,
      'pendingJobs': allJobs.where((j) => j.status == JobStatus.pendingApproval).length,
      'pendingReports': _reports.where((r) => r.status == 'pending').length,
    };
  }
}
