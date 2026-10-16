import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/chat_repository.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatConversationScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    ref.read(chatRepositoryProvider).sendMessage(
          chatId: widget.chatId,
          sender: currentUser,
          text: text,
        );

    _messageController.clear();
    ref.read(chatConversationsProvider.notifier).refresh();
    setState(() {});

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatRepo = ref.watch(chatRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider);

    final conversations = chatRepo.conversations;
    final conv = conversations.firstWhere(
      (c) => c.id == widget.chatId,
      orElse: () => ChatConversationModel(
        id: widget.chatId,
        participantIds: [],
        participantNames: {},
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
    );

    final title = currentUser != null ? conv.getTitle(currentUser.id) : 'Chat';
    final subtitle = currentUser != null ? conv.getSubtitle(currentUser.id) : null;
    final messages = chatRepo.getMessagesForChat(widget.chatId);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.blue.withValues(alpha: 0.15),
              child: conv.isDepartmentGroup
                  ? const Icon(Icons.groups, color: AppColors.blue, size: 20)
                  : Text(
                      title.isNotEmpty ? title[0] : 'C',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (subtitle?.contains('Alumni') ?? false) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: AppColors.blue, size: 14),
                      ],
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.waving_hand, size: 40, color: Colors.amber.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Say hello to $title!',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Start your conversation now.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUser?.id;
                      return _buildMessageBubble(msg, isMe, conv.isDepartmentGroup);
                    },
                  ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(backgroundColor: AppColors.blue),
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg, bool isMe, bool isGroup) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.blue
              : Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.grey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && isGroup) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.senderName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.teal),
                  ),
                  if (msg.isSenderVerified || msg.senderRole == 'alumni') ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppColors.blue, size: 12),
                  ],
                ],
              ),
              const SizedBox(height: 2),
            ],
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.white : null,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.chatTime(msg.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
