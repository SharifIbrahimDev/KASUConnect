import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../home/widgets/role_badge.dart';

class PeerSearchScreen extends ConsumerStatefulWidget {
  const PeerSearchScreen({super.key});

  @override
  ConsumerState<PeerSearchScreen> createState() => _PeerSearchScreenState();
}

class _PeerSearchScreenState extends ConsumerState<PeerSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedDepartment = 'All Departments';
  String _selectedLevel = 'All Levels';
  String _selectedRole = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyQuickSearch(String query, {String? dept, String? level}) {
    setState(() {
      _searchController.text = query;
      if (dept != null) _selectedDepartment = dept;
      if (level != null) _selectedLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRepo = ref.watch(userRepositoryProvider);
    final currentUser = ref.watch(currentUserProvider);

    UserRole? roleFilter;
    if (_selectedRole == 'Students') roleFilter = UserRole.student;
    if (_selectedRole == 'Alumni') roleFilter = UserRole.alumni;

    final users = userRepo.searchUsers(
      keyword: _searchController.text.trim(),
      department: _selectedDepartment,
      level: _selectedLevel,
      role: roleFilter,
    );

    // Flatten all departments
    final allDepts = ['All Departments'];
    for (var facultyDepts in AppConstants.fallbackFaculties.values) {
      allDepts.addAll(facultyDepts);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Peers & Skills'),
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Graphic Designer, Flutter, Python...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.blue),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),

                // Quick Presets
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Quick:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text('Graphic Designer CS 400L', style: TextStyle(fontSize: 11)),
                        onPressed: () => _applyQuickSearch('Graphic Design', dept: 'Computer Science', level: '400L'),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('Flutter Developer', style: TextStyle(fontSize: 11)),
                        onPressed: () => _applyQuickSearch('Flutter', dept: 'All Departments', level: 'All Levels'),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('Mass Comm 300L Writer', style: TextStyle(fontSize: 11)),
                        onPressed: () => _applyQuickSearch('Writing', dept: 'Mass Communication', level: '300L'),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        label: const Text('Alumni Mentors', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _selectedRole = 'Alumni';
                            _searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Filters Row (Dept, Level, Role)
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: allDepts.contains(_selectedDepartment) ? _selectedDepartment : 'All Departments',
                        isExpanded: true,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          isDense: true,
                        ),
                        items: allDepts.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDepartment = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          isDense: true,
                        ),
                        items: ['All Levels', ...AppConstants.levels].map((l) {
                          return DropdownMenuItem(
                            value: l,
                            child: Text(l, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedLevel = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          isDense: true,
                        ),
                        items: ['All', 'Students', 'Alumni'].map((r) {
                          return DropdownMenuItem(
                            value: r,
                            child: Text(r, style: const TextStyle(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedRole = val);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Results
          Expanded(
            child: users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 56, color: Colors.grey.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'No KASU members found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try broadening your skill keywords or resetting filters',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _selectedDepartment = 'All Departments';
                              _selectedLevel = 'All Levels';
                              _selectedRole = 'All';
                            });
                          },
                          child: const Text('Reset All Filters'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(user, currentUser);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, UserModel? currentUser) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/profile/${user.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : 'U',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue, fontSize: 18),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.fullName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            RoleBadge(
                              role: user.role,
                              isVerified: user.isVerified,
                              level: user.level,
                              showLabel: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.subtitleInfo,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        if (user.bio != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            user.bio!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, height: 1.3),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Skills Chips
              if (user.skills.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: user.skills.take(4).map((skill) {
                    final isMatched = _searchController.text.isNotEmpty &&
                        skill.toLowerCase().contains(_searchController.text.toLowerCase().trim());
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isMatched
                            ? AppColors.blue.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isMatched ? AppColors.blue : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isMatched ? FontWeight.bold : FontWeight.w500,
                          color: isMatched ? AppColors.blue : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push('/profile/${user.id}'),
                    icon: const Icon(Icons.person_outline, size: 16),
                    label: const Text('View Profile', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(100, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: currentUser == null || currentUser.id == user.id
                        ? null
                        : () {
                            final chatRepo = ref.read(chatRepositoryProvider);
                            final conv = chatRepo.getOrCreateDirectChat(currentUser, user);
                            context.push('/chat/${conv.id}');
                          },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Message', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      minimumSize: const Size(100, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
