import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../services/mock_data_seed.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

final chatConversationsProvider = StateNotifierProvider<ChatConversationsNotifier, List<ChatConversationModel>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return ChatConversationsNotifier(repo);
});

class ChatConversationsNotifier extends StateNotifier<List<ChatConversationModel>> {
  final ChatRepository _repo;

  ChatConversationsNotifier(this._repo) : super(_repo.conversations) {
    _repo.stream.listen((convs) {
      state = convs;
    });
  }

  void refresh() {
    state = _repo.conversations;
  }
}

class ChatRepository {
  final List<ChatConversationModel> _conversations = List.from(MockDataSeed.conversations);
  final List<ChatMessageModel> _messages = List.from(MockDataSeed.sampleMessages);
  final ValueNotifier<List<ChatConversationModel>> _notifier = ValueNotifier([]);

  ChatRepository() {
    _notifier.value = List.unmodifiable(_conversations);
  }

  Stream<List<ChatConversationModel>> get stream => Stream.periodic(
        const Duration(milliseconds: 500),
        (_) => List<ChatConversationModel>.unmodifiable(_conversations),
      ).distinct();

  List<ChatConversationModel> get conversations => List.unmodifiable(_conversations);

  List<ChatConversationModel> getConversationsForUser(String userId, String userDepartment) {
    return _conversations.where((c) {
      if (c.isDepartmentGroup) {
        return c.departmentName?.toLowerCase() == userDepartment.toLowerCase() ||
            c.participantIds.contains(userId);
      }
      return c.participantIds.contains(userId);
    }).toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  List<ChatMessageModel> getMessagesForChat(String chatId) {
    final msgs = _messages.where((m) => m.chatId == chatId).toList();
    msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(msgs);
  }

  ChatMessageModel sendMessage({
    required String chatId,
    required UserModel sender,
    required String text,
  }) {
    final msg = ChatMessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: sender.id,
      senderName: sender.fullName,
      senderRole: sender.role.name,
      senderAvatar: sender.avatarUrl,
      isSenderVerified: sender.isVerified,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    _messages.add(msg);

    // Update conversation
    final idx = _conversations.indexWhere((c) => c.id == chatId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(
        lastMessage: text,
        lastMessageTime: DateTime.now(),
      );
    }

    _notifier.value = List.unmodifiable(_conversations);
    return msg;
  }

  ChatConversationModel getOrCreateDirectChat(UserModel currentUser, UserModel otherUser) {
    // Check if chat already exists
    final existing = _conversations.firstWhere(
      (c) =>
          !c.isDepartmentGroup &&
          c.participantIds.contains(currentUser.id) &&
          c.participantIds.contains(otherUser.id),
      orElse: () {
        final newConv = ChatConversationModel(
          id: 'conv_${currentUser.id}_${otherUser.id}',
          participantIds: [currentUser.id, otherUser.id],
          participantNames: {
            currentUser.id: currentUser.fullName,
            otherUser.id: otherUser.fullName,
          },
          participantAvatars: {
            currentUser.id: currentUser.avatarUrl,
            otherUser.id: otherUser.avatarUrl,
          },
          participantRoles: {
            currentUser.id: currentUser.role.name,
            otherUser.id: otherUser.role.name,
          },
          lastMessage: 'Started conversation with ${otherUser.fullName}',
          lastMessageTime: DateTime.now(),
          unreadCount: 0,
        );
        _conversations.insert(0, newConv);
        _notifier.value = List.unmodifiable(_conversations);
        return newConv;
      },
    );

    return existing;
  }

  ChatConversationModel getOrCreateDepartmentGroup(String departmentName, UserModel currentUser) {
    final existing = _conversations.firstWhere(
      (c) => c.isDepartmentGroup && c.departmentName?.toLowerCase() == departmentName.toLowerCase(),
      orElse: () {
        final newConv = ChatConversationModel(
          id: 'conv_dept_${departmentName.replaceAll(' ', '_').toLowerCase()}',
          participantIds: [currentUser.id],
          participantNames: {currentUser.id: currentUser.fullName},
          participantRoles: {currentUser.id: currentUser.role.name},
          lastMessage: 'Welcome to the official $departmentName Group!',
          lastMessageTime: DateTime.now(),
          isDepartmentGroup: true,
          departmentName: departmentName,
        );
        _conversations.insert(0, newConv);
        _notifier.value = List.unmodifiable(_conversations);
        return newConv;
      },
    );

    return existing;
  }
}
