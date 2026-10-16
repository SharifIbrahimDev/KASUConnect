import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/chat_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/chat_repository.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final chatRepo = ref.watch(chatRepositoryProvider);
    ref.watch(chatConversationsProvider); // Listen to changes

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access messages')),
      );
    }

    final allUserConvs = chatRepo.getConversationsForUser(currentUser.id, currentUser.department);
    final directConvs = allUserConvs.where((c) => !c.isDepartmentGroup).toList();
    final groupConvs = allUserConvs.where((c) => c.isDepartmentGroup).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages & Groups'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.blue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.blue,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 18),
                  const SizedBox(width: 8),
                  Text('Direct (${directConvs.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.groups_outlined, size: 18),
                  const SizedBox(width: 8),
                  const Text('Dept Groups'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Direct Messages
          directConvs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 56, color: Colors.grey.withValues(alpha: 0.4)),
                      const SizedBox(height: 16),
                      const Text(
                        'No direct conversations yet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Connect with peers, alumni mentors, and project teammates.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => context.push('/peer-search'),
                        icon: const Icon(Icons.search),
                        label: const Text('Find Peers by Skill'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: directConvs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 76),
                  itemBuilder: (context, index) {
                    final conv = directConvs[index];
                    return _buildConversationTile(conv, currentUser);
                  },
                ),

          // 2. Department Groups
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User's own department group banner
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.blue.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.groups, color: AppColors.blue, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${currentUser.department} Group',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Text(
                                  'Official KASU Department Channel',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Chat with all students and verified alumni in your department. Ask academic questions, share project updates, and discover local career openings.',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          final deptConv = chatRepo.getOrCreateDepartmentGroup(
                            currentUser.department,
                            currentUser,
                          );
                          context.push('/chat/${deptConv.id}');
                        },
                        icon: const Icon(Icons.forum_outlined),
                        label: Text('Open ${currentUser.department} Chat'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Other Department Channels',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),

              ...groupConvs.where((c) => c.departmentName != currentUser.department).map((conv) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.teal,
                      child: Icon(Icons.group, color: Colors.white, size: 20),
                    ),
                    title: Text(conv.getTitle(currentUser.id), style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(conv.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/chat/${conv.id}'),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ChatConversationModel conv, dynamic currentUser) {
    final title = conv.getTitle(currentUser.id);
    final subtitle = conv.getSubtitle(currentUser.id);
    final otherId = conv.participantIds.firstWhere((id) => id != currentUser.id, orElse: () => '');
    final avatar = conv.participantAvatars[otherId];
    final isAlumni = conv.participantRoles[otherId] == 'alumni';

    return ListTile(
      onTap: () => context.push('/chat/${conv.id}'),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null
                ? Text(title.isNotEmpty ? title[0] : 'U', style: const TextStyle(fontWeight: FontWeight.bold))
                : null,
          ),
          if (isAlumni)
            const Positioned(
              bottom: 0,
              right: 0,
              child: Icon(Icons.verified, color: AppColors.blue, size: 16),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            DateFormatter.chatTime(conv.lastMessageTime),
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null)
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 2),
          Text(
            conv.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
