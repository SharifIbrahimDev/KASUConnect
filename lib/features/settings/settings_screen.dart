import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../home/widgets/role_badge.dart';
import '../home/widgets/demo_role_switcher.dart';
import 'theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile summary card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.blue.withValues(alpha: 0.15),
                    backgroundImage: currentUser?.avatarUrl != null
                        ? NetworkImage(currentUser!.avatarUrl!)
                        : null,
                    child: currentUser?.avatarUrl == null
                        ? Text(
                            currentUser?.fullName.isNotEmpty == true ? currentUser!.fullName[0] : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.blue),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                currentUser?.fullName ?? 'KASU User',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (currentUser?.isAlumni == true) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: AppColors.blue, size: 16),
                            ],
                          ],
                        ),
                        Text(
                          currentUser?.subtitleInfo ?? '',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        if (currentUser != null)
                          VerificationStatusBadge(status: currentUser.verificationStatus),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/edit-profile'),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Role Switcher Tile (Key for pair-programming and previewing all 3 role perspectives)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.blue.withValues(alpha: 0.3)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.swap_horiz_rounded, color: AppColors.blue),
              ),
              title: const Text('Switch Demo Perspective', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Currently viewing as ${currentUser?.role.displayName ?? 'Student'}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => DemoRoleSwitcherSheet.show(context),
            ),
          ),

          const SizedBox(height: 16),

          const Text('Preferences & Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.blue),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Adjust app theme brightness'),
                  value: isDark,
                  onChanged: (_) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: AppColors.blue),
                  title: const Text('Job & Mentorship Alerts'),
                  subtitle: const Text('Instant push notifications for new jobs & mentorship replies'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Push notifications are enabled!')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('About & Security', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        AppAssets.kasuLogo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.school, color: AppColors.blue, size: 20),
                      ),
                    ),
                  ),
                  title: const Text('About KASUConnect'),
                  subtitle: const Text('Version 1.0.0+1 • Kaduna State University'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: AppColors.blue),
                  title: const Text('Verification & Anti-Scam Rules'),
                  subtitle: const Text('Learn how KASUConnect protects students from fake jobs'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Anti-Scam & Safety Policy'),
                        content: const Text(
                          '1. All students must register with valid KASU matric numbers.\n\n'
                          '2. All alumni receive verified Blue Ticks only upon admin credential validation.\n\n'
                          '3. Every job post is vetted by KASU Administration before student publication.\n\n'
                          '4. Any user demanding payments or registration fees is immediately banned.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                        actions: [
                          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it')),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sign Out Button
          FilledButton.icon(
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
