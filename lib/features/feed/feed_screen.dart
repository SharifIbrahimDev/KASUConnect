import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../home/widgets/demo_role_switcher.dart';
import 'widgets/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final allPosts = ref.watch(postsFeedProvider);

    final filteredPosts = allPosts.where((p) {
      if (_selectedCategory == 'all') return true;
      if (_selectedCategory == 'department') {
        return currentUser != null &&
            p.authorDepartment.toLowerCase() == currentUser.department.toLowerCase();
      }
      return p.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  AppAssets.kasuLogo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.school, color: AppColors.blue, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('KASUConnect', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        actions: [
          // Demo role perspective switcher button
          ActionChip(
            avatar: Icon(
              currentUser?.isAlumni ?? false
                  ? Icons.verified
                  : currentUser?.isAdmin ?? false
                      ? Icons.shield
                      : Icons.school,
              size: 16,
              color: currentUser?.isAlumni ?? false
                  ? AppColors.blue
                  : currentUser?.isAdmin ?? false
                      ? const Color(0xFF7C3AED)
                      : AppColors.teal,
            ),
            label: Text(
              currentUser?.role.displayName ?? 'Role',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => DemoRoleSwitcherSheet.show(context),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => context.push('/chat'),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Re-trigger post updates
          ref.invalidate(postsFeedProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Quick Post Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.blue.withValues(alpha: 0.2)),
                  ),
                  child: InkWell(
                    onTap: () => context.push('/create-post'),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.blue.withValues(alpha: 0.15),
                            backgroundImage: currentUser?.avatarUrl != null
                                ? NetworkImage(currentUser!.avatarUrl!)
                                : null,
                            child: currentUser?.avatarUrl == null
                                ? Text(
                                    currentUser?.fullName.isNotEmpty == true
                                        ? currentUser!.fullName[0]
                                        : 'U',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentUser?.isAlumni == true
                                  ? 'Share career advice or announce a reunion...'
                                  : 'Share project updates or ask KASU peers...',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, color: AppColors.blue, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter Pills
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All Posts', Icons.dynamic_feed),
                    const SizedBox(width: 8),
                    _buildFilterChip('department', 'My Dept (${currentUser?.department.split(' ').first ?? 'Dept'})', Icons.groups),
                    const SizedBox(width: 8),
                    _buildFilterChip('success_story', 'Success Stories 🌟', Icons.auto_awesome),
                    const SizedBox(width: 8),
                    _buildFilterChip('advice', 'Career Advice 💡', Icons.lightbulb_outline),
                    const SizedBox(width: 8),
                    _buildFilterChip('reunion', 'Reunions & Events 🎓', Icons.event),
                  ],
                ),
              ),
            ),

            // Posts List
            if (filteredPosts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.feed_outlined, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'No posts found in this category yet',
                        style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => context.push('/create-post'),
                        icon: const Icon(Icons.add),
                        label: const Text('Be the first to post!'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = filteredPosts[index];
                    return PostCard(
                      post: post,
                      onTap: () => context.push('/post/${post.id}'),
                    );
                  },
                  childCount: filteredPosts.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-post'),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Post'),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, IconData icon) {
    final isSelected = _selectedCategory == key;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.blue),
      selectedColor: AppColors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (val) {
        setState(() => _selectedCategory = key);
      },
    );
  }
}
