enum UserRole {
  student,
  alumni,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.alumni:
        return 'Alumni';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'alumni':
      case 'alumnus':
        return UserRole.alumni;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

enum VerificationStatus {
  pending,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending Verification';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  static VerificationStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;
  final String? matricNumber; // For students: e.g. KASU/20/CSC/1042
  final String? alumniId; // For alumni: e.g. ALM-2019-042
  final String? graduationYear; // e.g. 2021
  final String faculty;
  final String department;
  final String? level; // e.g. '100L', '200L', '300L', '400L', '500L'
  final List<String> skills;
  final String? bio;
  final String? currentCompany;
  final String? jobTitle;
  final bool isMentor;
  final String? mentorBio;
  final bool isAvailableForMentorship;
  final VerificationStatus verificationStatus;
  final bool isBlocked;
  final String? cvUrl;
  final String? cvFileName;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.matricNumber,
    this.alumniId,
    this.graduationYear,
    required this.faculty,
    required this.department,
    this.level,
    this.skills = const [],
    this.bio,
    this.currentCompany,
    this.jobTitle,
    this.isMentor = false,
    this.mentorBio,
    this.isAvailableForMentorship = false,
    this.verificationStatus = VerificationStatus.pending,
    this.isBlocked = false,
    this.cvUrl,
    this.cvFileName,
    required this.createdAt,
  });

  bool get isStudent => role == UserRole.student;
  bool get isAlumni => role == UserRole.alumni;
  bool get isAdmin => role == UserRole.admin;
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  String get subtitleInfo {
    if (isStudent) {
      return '$department ${level != null ? '• $level' : ''}';
    } else if (isAlumni) {
      if (jobTitle != null && currentCompany != null) {
        return '$jobTitle at $currentCompany';
      } else if (jobTitle != null) {
        return jobTitle!;
      }
      return 'Class of ${graduationYear ?? 'Alumni'} • $department';
    } else {
      return 'KASU Administrator';
    }
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? avatarUrl,
    String? matricNumber,
    String? alumniId,
    String? graduationYear,
    String? faculty,
    String? department,
    String? level,
    List<String>? skills,
    String? bio,
    String? currentCompany,
    String? jobTitle,
    bool? isMentor,
    String? mentorBio,
    bool? isAvailableForMentorship,
    VerificationStatus? verificationStatus,
    bool? isBlocked,
    String? cvUrl,
    String? cvFileName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      matricNumber: matricNumber ?? this.matricNumber,
      alumniId: alumniId ?? this.alumniId,
      graduationYear: graduationYear ?? this.graduationYear,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      level: level ?? this.level,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      currentCompany: currentCompany ?? this.currentCompany,
      jobTitle: jobTitle ?? this.jobTitle,
      isMentor: isMentor ?? this.isMentor,
      mentorBio: mentorBio ?? this.mentorBio,
      isAvailableForMentorship:
          isAvailableForMentorship ?? this.isAvailableForMentorship,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isBlocked: isBlocked ?? this.isBlocked,
      cvUrl: cvUrl ?? this.cvUrl,
      cvFileName: cvFileName ?? this.cvFileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'avatarUrl': avatarUrl,
      'matricNumber': matricNumber,
      'alumniId': alumniId,
      'graduationYear': graduationYear,
      'faculty': faculty,
      'department': department,
      'level': level,
      'skills': skills,
      'bio': bio,
      'currentCompany': currentCompany,
      'jobTitle': jobTitle,
      'isMentor': isMentor,
      'mentorBio': mentorBio,
      'isAvailableForMentorship': isAvailableForMentorship,
      'verificationStatus': verificationStatus.name,
      'isBlocked': isBlocked,
      'cvUrl': cvUrl,
      'cvFileName': cvFileName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserModel(
      id: id ?? map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: UserRole.fromString(map['role']),
      avatarUrl: map['avatarUrl'],
      matricNumber: map['matricNumber'],
      alumniId: map['alumniId'],
      graduationYear: map['graduationYear'],
      faculty: map['faculty'] ?? '',
      department: map['department'] ?? '',
      level: map['level'],
      skills: List<String>.from(map['skills'] ?? const []),
      bio: map['bio'],
      currentCompany: map['currentCompany'],
      jobTitle: map['jobTitle'],
      isMentor: map['isMentor'] ?? false,
      mentorBio: map['mentorBio'],
      isAvailableForMentorship: map['isAvailableForMentorship'] ?? false,
      verificationStatus:
          VerificationStatus.fromString(map['verificationStatus']),
      isBlocked: map['isBlocked'] ?? false,
      cvUrl: map['cvUrl'],
      cvFileName: map['cvFileName'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
