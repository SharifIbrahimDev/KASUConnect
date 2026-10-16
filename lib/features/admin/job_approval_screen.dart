import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/job_model.dart';
import '../../data/repositories/admin_repository.dart';

class JobApprovalScreen extends ConsumerStatefulWidget {
  const JobApprovalScreen({super.key});

  @override
  ConsumerState<JobApprovalScreen> createState() => _JobApprovalScreenState();
}

class _JobApprovalScreenState extends ConsumerState<JobApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final pendingJobs = adminRepo.getPendingJobs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Scam & Moderation Queue'),
      ),
      body: pendingJobs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_outlined, size: 64, color: AppColors.success.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No pending jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text('All posted opportunities have been reviewed.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingJobs.length,
              itemBuilder: (context, index) {
                final job = pendingJobs[index];
                return _buildJobModerationCard(job, adminRepo);
              },
            ),
    );
  }

  Widget _buildJobModerationCard(JobModel job, AdminRepository adminRepo) {
    final isLikelyScam = job.description.toLowerCase().contains('fee') ||
        job.description.toLowerCase().contains('pay') ||
        job.requirements.toLowerCase().contains('deposit');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLikelyScam ? AppColors.error : AppColors.border,
          width: isLikelyScam ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLikelyScam) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Automated Scam Warning: Mentions registration deposit or payment demands.',
                        style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business_center, color: AppColors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${job.company} • ${job.location}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Pending Review', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Posted by: ${job.posterName} (${job.isAlumniPoster ? 'Verified Alumni' : 'External Employer'})',
              style: const TextStyle(fontSize: 12, color: AppColors.blue, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Job Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(job.description, style: const TextStyle(fontSize: 13, height: 1.35)),
                  const SizedBox(height: 8),
                  const Text('Requirements:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(job.requirements, style: const TextStyle(fontSize: 13, height: 1.35)),
                  if (job.salary != null) ...[
                    const SizedBox(height: 8),
                    Text('Compensation: ${job.salary}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      adminRepo.rejectJob(job.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Job "${job.title}" rejected and blocked from students.')),
                      );
                    },
                    icon: const Icon(Icons.block, size: 16),
                    label: const Text('Reject Scam'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      adminRepo.approveJob(job.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Job "${job.title}" approved and published to all students!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve & Publish'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
