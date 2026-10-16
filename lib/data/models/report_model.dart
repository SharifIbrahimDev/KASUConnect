class ReportModel {
  final String id;
  final String reporterId;
  final String reporterName;
  final String targetType; // 'post', 'job', 'user', 'comment'
  final String targetId;
  final String targetTitle;
  final String reason;
  final String? details;
  final String status; // 'pending', 'resolved', 'dismissed'
  final DateTime createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.reporterName,
    required this.targetType,
    required this.targetId,
    required this.targetTitle,
    required this.reason,
    this.details,
    this.status = 'pending',
    required this.createdAt,
  });

  ReportModel copyWith({
    String? id,
    String? reporterId,
    String? reporterName,
    String? targetType,
    String? targetId,
    String? targetTitle,
    String? reason,
    String? details,
    String? status,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reporterName: reporterName ?? this.reporterName,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetTitle: targetTitle ?? this.targetTitle,
      reason: reason ?? this.reason,
      details: details ?? this.details,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'targetType': targetType,
      'targetId': targetId,
      'targetTitle': targetTitle,
      'reason': reason,
      'details': details,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ReportModel(
      id: id ?? map['id'] ?? '',
      reporterId: map['reporterId'] ?? '',
      reporterName: map['reporterName'] ?? '',
      targetType: map['targetType'] ?? 'post',
      targetId: map['targetId'] ?? '',
      targetTitle: map['targetTitle'] ?? '',
      reason: map['reason'] ?? '',
      details: map['details'],
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
