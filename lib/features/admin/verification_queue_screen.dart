import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/admin_repository.dart';

class VerificationQueueScreen extends ConsumerStatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  ConsumerState<VerificationQueueScreen> createState() => _VerificationQueueScreenState();
}

class _VerificationQueueScreenState extends ConsumerState<VerificationQueueScreen> {
  @override
  Widget build(BuildContext context) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final pendingUsers = adminRepo.getPendingVerificationUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ID Verification Queue'),
      ),
      body: pendingUsers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user, size: 64, color: AppColors.success.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  const Text('No matric numbers or alumni IDs are waiting for verification.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingUsers.length,
              itemBuilder: (context, index) {
                final user = pendingUsers[index];
                return _buildVerificationCard(user, adminRepo);
              },
            ),
    );
  }

  Widget _buildVerificationCard(UserModel user, AdminRepository adminRepo) {
    final isStudent = user.isStudent;

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
                  radius: 24,
                  backgroundColor: isStudent ? AppColors.teal.withValues(alpha: 0.15) : AppColors.blue.withValues(alpha: 0.15),
                  child: Icon(isStudent ? Icons.school : Icons.verified, color: isStudent ? AppColors.teal : AppColors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isStudent ? 'Student Pending' : 'Alumni Pending',
                    style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Credentials info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (isStudent) ...[
                    _buildInfoRow('Matriculation No.', user.matricNumber ?? 'KASU/22/...', isHighlight: true),
                    const Divider(height: 12),
                    _buildInfoRow('Department & Level', '${user.department} • ${user.level ?? 'Student'}'),
                  ] else ...[
                    _buildInfoRow('Alumni / Cert. ID', user.alumniId ?? 'ALM-...', isHighlight: true),
                    const Divider(height: 12),
                    _buildInfoRow('Graduation Year', 'Class of ${user.graduationYear ?? 'Alumni'}'),
                    if (user.currentCompany != null) ...[
                      const Divider(height: 12),
                      _buildInfoRow('Company', '${user.jobTitle} at ${user.currentCompany}'),
                    ],
                  ],
                  const Divider(height: 12),
                  _buildInfoRow('Submitted', DateFormatter.timeAgo(user.createdAt)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      adminRepo.rejectUserVerification(user.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Rejected verification for ${user.fullName}')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Reject ID'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      adminRepo.approveUserVerification(user.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Approved ${user.fullName}! Blue badge / matric verified.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                    child: const Text('Approve & Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppColors.blue : null,
          ),
        ),
      ],
    );
  }
}
