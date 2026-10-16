import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';

class PendingVerificationScreen extends ConsumerWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Verification'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 48,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification In Progress',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Hello ${user?.fullName ?? 'KASU Member'},\n'
                'To maintain a safe, scam-free community, the KASU administration checks every student matric number and alumni ID before activating full privileges.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Account Type', user?.role.displayName ?? 'Student'),
                    const Divider(height: 20),
                    if (user?.isStudent ?? false)
                      _buildInfoRow('Matric Number', user?.matricNumber ?? 'KASU/20/...')
                    else
                      _buildInfoRow('Alumni ID', user?.alumniId ?? 'ALM-...'),
                    const Divider(height: 20),
                    _buildInfoRow('Department', user?.department ?? 'Computer Science'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore KASUConnect (Preview Mode)'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  ref.read(currentUserProvider.notifier).signOut();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
