import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

class RoleBadge extends StatelessWidget {
  final UserRole role;
  final bool isVerified;
  final String? level;
  final bool showLabel;
  final double iconSize;

  const RoleBadge({
    super.key,
    required this.role,
    this.isVerified = false,
    this.level,
    this.showLabel = true,
    this.iconSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.alumni) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: AppColors.blue,
            size: iconSize,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
              ),
              child: const Text(
                'Alumni',
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      );
    } else if (role == UserRole.admin) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_rounded, color: const Color(0xFF7C3AED), size: iconSize),
            if (showLabel) ...[
              const SizedBox(width: 4),
              const Text(
                'Admin',
                style: TextStyle(
                  color: Color(0xFF7C3AED),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      // Student
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.teal.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.25)),
        ),
        child: Text(
          level != null ? 'Student • $level' : 'Student',
          style: const TextStyle(
            color: Color(0xFF0F766E),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
  }
}

class VerificationStatusBadge extends StatelessWidget {
  final VerificationStatus status;

  const VerificationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case VerificationStatus.verified:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 14),
              SizedBox(width: 4),
              Text(
                'Verified KASU',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case VerificationStatus.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_top_rounded, color: AppColors.warning, size: 14),
              SizedBox(width: 4),
              Text(
                'Pending Verification',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case VerificationStatus.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_rounded, color: AppColors.error, size: 14),
              SizedBox(width: 4),
              Text(
                'Unverified',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
    }
  }
}
