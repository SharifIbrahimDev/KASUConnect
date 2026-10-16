class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String? senderAvatar;
  final bool isSenderVerified;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.senderAvatar,
    this.isSenderVerified = false,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'senderAvatar': senderAvatar,
      'isSenderVerified': isSenderVerified,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatMessageModel(
      id: id ?? map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? 'student',
      senderAvatar: map['senderAvatar'],
      isSenderVerified: map['isSenderVerified'] ?? false,
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}

class ChatConversationModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String?> participantAvatars;
  final Map<String, String> participantRoles;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isDepartmentGroup;
  final String? departmentName;

  const ChatConversationModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.participantAvatars = const {},
    this.participantRoles = const {},
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isDepartmentGroup = false,
    this.departmentName,
  });

  String getTitle(String currentUserId) {
    if (isDepartmentGroup) {
      return '$departmentName Group';
    }
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participantIds.isNotEmpty ? participantIds.first : '',
    );
    return participantNames[otherId] ?? 'Chat';
  }

  String? getSubtitle(String currentUserId) {
    if (isDepartmentGroup) {
      return 'Official Department Channel';
    }
    final otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
    final role = participantRoles[otherId];
    if (role == 'alumni') return 'Verified KASU Alumni';
    if (role == 'student') return 'KASU Student';
    if (role == 'admin') return 'KASU Administration';
    return null;
  }

  ChatConversationModel copyWith({
    String? id,
    List<String>? participantIds,
    Map<String, String>? participantNames,
    Map<String, String?>? participantAvatars,
    Map<String, String>? participantRoles,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isDepartmentGroup,
    String? departmentName,
  }) {
    return ChatConversationModel(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      participantNames: participantNames ?? this.participantNames,
      participantAvatars: participantAvatars ?? this.participantAvatars,
      participantRoles: participantRoles ?? this.participantRoles,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isDepartmentGroup: isDepartmentGroup ?? this.isDepartmentGroup,
      departmentName: departmentName ?? this.departmentName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'participantRoles': participantRoles,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isDepartmentGroup': isDepartmentGroup,
      'departmentName': departmentName,
    };
  }

  factory ChatConversationModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return ChatConversationModel(
      id: id ?? map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? const []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? const {}),
      participantAvatars: Map<String, String?>.from(map['participantAvatars'] ?? const {}),
      participantRoles: Map<String, String>.from(map['participantRoles'] ?? const {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.tryParse(map['lastMessageTime']) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
      isDepartmentGroup: map['isDepartmentGroup'] ?? false,
      departmentName: map['departmentName'],
    );
  }
}
