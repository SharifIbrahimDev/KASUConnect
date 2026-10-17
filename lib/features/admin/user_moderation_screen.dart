import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/admin_repository.dart';
import '../home/widgets/role_badge.dart';

class UserModerationScreen extends ConsumerStatefulWidget {
  const UserModerationScreen({super.key});

  @override
  ConsumerState<UserModerationScreen> createState() => _UserModerationScreenState();
}

class _UserModerationScreenState extends ConsumerState<UserModerationScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final query = _searchController.text.toLowerCase().trim();

    final allUsers = adminRepo.getAllUsers().where((u) {
      if (query.isEmpty) return true;
      return u.fullName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.department.toLowerCase().contains(query) ||
          (u.matricNumber?.toLowerCase().contains(query) ?? false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Moderation & Safety'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, matric no, or email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.blue),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: allUsers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = allUsers[index];
                final isBlocked = user.isBlocked;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? Text(user.fullName[0]) : null,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: isBlocked ? TextDecoration.lineThrough : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      RoleBadge(role: user.role, isVerified: user.isVerified, showLabel: false),
                    ],
                  ),
                  subtitle: Text(
                    '${user.subtitleInfo} • ${user.email}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: OutlinedButton(
                    onPressed: () {
                      adminRepo.toggleBlockUser(user.id);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBlocked
                              ? 'Unblocked ${user.fullName}'
                              : 'Blocked ${user.fullName} from app access'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isBlocked ? AppColors.success : AppColors.error,
                      side: BorderSide(color: isBlocked ? AppColors.success : AppColors.error),
                      minimumSize: const Size(80, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text(isBlocked ? 'Unblock' : 'Block', style: const TextStyle(fontSize: 11)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
