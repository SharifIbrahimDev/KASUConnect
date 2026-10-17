import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/job_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/job_repository.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();
  String _selectedJobType = 'all';
  String _selectedArrangement = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final jobRepo = ref.watch(jobRepositoryProvider);

    final approvedJobs = jobRepo.getApprovedJobs(
      query: _searchController.text.trim(),
      jobType: _selectedJobType,
      arrangement: _selectedArrangement,
    );

    final userApplications = currentUser != null ? jobRepo.getApplicationsForUser(currentUser.id) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('KASU Career & Jobs'),
        actions: [
          if (currentUser?.isStudent == true) ...[
            TextButton.icon(
              onPressed: () => context.push('/my-applications'),
              icon: const Icon(Icons.assignment_turned_in_outlined, size: 18),
              label: Text(
                'My Apps (${userApplications.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
          if (currentUser?.isAlumni == true || currentUser?.isAdmin == true) ...[
            IconButton(
              onPressed: () => context.push('/post-job'),
              icon: const Icon(Icons.add_business_outlined),
              tooltip: 'Post Opportunity',
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
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
                    hintText: 'Search jobs, internships, companies in Kaduna...',
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
                const SizedBox(height: 10),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeChip('all', 'All Types'),
                      const SizedBox(width: 6),
                      _buildTypeChip('internship', 'Internships 💼'),
                      const SizedBox(width: 6),
                      _buildTypeChip('graduate_trainee', 'Graduate Trainee 🎓'),
                      const SizedBox(width: 6),
                      _buildTypeChip('full_time', 'Full-time 🏢'),
                      const SizedBox(width: 6),
                      _buildTypeChip('remote', 'Remote Only 🌐'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Jobs List
          Expanded(
            child: approvedJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off_outlined, size: 56, color: Colors.grey.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text(
                          'No opportunities found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Check back soon or try clearing filters.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        if (currentUser?.isAlumni == true) ...[
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => context.push('/post-job'),
                            icon: const Icon(Icons.add),
                            label: const Text('Post an Opportunity for KASU Students'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: approvedJobs.length,
                    itemBuilder: (context, index) {
                      final job = approvedJobs[index];
                      final hasApplied = currentUser != null && jobRepo.hasUserApplied(job.id, currentUser.id);
                      final myApp = hasApplied
                          ? userApplications.firstWhere((a) => a.jobId == job.id)
                          : null;

                      return _buildJobCard(job, hasApplied, myApp);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: (currentUser?.isAlumni == true || currentUser?.isAdmin == true)
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/post-job'),
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Post a Job'),
            )
          : null,
    );
  }

  Widget _buildTypeChip(String key, String label) {
    final isSelected = _selectedJobType == key;
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      selectedColor: AppColors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (val) {
        setState(() => _selectedJobType = key);
      },
    );
  }

  Widget _buildJobCard(JobModel job, bool hasApplied, dynamic myApp) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.push('/job/${job.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        job.company.isNotEmpty ? job.company[0] : 'K',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              job.company,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                            if (job.isAlumniPoster) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 12, color: AppColors.blue),
                                    SizedBox(width: 2),
                                    Text('Alumni Poster', style: TextStyle(color: AppColors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Badges: Location, Work Arrangement, Job Type, Salary
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildTag(Icons.location_on_outlined, job.location),
                  _buildTag(Icons.business_outlined, AppConstants.workArrangements[job.workArrangement] ?? job.workArrangement),
                  _buildTag(Icons.work_outline, AppConstants.jobTypes[job.jobType] ?? job.jobType),
                  if (job.salary != null)
                    _buildTag(Icons.payments_outlined, job.salary!, color: AppColors.success),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                job.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),

              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted ${DateFormatter.timeAgo(job.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  if (hasApplied && myApp != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Status: ${myApp.status.displayName}',
                        style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] else ...[
                    FilledButton(
                      onPressed: () => context.push('/job/${job.id}'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.blue,
                        minimumSize: const Size(90, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: const Text('View & Apply', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, {Color? color}) {
    final c = color ?? AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
