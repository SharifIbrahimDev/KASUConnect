class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String? authorAvatar;
  final bool isVerifiedAlumni;
  final String content;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    this.isVerifiedAlumni = false,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatar': authorAvatar,
      'isVerifiedAlumni': isVerifiedAlumni,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CommentModel(
      id: id ?? map['id'] ?? '',
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorRole: map['authorRole'] ?? 'student',
      authorAvatar: map['authorAvatar'],
      isVerifiedAlumni: map['isVerifiedAlumni'] ?? false,
      content: map['content'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
