import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/job_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/job_repository.dart';

class ApplyJobDialog extends ConsumerStatefulWidget {
  final JobModel job;

  const ApplyJobDialog({super.key, required this.job});

  static Future<void> show(BuildContext context, JobModel job) {
    return showDialog(
      context: context,
      builder: (ctx) => ApplyJobDialog(job: job),
    );
  }

  @override
  ConsumerState<ApplyJobDialog> createState() => _ApplyJobDialogState();
}

class _ApplyJobDialogState extends ConsumerState<ApplyJobDialog> {
  final _coverNoteController = TextEditingController();
  late String _selectedCvFileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _selectedCvFileName = user?.cvFileName ?? '${user?.fullName.replaceAll(' ', '_') ?? 'KASU'}_CV_2026.pdf';
  }

  @override
  void dispose() {
    _coverNoteController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    ref.read(jobRepositoryProvider).applyForJob(
          job: widget.job,
          applicant: user,
          coverNote: _coverNoteController.text.trim().isNotEmpty ? _coverNoteController.text.trim() : null,
          cvFileName: _selectedCvFileName,
        );

    // Refresh jobs list
    ref.read(jobsListProvider.notifier).refresh();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Application submitted for ${widget.job.title}! Track status in My Applications.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apply for Opportunity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            '${widget.job.title} • ${widget.job.company}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: AppColors.blue, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Student',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '${user?.department ?? 'KASU'} • ${user?.level ?? 'Student'}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // In-App CV attachment
            const Text('Curriculum Vitae (CV)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedCvFileName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCvFileName = '${user?.fullName.replaceAll(' ', '_')}_Updated_Resume.pdf';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Attached updated CV PDF')),
                      );
                    },
                    child: const Text('Change', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Cover note
            const Text('Cover Note / Message to Employer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _coverNoteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Briefly highlight why you are a great fit for this role...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitApplication,
          style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit Application'),
        ),
      ],
    );
  }
}
