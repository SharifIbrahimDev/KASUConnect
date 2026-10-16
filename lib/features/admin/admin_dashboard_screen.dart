import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../home/widgets/demo_role_switcher.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final stats = adminRepo.getAdminStats();
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Command Center'),
        actions: [
          ActionChip(
            avatar: const Icon(Icons.shield, size: 16, color: Color(0xFF7C3AED)),
            label: const Text('Admin Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => DemoRoleSwitcherSheet.show(context),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Greeting Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.5), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        AppAssets.kasuLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.security, color: Color(0xFF7C3AED), size: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.fullName ?? 'KASU Administrator',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Student Affairs & Career Directorate',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Owner / Moderator Access',
                            style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Urgent Attention Counters
            const Text(
              'Urgent Queues',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pending IDs',
                    count: stats['pendingVerifications'] ?? 0,
                    subtitle: 'Matric & Alumni IDs',
                    color: AppColors.warning,
                    icon: Icons.badge_outlined,
                    onTap: () => context.push('/admin/verification-queue'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Job Scams',
                    count: stats['pendingJobs'] ?? 0,
                    subtitle: 'Awaiting Vetting',
                    color: AppColors.error,
                    icon: Icons.shield_outlined,
                    onTap: () => context.push('/admin/job-approvals'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Active Jobs',
                    count: stats['activeJobs'] ?? 0,
                    subtitle: 'Verified Postings',
                    color: AppColors.blue,
                    icon: Icons.work_outline,
                    onTap: () => context.push('/jobs'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'User Reports',
                    count: stats['pendingReports'] ?? 0,
                    subtitle: 'Flagged Content',
                    color: const Color(0xFF7C3AED),
                    icon: Icons.flag_outlined,
                    onTap: () => context.push('/admin/reports'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Administrative Tools List
            const Text(
              'Management Modules',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildToolTile(
              context: context,
              icon: Icons.verified_user_outlined,
              title: 'Matric & Alumni ID Verification Queue',
              subtitle: 'Check student matric numbers & alumni credentials to prevent fake profiles.',
              badgeText: '${stats['pendingVerifications']} Pending',
              badgeColor: AppColors.warning,
              onTap: () => context.push('/admin/verification-queue'),
            ),
            const SizedBox(height: 10),

            _buildToolTile(
              context: context,
              icon: Icons.shield_outlined,
              title: 'Job Scam Protection & Moderation',
              subtitle: 'Inspect employer postings to ensure no fake jobs or registration fee scams.',
              badgeText: '${stats['pendingJobs']} Review',
              badgeColor: AppColors.error,
              onTap: () => context.push('/admin/job-approvals'),
            ),
            const SizedBox(height: 10),

            _buildToolTile(
              context: context,
              icon: Icons.person_off_outlined,
              title: 'User Moderation & Blocking',
              subtitle: 'Search all users, review behaviors, and block rude or abusive accounts.',
              onTap: () => context.push('/admin/user-moderation'),
            ),
            const SizedBox(height: 10),

            _buildToolTile(
              context: context,
              icon: Icons.flag_outlined,
              title: 'Community Reports & Scam Complaints',
              subtitle: 'Review student and alumni feedback on suspicious activity.',
              badgeText: '${stats['pendingReports']} New',
              badgeColor: const Color(0xFF7C3AED),
              onTap: () => context.push('/admin/reports'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.blue, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.blue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor ?? AppColors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
