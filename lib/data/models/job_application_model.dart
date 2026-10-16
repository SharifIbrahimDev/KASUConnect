enum ApplicationStatus {
  pending,
  reviewed,
  accepted,
  rejected;

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending Review';
      case ApplicationStatus.reviewed:
        return 'Under Review';
      case ApplicationStatus.accepted:
        return 'Accepted 🎉';
      case ApplicationStatus.rejected:
        return 'Not Selected';
    }
  }

  static ApplicationStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'reviewed':
        return ApplicationStatus.reviewed;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }
}

class JobApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final String applicantDepartment;
  final String? applicantLevel;
  final String? cvUrl;
  final String? cvFileName;
  final String? coverNote;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? reviewedAt;

  const JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.applicantDepartment,
    this.applicantLevel,
    this.cvUrl,
    this.cvFileName,
    this.coverNote,
    this.status = ApplicationStatus.pending,
    required this.appliedAt,
    this.reviewedAt,
  });

  JobApplicationModel copyWith({
    String? id,
    String? jobId,
    String? jobTitle,
    String? companyName,
    String? applicantId,
    String? applicantName,
    String? applicantEmail,
    String? applicantDepartment,
    String? applicantLevel,
    String? cvUrl,
    String? cvFileName,
    String? coverNote,
    ApplicationStatus? status,
    DateTime? appliedAt,
    DateTime? reviewedAt,
  }) {
    return JobApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantDepartment: applicantDepartment ?? this.applicantDepartment,
      applicantLevel: applicantLevel ?? this.applicantLevel,
      cvUrl: cvUrl ?? this.cvUrl,
      cvFileName: cvFileName ?? this.cvFileName,
      coverNote: coverNote ?? this.coverNote,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantDepartment': applicantDepartment,
      'applicantLevel': applicantLevel,
      'cvUrl': cvUrl,
      'cvFileName': cvFileName,
      'coverNote': coverNote,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory JobApplicationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return JobApplicationModel(
      id: id ?? map['id'] ?? '',
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      companyName: map['companyName'] ?? '',
      applicantId: map['applicantId'] ?? '',
      applicantName: map['applicantName'] ?? '',
      applicantEmail: map['applicantEmail'] ?? '',
      applicantDepartment: map['applicantDepartment'] ?? '',
      applicantLevel: map['applicantLevel'],
      cvUrl: map['cvUrl'],
      cvFileName: map['cvFileName'],
      coverNote: map['coverNote'],
      status: ApplicationStatus.fromString(map['status']),
      appliedAt: map['appliedAt'] != null
          ? DateTime.tryParse(map['appliedAt']) ?? DateTime.now()
          : DateTime.now(),
      reviewedAt: map['reviewedAt'] != null
          ? DateTime.tryParse(map['reviewedAt'])
          : null,
    );
  }
}
