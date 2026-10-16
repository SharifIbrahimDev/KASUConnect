import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/job_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/repositories/admin_repository.dart';
import 'apply_job_dialog.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;

  const JobDetailScreen({super.key, required this.jobId});

  void _showReportDialog(BuildContext context, WidgetRef ref, JobModel job, UserModel reporter) {
    String selectedReason = 'Fake job / fraud';
    final detailsController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Report Job Opportunity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Protect fellow KASU students. If this employer is demanding money, registration fees, or posting fraudulent info, report it immediately.',
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
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(labelText: 'Details / Evidence'),
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
                      targetType: 'job',
                      targetId: job.id,
                      targetTitle: '${job.title} at ${job.company}',
                      reason: selectedReason,
                      details: detailsController.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted to KASU Admin!')),
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
    final jobRepo = ref.watch(jobRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider);
    final job = jobRepo.getJobById(jobId);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Opportunity Details')),
        body: const Center(child: Text('Job not found or closed')),
      );
    }

    final hasApplied = currentUser != null && jobRepo.hasUserApplied(job.id, currentUser.id);
    final myApp = hasApplied
        ? jobRepo.getApplicationsForUser(currentUser.id).firstWhere((a) => a.jobId == job.id)
        : null;

    final isOwnerOrAdmin = currentUser != null &&
        (currentUser.id == job.posterId || currentUser.isAdmin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
        actions: [
          if (currentUser != null && !isOwnerOrAdmin)
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: AppColors.error),
              tooltip: 'Report Suspicious Job',
              onPressed: () => _showReportDialog(context, ref, job, currentUser),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company and Job Title Card
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      job.company.isNotEmpty ? job.company[0] : 'K',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.company,
                        style: const TextStyle(fontSize: 14, color: AppColors.blue, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        job.location,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Key Attributes Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildAttrRow('Job Type', AppConstants.jobTypes[job.jobType] ?? job.jobType, Icons.work_outline),
                  const Divider(height: 16),
                  _buildAttrRow('Work Arrangement', AppConstants.workArrangements[job.workArrangement] ?? job.workArrangement, Icons.business_outlined),
                  const Divider(height: 16),
                  _buildAttrRow('Compensation', job.salary ?? 'Negotiable / Stipend', Icons.payments_outlined),
                  const Divider(height: 16),
                  _buildAttrRow('Target Depts', job.targetDepartments.isEmpty ? 'Open to All KASU Depts' : job.targetDepartments.join(', '), Icons.school_outlined),
                  if (job.deadline != null) ...[
                    const Divider(height: 16),
                    _buildAttrRow('Deadline', DateFormatter.shortDate(job.deadline), Icons.calendar_today_outlined),
                  ],
                ],
              ),
            ),

            // Alumni poster verification tag
            if (job.isAlumniPoster) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppColors.blue, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alumni Verified Opportunity',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.blue),
                          ),
                          Text(
                            'Posted by ${job.posterName} (KASU Graduate)',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Description
            const Text('Job Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(job.description, style: const TextStyle(fontSize: 14, height: 1.5)),

            const SizedBox(height: 20),

            // Requirements
            const Text('Requirements & Qualifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(job.requirements, style: const TextStyle(fontSize: 14, height: 1.5)),

            const SizedBox(height: 32),

            // Bottom CTA
            if (hasApplied && myApp != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Application Submitted',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Status: ${myApp.status.displayName}',
                      style: const TextStyle(fontSize: 14, color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applied on ${DateFormatter.shortDate(myApp.appliedAt)} with ${myApp.cvFileName ?? 'CV'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ] else if (isOwnerOrAdmin) ...[
              FilledButton.icon(
                onPressed: () => context.push('/manage-job-applicants/${job.id}'),
                icon: const Icon(Icons.people),
                label: Text('Manage Applicants (${job.applicationsCount})'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ] else ...[
              FilledButton.icon(
                onPressed: () => ApplyJobDialog.show(context, job),
                icon: const Icon(Icons.upload_file),
                label: const Text('Apply with In-App CV'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildAttrRow(String label, String value, IconData icon) {
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
