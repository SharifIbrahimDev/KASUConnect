enum MentorshipStatus {
  pending,
  accepted,
  declined,
  completed;

  String get displayName {
    switch (this) {
      case MentorshipStatus.pending:
        return 'Pending Approval';
      case MentorshipStatus.accepted:
        return 'Active Mentorship';
      case MentorshipStatus.declined:
        return 'Declined';
      case MentorshipStatus.completed:
        return 'Completed';
    }
  }

  static MentorshipStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'accepted':
        return MentorshipStatus.accepted;
      case 'declined':
        return MentorshipStatus.declined;
      case 'completed':
        return MentorshipStatus.completed;
      default:
        return MentorshipStatus.pending;
    }
  }
}

class MentorshipModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentDepartment;
  final String? studentLevel;
  final String? studentAvatar;
  final String alumniId;
  final String alumniName;
  final String? alumniJobTitle;
  final String? alumniCompany;
  final String? alumniAvatar;
  final String message; // e.g., "Sir, please mentor me."
  final String fieldOfInterest;
  final MentorshipStatus status;
  final String? alumniResponseNote;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MentorshipModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentDepartment,
    this.studentLevel,
    this.studentAvatar,
    required this.alumniId,
    required this.alumniName,
    this.alumniJobTitle,
    this.alumniCompany,
    this.alumniAvatar,
    required this.message,
    required this.fieldOfInterest,
    this.status = MentorshipStatus.pending,
    this.alumniResponseNote,
    required this.createdAt,
    this.updatedAt,
  });

  MentorshipModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentDepartment,
    String? studentLevel,
    String? studentAvatar,
    String? alumniId,
    String? alumniName,
    String? alumniJobTitle,
    String? alumniCompany,
    String? alumniAvatar,
    String? message,
    String? fieldOfInterest,
    MentorshipStatus? status,
    String? alumniResponseNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MentorshipModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentDepartment: studentDepartment ?? this.studentDepartment,
      studentLevel: studentLevel ?? this.studentLevel,
      studentAvatar: studentAvatar ?? this.studentAvatar,
      alumniId: alumniId ?? this.alumniId,
      alumniName: alumniName ?? this.alumniName,
      alumniJobTitle: alumniJobTitle ?? this.alumniJobTitle,
      alumniCompany: alumniCompany ?? this.alumniCompany,
      alumniAvatar: alumniAvatar ?? this.alumniAvatar,
      message: message ?? this.message,
      fieldOfInterest: fieldOfInterest ?? this.fieldOfInterest,
      status: status ?? this.status,
      alumniResponseNote: alumniResponseNote ?? this.alumniResponseNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentDepartment': studentDepartment,
      'studentLevel': studentLevel,
      'studentAvatar': studentAvatar,
      'alumniId': alumniId,
      'alumniName': alumniName,
      'alumniJobTitle': alumniJobTitle,
      'alumniCompany': alumniCompany,
      'alumniAvatar': alumniAvatar,
      'message': message,
      'fieldOfInterest': fieldOfInterest,
      'status': status.name,
      'alumniResponseNote': alumniResponseNote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory MentorshipModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MentorshipModel(
      id: id ?? map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentDepartment: map['studentDepartment'] ?? '',
      studentLevel: map['studentLevel'],
      studentAvatar: map['studentAvatar'],
      alumniId: map['alumniId'] ?? '',
      alumniName: map['alumniName'] ?? '',
      alumniJobTitle: map['alumniJobTitle'],
      alumniCompany: map['alumniCompany'],
      alumniAvatar: map['alumniAvatar'],
      message: map['message'] ?? '',
      fieldOfInterest: map['fieldOfInterest'] ?? '',
      status: MentorshipStatus.fromString(map['status']),
      alumniResponseNote: map['alumniResponseNote'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }
}
