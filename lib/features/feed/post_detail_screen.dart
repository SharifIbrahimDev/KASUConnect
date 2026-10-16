import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';
import 'widgets/post_card.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _handleAddComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    ref.read(postsFeedProvider.notifier).addComment(widget.postId, currentUser, text);
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(postRepositoryProvider);
    final post = repo.getPostById(widget.postId);
    final comments = repo.getCommentsForPost(widget.postId);
    final currentUser = ref.watch(currentUserProvider);

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: Text('Post not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                PostCard(post: post),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Comments & Discussion',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No comments yet. Start the conversation!',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  ...comments.map((comment) => _buildCommentTile(comment)),
              ],
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
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
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLength: AppConstants.maxCommentLength,
                      buildCounter: (_, {required currentLength, isFocused, maxLength}) => null,
                      decoration: const InputDecoration(
                        hintText: 'Add a helpful comment or question...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _handleAddComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _handleAddComment,
                    style: IconButton.styleFrom(backgroundColor: AppColors.blue),
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.blue.withValues(alpha: 0.1),
            backgroundImage: comment.authorAvatar != null ? NetworkImage(comment.authorAvatar!) : null,
            child: comment.authorAvatar == null
                ? Text(
                    comment.authorName.isNotEmpty ? comment.authorName[0] : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue, fontSize: 12),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1E293B)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      if (comment.isVerifiedAlumni) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: AppColors.blue, size: 14),
                      ],
                      const Spacer(),
                      Text(
                        DateFormatter.timeAgo(comment.createdAt),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.content, style: const TextStyle(fontSize: 13, height: 1.35)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
