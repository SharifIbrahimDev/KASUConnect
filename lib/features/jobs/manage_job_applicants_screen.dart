import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/job_application_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/repositories/chat_repository.dart';

class ManageJobApplicantsScreen extends ConsumerStatefulWidget {
  final String jobId;

  const ManageJobApplicantsScreen({super.key, required this.jobId});

  @override
  ConsumerState<ManageJobApplicantsScreen> createState() => _ManageJobApplicantsScreenState();
}

class _ManageJobApplicantsScreenState extends ConsumerState<ManageJobApplicantsScreen> {
  @override
  Widget build(BuildContext context) {
    final jobRepo = ref.watch(jobRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider);
    final job = jobRepo.getJobById(widget.jobId);
    final applicants = jobRepo.getApplicationsForJob(widget.jobId);

    return Scaffold(
      appBar: AppBar(
        title: Text(job != null ? 'Applicants: ${job.title}' : 'Applicants'),
      ),
      body: applicants.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 56, color: Colors.grey.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text('No students have applied yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Student applications with their CVs will appear here.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applicants.length,
              itemBuilder: (context, index) {
                final app = applicants[index];
                return _buildApplicantCard(app, currentUser);
              },
            ),
    );
  }

  Widget _buildApplicantCard(JobApplicationModel app, dynamic currentUser) {
    Color statusColor;
    switch (app.status) {
      case ApplicationStatus.accepted:
        statusColor = AppColors.success;
        break;
      case ApplicationStatus.rejected:
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
                  backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                  child: Text(
                    app.applicantName.isNotEmpty ? app.applicantName[0] : 'S',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.applicantName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${app.applicantDepartment} • ${app.applicantLevel ?? 'Student'}',
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
                    app.status.displayName,
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

            // CV attachment chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      app.cvFileName ?? 'Applicant_Resume.pdf',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text('Preview CV', style: TextStyle(fontSize: 12, color: AppColors.blue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            if (app.coverNote != null) ...[
              const SizedBox(height: 10),
              Text(
                'Cover Note: "${app.coverNote}"',
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, height: 1.35),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied ${DateFormatter.timeAgo(app.appliedAt)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    if (currentUser != null)
                      IconButton(
                        onPressed: () {
                          final authRepo = ref.read(authRepositoryProvider);
                          final student = authRepo.allUsers.firstWhere(
                            (u) => u.id == app.applicantId,
                            orElse: () => currentUser,
                          );
                          final chatRepo = ref.read(chatRepositoryProvider);
                          final conv = chatRepo.getOrCreateDirectChat(currentUser, student);
                          context.push('/chat/${conv.id}');
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        tooltip: 'Message Applicant',
                      ),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(jobRepositoryProvider).updateApplicationStatus(app.id, ApplicationStatus.rejected);
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        minimumSize: const Size(70, 36),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        ref.read(jobRepositoryProvider).updateApplicationStatus(app.id, ApplicationStatus.accepted);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Accepted ${app.applicantName}! Notification sent.')),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size(80, 36),
                      ),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
