import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_model.dart';
import '../models/job_application_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_seed.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

final jobsListProvider = StateNotifierProvider<JobsListNotifier, List<JobModel>>((ref) {
  final repo = ref.watch(jobRepositoryProvider);
  return JobsListNotifier(repo);
});

final userApplicationsProvider = Provider<List<JobApplicationModel>>((ref) {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.applications;
});

class JobsListNotifier extends StateNotifier<List<JobModel>> {
  final JobRepository _repo;

  JobsListNotifier(this._repo) : super(_repo.getApprovedJobs()) {
    _repo.jobsStream.listen((_) {
      state = _repo.getApprovedJobs();
    });
  }

  void postJob({
    required UserModel poster,
    required String title,
    required String company,
    required String location,
    required String workArrangement,
    required String jobType,
    required String description,
    required String requirements,
    String? salary,
    List<String> targetDepartments = const [],
    DateTime? deadline,
  }) {
    _repo.postJob(
      poster: poster,
      title: title,
      company: company,
      location: location,
      workArrangement: workArrangement,
      jobType: jobType,
      description: description,
      requirements: requirements,
      salary: salary,
      targetDepartments: targetDepartments,
      deadline: deadline,
    );
    state = _repo.getApprovedJobs();
  }

  void refresh() {
    state = _repo.getApprovedJobs();
  }
}

class JobRepository {
  final List<JobModel> _jobs = List.from(MockDataSeed.jobs);
  final List<JobApplicationModel> _applications = List.from(MockDataSeed.applications);
  final ValueNotifier<List<JobModel>> _jobsNotifier = ValueNotifier([]);

  JobRepository() {
    _jobsNotifier.value = List.unmodifiable(_jobs);
  }

  Stream<List<JobModel>> get jobsStream => Stream.periodic(
        const Duration(milliseconds: 500),
        (_) => List<JobModel>.unmodifiable(_jobs),
      ).distinct();

  List<JobModel> get allJobs => List.unmodifiable(_jobs);
  List<JobApplicationModel> get applications => List.unmodifiable(_applications);

  List<JobModel> getApprovedJobs({
    String? query,
    String? jobType,
    String? arrangement,
    String? department,
  }) {
    var filtered = _jobs.where((j) => j.status == JobStatus.approved).toList();

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      filtered = filtered.where((j) {
        return j.title.toLowerCase().contains(q) ||
            j.company.toLowerCase().contains(q) ||
            j.description.toLowerCase().contains(q) ||
            j.location.toLowerCase().contains(q);
      }).toList();
    }

    if (jobType != null && jobType != 'all') {
      filtered = filtered.where((j) => j.jobType == jobType).toList();
    }

    if (arrangement != null && arrangement != 'all') {
      filtered = filtered.where((j) => j.workArrangement == arrangement).toList();
    }

    if (department != null && department != 'All Departments') {
      filtered = filtered.where((j) {
        return j.targetDepartments.isEmpty || j.targetDepartments.contains(department);
      }).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(filtered);
  }

  List<JobModel> getPendingJobs() {
    return _jobs.where((j) => j.status == JobStatus.pendingApproval).toList();
  }

  List<JobModel> getJobsByPoster(String posterId) {
    return _jobs.where((j) => j.posterId == posterId).toList();
  }

  JobModel? getJobById(String id) {
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  JobModel postJob({
    required UserModel poster,
    required String title,
    required String company,
    required String location,
    required String workArrangement,
    required String jobType,
    required String description,
    required String requirements,
    String? salary,
    List<String> targetDepartments = const [],
    DateTime? deadline,
  }) {
    // If posted by Admin, auto-approve; if posted by Alumni, requires Admin Approval to prevent scams!
    final initialStatus = poster.isAdmin ? JobStatus.approved : JobStatus.pendingApproval;

    final newJob = JobModel(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      company: company,
      location: location,
      workArrangement: workArrangement,
      jobType: jobType,
      description: description,
      requirements: requirements,
      salary: salary,
      posterId: poster.id,
      posterName: poster.fullName,
      posterEmail: poster.email,
      isAlumniPoster: poster.isAlumni,
      targetDepartments: targetDepartments,
      status: initialStatus,
      applicationsCount: 0,
      deadline: deadline ?? DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
    );

    _jobs.insert(0, newJob);
    _jobsNotifier.value = List.unmodifiable(_jobs);
    return newJob;
  }

  void approveJob(String jobId) {
    final idx = _jobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      _jobs[idx] = _jobs[idx].copyWith(status: JobStatus.approved);
      _jobsNotifier.value = List.unmodifiable(_jobs);
    }
  }

  void rejectJob(String jobId) {
    final idx = _jobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      _jobs[idx] = _jobs[idx].copyWith(status: JobStatus.rejected);
      _jobsNotifier.value = List.unmodifiable(_jobs);
    }
  }

  JobApplicationModel applyForJob({
    required JobModel job,
    required UserModel applicant,
    String? coverNote,
    String? cvFileName,
    String? cvUrl,
  }) {
    final newApp = JobApplicationModel(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      jobId: job.id,
      jobTitle: job.title,
      companyName: job.company,
      applicantId: applicant.id,
      applicantName: applicant.fullName,
      applicantEmail: applicant.email,
      applicantDepartment: applicant.department,
      applicantLevel: applicant.level,
      cvUrl: cvUrl ?? applicant.cvUrl,
      cvFileName: cvFileName ?? applicant.cvFileName ?? '${applicant.fullName.replaceAll(' ', '_')}_CV.pdf',
      coverNote: coverNote,
      status: ApplicationStatus.pending,
      appliedAt: DateTime.now(),
    );

    _applications.insert(0, newApp);

    // Update applications count on the job
    final jobIdx = _jobs.indexWhere((j) => j.id == job.id);
    if (jobIdx != -1) {
      _jobs[jobIdx] = _jobs[jobIdx].copyWith(
        applicationsCount: _jobs[jobIdx].applicationsCount + 1,
      );
      _jobsNotifier.value = List.unmodifiable(_jobs);
    }

    return newApp;
  }

  List<JobApplicationModel> getApplicationsForUser(String userId) {
    return _applications.where((a) => a.applicantId == userId).toList();
  }

  List<JobApplicationModel> getApplicationsForJob(String jobId) {
    return _applications.where((a) => a.jobId == jobId).toList();
  }

  bool hasUserApplied(String jobId, String userId) {
    return _applications.any((a) => a.jobId == jobId && a.applicantId == userId);
  }

  void updateApplicationStatus(String applicationId, ApplicationStatus newStatus) {
    final idx = _applications.indexWhere((a) => a.id == applicationId);
    if (idx != -1) {
      _applications[idx] = _applications[idx].copyWith(
        status: newStatus,
        reviewedAt: DateTime.now(),
      );
    }
  }
}
