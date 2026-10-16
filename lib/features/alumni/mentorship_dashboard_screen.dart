import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/mentorship_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/mentorship_repository.dart';
import '../../data/repositories/chat_repository.dart';

class MentorshipDashboardScreen extends ConsumerWidget {
  const MentorshipDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final allRequests = ref.watch(mentorshipListProvider);

    final requests = currentUser?.isAlumni == true
        ? allRequests.where((r) => r.alumniId == currentUser!.id).toList()
        : allRequests.where((r) => r.studentId == currentUser?.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser?.isAlumni == true ? 'Mentorship Inquiries' : 'My Mentorship Requests'),
      ),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handshake_outlined, size: 56, color: Colors.grey.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.isAlumni == true
                        ? 'No student mentorship requests yet'
                        : 'You haven\'t sent any mentorship requests yet',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser?.isAlumni == true
                        ? 'When KASU students send you a request, it will appear here.'
                        : 'Explore verified alumni in the Alumni Hub and request guidance!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  if (currentUser?.isStudent == true) ...[
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.push('/alumni'),
                      icon: const Icon(Icons.explore),
                      label: const Text('Browse Alumni Mentors'),
                    ),
                  ],
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return _buildRequestCard(context, ref, req, currentUser);
              },
            ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    WidgetRef ref,
    MentorshipModel req,
    UserModel? currentUser,
  ) {
    final isAlumni = currentUser?.isAlumni ?? false;
    final isPending = req.status == MentorshipStatus.pending;
    final isAccepted = req.status == MentorshipStatus.accepted;

    Color statusColor;
    switch (req.status) {
      case MentorshipStatus.accepted:
        statusColor = AppColors.success;
        break;
      case MentorshipStatus.declined:
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.warning;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: (isAlumni ? req.studentAvatar : req.alumniAvatar) != null
                      ? NetworkImage(isAlumni ? req.studentAvatar! : req.alumniAvatar!)
                      : null,
                  child: Text(
                    (isAlumni ? req.studentName : req.alumniName).isNotEmpty
                        ? (isAlumni ? req.studentName[0] : req.alumniName[0])
                        : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAlumni ? req.studentName : req.alumniName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        isAlumni
                            ? '${req.studentDepartment} • ${req.studentLevel ?? 'Student'}'
                            : '${req.alumniJobTitle ?? 'Alumni'} • ${req.alumniCompany ?? 'Mentor'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    req.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars, color: AppColors.blue, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Focus Area: ${req.fieldOfInterest}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${req.message}"',
                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.35),
                  ),
                ],
              ),
            ),

            if (req.alumniResponseNote != null) ...[
              const SizedBox(height: 8),
              Text(
                'Mentor Note: ${req.alumniResponseNote}',
                style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.timeAgo(req.createdAt),
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),

                if (isAlumni && isPending) ...[
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          ref.read(mentorshipListProvider.notifier).respondToRequest(
                                requestId: req.id,
                                accept: false,
                              );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(80, 36),
                        ),
                        child: const Text('Decline'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          ref.read(mentorshipListProvider.notifier).respondToRequest(
                                requestId: req.id,
                                accept: true,
                                responseNote: 'Mentorship accepted! Let\'s connect.',
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Accepted mentorship for ${req.studentName}!')),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.success,
                          minimumSize: const Size(90, 36),
                        ),
                        child: const Text('Accept'),
                      ),
                    ],
                  ),
                ] else if (isAccepted && currentUser != null) ...[
                  FilledButton.icon(
                    onPressed: () {
                      final authRepo = ref.read(authRepositoryProvider);
                      final otherUserId = isAlumni ? req.studentId : req.alumniId;
                      final otherUser = authRepo.allUsers.firstWhere(
                        (u) => u.id == otherUserId,
                        orElse: () => currentUser,
                      );
                      final chatRepo = ref.read(chatRepositoryProvider);
                      final conv = chatRepo.getOrCreateDirectChat(currentUser, otherUser);
                      context.push('/chat/${conv.id}');
                    },
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('Open Mentorship Chat', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.blue, minimumSize: const Size(140, 36)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
