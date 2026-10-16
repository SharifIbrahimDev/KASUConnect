class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String authorRole; // 'student', 'alumni', 'admin'
  final String? authorAvatar;
  final String authorDepartment;
  final String? authorLevel;
  final bool isVerifiedAlumni;
  final String content;
  final String category; // 'post', 'advice', 'success_story', 'reunion'
  final String? mediaUrl;
  final List<String> likes;
  final int commentsCount;
  final DateTime createdAt;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.authorAvatar,
    required this.authorDepartment,
    this.authorLevel,
    this.isVerifiedAlumni = false,
    required this.content,
    this.category = 'post',
    this.mediaUrl,
    this.likes = const [],
    this.commentsCount = 0,
    required this.createdAt,
  });

  int get likesCount => likes.length;

  bool isLikedBy(String userId) => likes.contains(userId);

  PostModel copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? authorAvatar,
    String? authorDepartment,
    String? authorLevel,
    bool? isVerifiedAlumni,
    String? content,
    String? category,
    String? mediaUrl,
    List<String>? likes,
    int? commentsCount,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      authorDepartment: authorDepartment ?? this.authorDepartment,
      authorLevel: authorLevel ?? this.authorLevel,
      isVerifiedAlumni: isVerifiedAlumni ?? this.isVerifiedAlumni,
      content: content ?? this.content,
      category: category ?? this.category,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      likes: likes ?? this.likes,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'authorAvatar': authorAvatar,
      'authorDepartment': authorDepartment,
      'authorLevel': authorLevel,
      'isVerifiedAlumni': isVerifiedAlumni,
      'content': content,
      'category': category,
      'mediaUrl': mediaUrl,
      'likes': likes,
      'commentsCount': commentsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return PostModel(
      id: id ?? map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorRole: map['authorRole'] ?? 'student',
      authorAvatar: map['authorAvatar'],
      authorDepartment: map['authorDepartment'] ?? '',
      authorLevel: map['authorLevel'],
      isVerifiedAlumni: map['isVerifiedAlumni'] ?? false,
      content: map['content'] ?? '',
      category: map['category'] ?? 'post',
      mediaUrl: map['mediaUrl'],
      likes: List<String>.from(map['likes'] ?? const []),
      commentsCount: map['commentsCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
