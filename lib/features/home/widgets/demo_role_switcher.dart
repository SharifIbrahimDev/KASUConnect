import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class DemoRoleSwitcherSheet extends ConsumerWidget {
  const DemoRoleSwitcherSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DemoRoleSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: AppColors.blue, size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Switch Demo Perspective',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Experience KASUConnect as different user roles',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRoleOption(
            context: context,
            ref: ref,
            title: 'Student View',
            subtitle: 'Fatima Bello • 400L Computer Science',
            description: 'Can post, chat, search peers by skills, apply for jobs, request mentors',
            role: UserRole.student,
            isSelected: currentUser?.role == UserRole.student,
            icon: Icons.school_rounded,
            badgeColor: AppColors.teal,
          ),
          const SizedBox(height: 12),
          _buildRoleOption(
            context: context,
            ref: ref,
            title: 'Alumni View (Verified Blue Tick)',
            subtitle: 'Engr. Aminu Garba • Class of 2018',
            description: 'Has verified blue badge, posts jobs, mentors students, accepts applications',
            role: UserRole.alumni,
            isSelected: currentUser?.role == UserRole.alumni,
            icon: Icons.verified_rounded,
            badgeColor: AppColors.blue,
          ),
          const SizedBox(height: 12),
          _buildRoleOption(
            context: context,
            ref: ref,
            title: 'Admin View (App Owner)',
            subtitle: 'Dr. Bello Umar • Student Affairs',
            description: 'Approves matric numbers, stops job scammers, blocks rude users',
            role: UserRole.admin,
            isSelected: currentUser?.role == UserRole.admin,
            icon: Icons.admin_panel_settings_rounded,
            badgeColor: const Color(0xFF7C3AED),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required String description,
    required UserRole role,
    required bool isSelected,
    required IconData icon,
    required Color badgeColor,
  }) {
    return InkWell(
      onTap: () {
        ref.read(currentUserProvider.notifier).switchDemoRole(role);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to $title'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? badgeColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? badgeColor.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: badgeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isSelected ? badgeColor : null,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle_rounded, color: badgeColor, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
