import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/mentorship_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../data/repositories/chat_repository.dart';
import '../feed/widgets/post_card.dart';
import 'mentorship_request_dialog.dart';

class AlumniHubScreen extends ConsumerStatefulWidget {
  const AlumniHubScreen({super.key});

  @override
  ConsumerState<AlumniHubScreen> createState() => _AlumniHubScreenState();
}

class _AlumniHubScreenState extends ConsumerState<AlumniHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDepartment = 'All Departments';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final mentorRepo = ref.watch(mentorshipRepositoryProvider);
    final allPosts = ref.watch(postsFeedProvider);

    final mentors = mentorRepo.getAvailableMentors(
      department: _selectedDepartment,
      search: _searchController.text.trim(),
    );

    final successStories = allPosts.where((p) => p.category == 'success_story').toList();
    final reunions = allPosts.where((p) => p.category == 'reunion').toList();

    // Check pending mentorship requests count for this user
    final allRequests = ref.watch(mentorshipListProvider);
    final pendingCount = currentUser?.isAlumni == true
        ? allRequests.where((r) => r.alumniId == currentUser!.id && r.status.name == 'pending').length
        : allRequests.where((r) => r.studentId == currentUser?.id).length;

    // Flatten all departments
    final allDepts = ['All Departments'];
    for (var facultyDepts in AppConstants.fallbackFaculties.values) {
      allDepts.addAll(facultyDepts);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni & Mentorship Hub'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => context.push('/mentorship-dashboard'),
                icon: const Icon(Icons.handshake_outlined),
                tooltip: 'Mentorship Dashboard',
              ),
              if (pendingCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$pendingCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.blue,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.blue,
          tabs: const [
            Tab(text: 'Mentors & Alumni', icon: Icon(Icons.people_outline, size: 20)),
            Tab(text: 'Success Stories', icon: Icon(Icons.auto_awesome, size: 20)),
            Tab(text: 'Reunions & Events', icon: Icon(Icons.event, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Mentors & Alumni Directory
          Column(
            children: [
              // Hero Alumni Banner
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.asset(
                        AppAssets.kasuAlumni,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.navy, AppColors.blue],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.black.withValues(alpha: 0.25),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.verified, color: AppColors.blue, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'KASU Alumni Network',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Verified Kaduna State University graduates mentoring the next generation',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search & Filter header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: const Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search alumni by name, role, company, or skills...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.blue),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: allDepts.contains(_selectedDepartment) ? _selectedDepartment : 'All Departments',
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Department',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  ],
                ),
              ),

              // Mentors List
              Expanded(
                child: mentors.isEmpty
                    ? const Center(
                        child: Text(
                          'No alumni mentors found with current filters',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: mentors.length,
                        itemBuilder: (context, index) {
                          final alumni = mentors[index];
                          return _buildMentorCard(alumni, currentUser, mentorRepo);
                        },
                      ),
              ),
            ],
          ),

          // 2. Success Stories Feed
          successStories.isEmpty
              ? const Center(
                  child: Text(
                    'No success stories posted yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: successStories.length,
                  itemBuilder: (context, index) {
                    final post = successStories[index];
                    return PostCard(post: post, onTap: () => context.push('/post/${post.id}'));
                  },
                ),

          // 3. Reunions & Events Feed
          reunions.isEmpty
              ? const Center(
                  child: Text(
                    'No reunion announcements posted yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: reunions.length,
                  itemBuilder: (context, index) {
                    final post = reunions[index];
                    return PostCard(post: post, onTap: () => context.push('/post/${post.id}'));
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(UserModel alumni, UserModel? currentUser, MentorshipRepository mentorRepo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasRequested = currentUser != null && mentorRepo.hasPendingOrActiveRequest(currentUser.id, alumni.id);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: alumni.avatarUrl != null ? NetworkImage(alumni.avatarUrl!) : null,
                  child: alumni.avatarUrl == null
                      ? Text(alumni.fullName[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
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
                              alumni.fullName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppColors.blue, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${alumni.jobTitle ?? 'Alumni'} • ${alumni.currentCompany ?? 'KASU Graduate'}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.blue),
                      ),
                      Text(
                        'Class of ${alumni.graduationYear ?? 'Alumni'} • ${alumni.department}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (alumni.mentorBio != null || alumni.bio != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.15)),
                ),
                child: Text(
                  alumni.mentorBio ?? alumni.bio!,
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
              ),
            ],

            if (alumni.skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: alumni.skills.take(4).map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 11)),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push('/profile/${alumni.id}'),
                  icon: const Icon(Icons.person_outline, size: 16),
                  label: const Text('Profile', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(80, 36)),
                ),
                const SizedBox(width: 8),
                if (currentUser?.isStudent == true) ...[
                  FilledButton.icon(
                    onPressed: hasRequested
                        ? () => context.push('/mentorship-dashboard')
                        : () => MentorshipRequestDialog.show(context, alumni),
                    icon: Icon(hasRequested ? Icons.check : Icons.handshake, size: 16),
                    label: Text(hasRequested ? 'Requested' : 'Request Mentorship', style: const TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      backgroundColor: hasRequested ? AppColors.success : AppColors.blue,
                      minimumSize: const Size(120, 36),
                    ),
                  ),
                ] else if (currentUser != null && currentUser.id != alumni.id) ...[
                  FilledButton.icon(
                    onPressed: () {
                      final chatRepo = ref.read(chatRepositoryProvider);
                      final conv = chatRepo.getOrCreateDirectChat(currentUser, alumni);
                      context.push('/chat/${conv.id}');
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text('Message', style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.blue, minimumSize: const Size(100, 36)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
