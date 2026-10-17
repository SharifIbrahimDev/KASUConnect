import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/job_application_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/job_repository.dart';

class CvPreviewDialog extends ConsumerWidget {
  final JobApplicationModel application;
  final bool isEmployer; // true if employer/admin viewing, false if student viewing self

  const CvPreviewDialog({
    super.key,
    required this.application,
    this.isEmployer = true,
  });

  static Future<void> show(
    BuildContext context, {
    required JobApplicationModel application,
    bool isEmployer = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CvPreviewDialog(
        application: application,
        isEmployer: isEmployer,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Find student user model if available
    final student = authRepo.allUsers.firstWhere(
      (u) => u.id == application.applicantId,
      orElse: () => UserModel(
        id: application.applicantId,
        email: application.applicantEmail,
        fullName: application.applicantName,
        role: UserRole.student,
        faculty: 'Faculty of Science',
        department: application.applicantDepartment,
        level: application.applicantLevel ?? '400L',
        skills: const ['Problem Solving', 'Teamwork', 'Communication', 'Research'],
        bio: 'Dedicated KASU student with a passion for excellence and practical application of coursework in real-world industry settings.',
        createdAt: application.appliedAt,
      ),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 780),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF141923) : const Color(0xFFF9FAFC),
            appBar: AppBar(
              backgroundColor: isDark ? const Color(0xFF1C2230) : Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  const Icon(Icons.description, color: AppColors.green, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      application.cvFileName ?? 'Student_Resume.pdf',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Download PDF',
                  icon: const Icon(Icons.download_rounded, color: AppColors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Downloaded ${application.cvFileName ?? 'CV.pdf'} successfully')),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Official KASU CV Header Card
                  _buildHeaderCard(context, student),
                  const SizedBox(height: 16),

                  // Applied Role Banner
                  _buildApplicationContextBanner(context),
                  const SizedBox(height: 16),

                  // Candidate Cover Note
                  if (application.coverNote != null && application.coverNote!.isNotEmpty) ...[
                    _buildSectionCard(
                      context,
                      title: 'Candidate Cover Statement',
                      icon: Icons.format_quote_rounded,
                      iconColor: AppColors.blue,
                      child: Text(
                        '“${application.coverNote}”',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Skills & Competencies
                  _buildSectionCard(
                    context,
                    title: 'Core Skills & Competencies',
                    icon: Icons.stars_rounded,
                    iconColor: AppColors.accentGold,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: student.skills.isNotEmpty
                          ? student.skills.map((skill) => _buildSkillChip(skill)).toList()
                          : [
                              _buildSkillChip('Flutter & Dart'),
                              _buildSkillChip('Problem Solving'),
                              _buildSkillChip('Team Collaboration'),
                              _buildSkillChip('Research & Analysis'),
                            ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Academic History
                  _buildSectionCard(
                    context,
                    title: 'Education & Academic Record',
                    icon: Icons.school_rounded,
                    iconColor: AppColors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.account_balance_rounded, size: 18, color: AppColors.green),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kaduna State University (KASU)',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    '${student.department} • ${student.faculty}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Current Level: ${student.level ?? 'Student'} | Matric: ${student.matricNumber ?? 'KASU Verified'}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Relevant Projects & Leadership
                  _buildSectionCard(
                    context,
                    title: 'University Projects & Activities',
                    icon: Icons.emoji_events_rounded,
                    iconColor: Colors.deepPurple,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBulletPoint('KASU Final Year / Semester Capstone project in ${student.department}.'),
                        _buildBulletPoint('Active member of KASU Student Association and technical workshops.'),
                        _buildBulletPoint('Hands-on coursework in practical industry tools and modern workflows.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            bottomNavigationBar: isEmployer
                ? _buildEmployerActionBar(context, ref, currentUser, student)
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, UserModel student) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              student.fullName.isNotEmpty ? student.fullName[0] : 'S',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        student.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('KASU', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${student.department} • ${student.level ?? 'Student'}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        student.email,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationContextBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: AppColors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application for: ${application.jobTitle}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.blue),
                ),
                Text(
                  'Submitted ${DateFormatter.formatDate(application.appliedAt)} • Status: ${application.status.displayName}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2638) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2C354D) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: AppColors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.35)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployerActionBar(
    BuildContext context,
    WidgetRef ref,
    dynamic currentUser,
    UserModel student,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C2230) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? const Color(0xFF2C354D) : AppColors.border),
        ),
      ),
      child: Row(
        children: [
          if (currentUser != null) ...[
            OutlinedButton.icon(
              onPressed: () {
                final chatRepo = ref.read(chatRepositoryProvider);
                final conv = chatRepo.getOrCreateDirectChat(currentUser, student);
                Navigator.of(context).pop();
                context.push('/chat/${conv.id}');
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 16),
              label: const Text('Chat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                side: const BorderSide(color: AppColors.blue),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                ref.read(jobRepositoryProvider).updateApplicationStatus(
                      application.id,
                      ApplicationStatus.rejected,
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Marked application as "${ApplicationStatus.rejected.displayName}"'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: () {
                ref.read(jobRepositoryProvider).updateApplicationStatus(
                      application.id,
                      ApplicationStatus.accepted,
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Accepted ${application.applicantName}! Candidate notified.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
              child: const Text('Accept 🎉'),
            ),
          ),
        ],
      ),
    );
  }
}
