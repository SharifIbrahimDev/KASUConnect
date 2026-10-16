import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../home/widgets/role_badge.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'success_story':
        return const Color(0xFF10B981); // Emerald
      case 'advice':
        return AppColors.blue;
      case 'reunion':
        return const Color(0xFFF59E0B); // Amber
      default:
        return AppColors.textSecondary;
    }
  }

  void _showReportDialog(BuildContext context, WidgetRef ref, UserModel? currentUser) {
    if (currentUser == null) return;
    String selectedReason = AppConstants.reportReasons.first;
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Report Post to Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help KASU administrators keep the platform safe and scam-free.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedReason,
                items: AppConstants.reportReasons.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedReason = v);
                },
                decoration: const InputDecoration(labelText: 'Reason'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(
                  labelText: 'Additional Details (optional)',
                  hintText: 'Describe what is wrong...',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(adminRepositoryProvider).submitReport(
                      reporter: currentUser,
                      targetType: 'post',
                      targetId: post.id,
                      targetTitle: post.content.length > 30 ? '${post.content.substring(0, 30)}...' : post.content,
                      reason: selectedReason,
                      details: detailsController.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted to KASU Admin. Thank you!')),
                );
              },
              child: const Text('Submit Report'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isLiked = currentUser != null && post.isLikedBy(currentUser.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryLabel = AppConstants.postTypes[post.category] ?? 'Post';
    final categoryColor = _getCategoryColor(post.category);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Author Avatar, Name, Role Badge, Category Tag, Menu
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                    backgroundImage: post.authorAvatar != null
                        ? NetworkImage(post.authorAvatar!)
                        : null,
                    child: post.authorAvatar == null
                        ? Text(
                            post.authorName.isNotEmpty ? post.authorName[0] : 'K',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.authorName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.isVerifiedAlumni || post.authorRole == 'alumni') ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: AppColors.blue, size: 16),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              post.authorRole == 'student' && post.authorLevel != null
                                  ? '${post.authorDepartment} • ${post.authorLevel}'
                                  : post.authorDepartment,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const Text(' • ', style: TextStyle(color: AppColors.textSecondary)),
                            Text(
                              DateFormatter.timeAgo(post.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Category pill
                  if (post.category != 'post')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        categoryLabel,
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  // Report / options menu
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                    onSelected: (val) {
                      if (val == 'report') {
                        _showReportDialog(context, ref, currentUser);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag_outlined, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Report Post', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Content text
              Text(
                post.content,
                style: const TextStyle(fontSize: 14, height: 1.45),
              ),

              if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 260),
                    width: double.infinity,
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: post.mediaUrl!.startsWith('assets/')
                        ? Image.asset(
                            post.mediaUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          )
                        : Image.network(
                            post.mediaUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Actions: Likes, Comments, Share
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: currentUser == null
                        ? null
                        : () {
                            ref.read(postsFeedProvider.notifier).toggleLike(post.id, currentUser.id);
                          },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            post.likesCount > 0 ? '${post.likesCount}' : 'Like',
                            style: TextStyle(
                              fontSize: 13,
                              color: isLiked ? Colors.red : AppColors.textSecondary,
                              fontWeight: isLiked ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            post.commentsCount > 0 ? '${post.commentsCount} Comments' : 'Comment',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post link copied to clipboard!')),
                      );
                    },
                    icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
