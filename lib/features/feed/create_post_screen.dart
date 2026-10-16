import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  String _selectedCategory = 'post';
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something before posting')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    ref.read(postsFeedProvider.notifier).addPost(
          author: currentUser,
          content: content,
          category: _selectedCategory,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post published to KASUConnect!')),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                  backgroundImage: currentUser?.avatarUrl != null
                      ? NetworkImage(currentUser!.avatarUrl!)
                      : null,
                  child: currentUser?.avatarUrl == null
                      ? Text(
                          currentUser?.fullName.isNotEmpty == true ? currentUser!.fullName[0] : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentUser?.fullName ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        if (currentUser?.isAlumni == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.blue, size: 16),
                        ],
                      ],
                    ),
                    Text(
                      currentUser?.subtitleInfo ?? 'KASU Member',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Category picker dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: AppConstants.postTypes.entries.map((e) {
                    return DropdownMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          Icon(
                            e.key == 'success_story'
                                ? Icons.auto_awesome
                                : e.key == 'advice'
                                    ? Icons.lightbulb_outline
                                    : e.key == 'reunion'
                                        ? Icons.event
                                        : Icons.article_outlined,
                            size: 18,
                            color: AppColors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Content text area
            TextField(
              controller: _contentController,
              maxLines: 8,
              maxLength: AppConstants.maxPostLength,
              decoration: InputDecoration(
                hintText: _selectedCategory == 'success_story'
                    ? 'Share your inspiring journey from KASU to your current career...'
                    : _selectedCategory == 'advice'
                        ? 'Share career, academic, or industry advice with KASU undergraduates...'
                        : _selectedCategory == 'reunion'
                            ? 'Announce an alumni reunion, meet-up, or homecoming event...'
                            : 'What is happening in your department or project?',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),

            const SizedBox(height: 20),

            // Media attachment simulation buttons
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image attachment preview ready')),
                    );
                  },
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Add Photo'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tagging department members')),
                    );
                  },
                  icon: const Icon(Icons.alternate_email, size: 18),
                  label: const Text('Tag Dept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
