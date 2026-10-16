import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/admin_repository.dart';

class ReportModerationScreen extends ConsumerStatefulWidget {
  const ReportModerationScreen({super.key});

  @override
  ConsumerState<ReportModerationScreen> createState() => _ReportModerationScreenState();
}

class _ReportModerationScreenState extends ConsumerState<ReportModerationScreen> {
  @override
  Widget build(BuildContext context) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final reports = adminRepo.reports;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Reports & Flags'),
      ),
      body: reports.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 64, color: AppColors.success.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No pending reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text('The KASU community is safe and peaceful.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final rep = reports[index];
                return _buildReportCard(rep, adminRepo);
              },
            ),
    );
  }

  Widget _buildReportCard(ReportModel rep, AdminRepository adminRepo) {
    final isResolved = rep.status == 'resolved';

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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.flag, color: AppColors.error, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reported ${rep.targetType.toUpperCase()}: ${rep.targetTitle}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Reason: ${rep.reason}',
                        style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isResolved ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rep.status.toUpperCase(),
                    style: TextStyle(
                      color: isResolved ? AppColors.success : AppColors.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            if (rep.details != null && rep.details!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '"${rep.details}"',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reported by ${rep.reporterName} • ${DateFormatter.timeAgo(rep.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                if (!isResolved)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          adminRepo.resolveReport(rep.id, 'dismissed');
                          setState(() {});
                        },
                        child: const Text('Dismiss', style: TextStyle(fontSize: 12)),
                      ),
                      FilledButton(
                        onPressed: () {
                          adminRepo.resolveReport(rep.id, 'resolved');
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Report marked as Resolved!')),
                          );
                        },
                        style: FilledButton.styleFrom(backgroundColor: AppColors.success, minimumSize: const Size(80, 32)),
                        child: const Text('Resolve', style: TextStyle(fontSize: 12)),
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
