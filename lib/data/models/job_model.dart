enum JobStatus {
  pendingApproval,
  approved,
  rejected,
  closed;

  String get displayName {
    switch (this) {
      case JobStatus.pendingApproval:
        return 'Pending Approval';
      case JobStatus.approved:
        return 'Approved & Active';
      case JobStatus.rejected:
        return 'Rejected';
      case JobStatus.closed:
        return 'Closed';
    }
  }

  static JobStatus fromString(String? val) {
    switch (val) {
      case 'approved':
        return JobStatus.approved;
      case 'rejected':
        return JobStatus.rejected;
      case 'closed':
        return JobStatus.closed;
      default:
        return JobStatus.pendingApproval;
    }
  }
}

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String workArrangement; // 'onsite', 'remote', 'hybrid'
  final String jobType; // 'internship', 'graduate_trainee', 'full_time', 'part_time', 'freelance'
  final String description;
  final String requirements;
  final String? salary;
  final String posterId;
  final String posterName;
  final String? posterEmail;
  final bool isAlumniPoster;
  final List<String> targetDepartments; // Empty means open to all
  final JobStatus status;
  final int applicationsCount;
  final DateTime? deadline;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workArrangement,
    required this.jobType,
    required this.description,
    required this.requirements,
    this.salary,
    required this.posterId,
    required this.posterName,
    this.posterEmail,
    this.isAlumniPoster = false,
    this.targetDepartments = const [],
    this.status = JobStatus.pendingApproval,
    this.applicationsCount = 0,
    this.deadline,
    required this.createdAt,
  });

  bool get isApproved => status == JobStatus.approved;
  bool get isPendingApproval => status == JobStatus.pendingApproval;

  JobModel copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? workArrangement,
    String? jobType,
    String? description,
    String? requirements,
    String? salary,
    String? posterId,
    String? posterName,
    String? posterEmail,
    bool? isAlumniPoster,
    List<String>? targetDepartments,
    JobStatus? status,
    int? applicationsCount,
    DateTime? deadline,
    DateTime? createdAt,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      workArrangement: workArrangement ?? this.workArrangement,
      jobType: jobType ?? this.jobType,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      salary: salary ?? this.salary,
      posterId: posterId ?? this.posterId,
      posterName: posterName ?? this.posterName,
      posterEmail: posterEmail ?? this.posterEmail,
      isAlumniPoster: isAlumniPoster ?? this.isAlumniPoster,
      targetDepartments: targetDepartments ?? this.targetDepartments,
      status: status ?? this.status,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'workArrangement': workArrangement,
      'jobType': jobType,
      'description': description,
      'requirements': requirements,
      'salary': salary,
      'posterId': posterId,
      'posterName': posterName,
      'posterEmail': posterEmail,
      'isAlumniPoster': isAlumniPoster,
      'targetDepartments': targetDepartments,
      'status': status.name,
      'applicationsCount': applicationsCount,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory JobModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return JobModel(
      id: id ?? map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? 'Kaduna',
      workArrangement: map['workArrangement'] ?? 'onsite',
      jobType: map['jobType'] ?? 'internship',
      description: map['description'] ?? '',
      requirements: map['requirements'] ?? '',
      salary: map['salary'],
      posterId: map['posterId'] ?? '',
      posterName: map['posterName'] ?? '',
      posterEmail: map['posterEmail'],
      isAlumniPoster: map['isAlumniPoster'] ?? false,
      targetDepartments:
          List<String>.from(map['targetDepartments'] ?? const []),
      status: JobStatus.fromString(map['status']),
      applicationsCount: map['applicationsCount'] ?? 0,
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
