import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../home/widgets/role_badge.dart';
import '../alumni/mentorship_request_dialog.dart';
import '../feed/widgets/post_card.dart';
import '../jobs/widgets/cv_preview_dialog.dart';
import '../../data/models/job_application_model.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  void _showReportUserDialog(BuildContext context, WidgetRef ref, UserModel reporter, UserModel targetUser) {
    String selectedReason = AppConstants.reportReasons.first;
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Report ${targetUser.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Help keep KASUConnect safe. Reports are investigated by KASU administrators.',
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
                  labelText: 'Details',
                  hintText: 'Describe inappropriate or suspicious behavior...',
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
                      reporter: reporter,
                      targetType: 'user',
                      targetId: targetUser.id,
                      targetTitle: targetUser.fullName,
                      reason: selectedReason,
                      details: detailsController.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report submitted against ${targetUser.fullName}')),
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
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider);
    final user = userRepo.getUserById(userId) ?? (userId == currentUser?.id ? currentUser : null);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    final isSelf = currentUser?.id == user.id;
    final allPosts = ref.watch(postsFeedProvider);
    final userPosts = allPosts.where((p) => p.authorId == user.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelf ? 'My Profile' : user.fullName),
        actions: [
          if (isSelf)
            IconButton(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit_outlined),
            )
          else if (currentUser != null)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'report') {
                  _showReportUserDialog(context, ref, currentUser, user);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined, color: AppColors.error, size: 18),
                      SizedBox(width: 8),
                      Text('Report User', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner + Profile Details Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.blue.withValues(alpha: 0.12),
                    AppColors.teal.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: const Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.blue.withValues(alpha: 0.2),
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue, fontSize: 32),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (user.isAlumni) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: AppColors.blue, size: 22),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.subtitleInfo,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  VerificationStatusBadge(status: user.verificationStatus),

                  if (user.bio != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      user.bio!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!isSelf && currentUser != null) ...[
                        FilledButton.icon(
                          onPressed: () {
                            final chatRepo = ref.read(chatRepositoryProvider);
                            final conv = chatRepo.getOrCreateDirectChat(currentUser, user);
                            context.push('/chat/${conv.id}');
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Send Message'),
                          style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
                        ),
                        if (user.isAlumni && (user.isAvailableForMentorship || user.isMentor)) ...[
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: () => MentorshipRequestDialog.show(context, user),
                            icon: const Icon(Icons.handshake_outlined, size: 18),
                            label: const Text('Request Mentorship'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.blue),
                            ),
                          ),
                        ],
                      ] else ...[
                        OutlinedButton.icon(
                          onPressed: () => context.push('/edit-profile'),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Profile & CV'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Profile info sections
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Academic & Verification Info
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Academic Information',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(Icons.account_balance, 'Faculty', user.faculty),
                          const Divider(height: 16),
                          _buildDetailRow(Icons.business, 'Department', user.department),
                          if (user.isStudent) ...[
                            const Divider(height: 16),
                            _buildDetailRow(Icons.badge, 'Matriculation No.', user.matricNumber ?? 'Verified Student'),
                            const Divider(height: 16),
                            _buildDetailRow(Icons.school, 'Current Level', user.level ?? '400L'),
                          ] else if (user.isAlumni) ...[
                            const Divider(height: 16),
                            _buildDetailRow(Icons.history_edu, 'Class of', user.graduationYear ?? 'Alumni'),
                            const Divider(height: 16),
                            _buildDetailRow(Icons.verified_user, 'Alumni ID', user.alumniId ?? 'Verified KASU Alumni'),
                            if (user.currentCompany != null) ...[
                              const Divider(height: 16),
                              _buildDetailRow(Icons.work, 'Company', user.currentCompany!),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Skills Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Skills & Expertise',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 12),
                          if (user.skills.isEmpty)
                            const Text('No skills listed yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: user.skills.map((s) {
                                return Chip(
                                  label: Text(s),
                                  backgroundColor: AppColors.blue.withValues(alpha: 0.08),
                                  side: BorderSide(color: AppColors.blue.withValues(alpha: 0.2)),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // CV Document card (for students)
                  if (user.isStudent) ...[
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.description, color: AppColors.blue),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Curriculum Vitae (CV)',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    user.cvFileName ?? 'No CV attached yet',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () {
                                final dummyApp = JobApplicationModel(
                                  id: 'profile_${user.id}',
                                  jobId: '',
                                  jobTitle: 'KASU Candidate Profile',
                                  companyName: 'Academic Resume',
                                  applicantId: user.id,
                                  applicantName: user.fullName,
                                  applicantEmail: user.email,
                                  applicantDepartment: user.department,
                                  applicantLevel: user.level,
                                  cvFileName: user.cvFileName ?? '${user.fullName.replaceAll(' ', '_')}_Resume.pdf',
                                  coverNote: user.bio,
                                  status: ApplicationStatus.reviewed,
                                  appliedAt: DateTime.now(),
                                );
                                CvPreviewDialog.show(
                                  context,
                                  application: dummyApp,
                                  isEmployer: !isSelf,
                                );
                              },
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('Preview CV'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                            if (isSelf) ...[
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => context.push('/edit-profile'),
                                child: Text(user.cvFileName == null ? 'Upload' : 'Change'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Posts by this user
                  Row(
                    children: [
                      const Text(
                        'Posts & Activity',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${userPosts.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (userPosts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No posts yet by this user',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...userPosts.map((p) => PostCard(post: p, onTap: () => context.push('/post/${p.id}'))),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.blue),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
