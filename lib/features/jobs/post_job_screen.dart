import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/job_repository.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Junior Flutter Developer Intern');
  final _companyController = TextEditingController();
  final _locationController = TextEditingController(text: 'Kaduna');
  final _salaryController = TextEditingController(text: '₦50,000 / month');
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();

  String _selectedJobType = 'internship';
  String _selectedArrangement = 'onsite';
  final List<String> _targetDepartments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user?.currentCompany != null) {
      _companyController.text = user!.currentCompany!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _submitJob() {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    ref.read(jobsListProvider.notifier).postJob(
          poster: user,
          title: _titleController.text.trim(),
          company: _companyController.text.trim(),
          location: _locationController.text.trim(),
          workArrangement: _selectedArrangement,
          jobType: _selectedJobType,
          description: _descriptionController.text.trim(),
          requirements: _requirementsController.text.trim(),
          salary: _salaryController.text.trim().isNotEmpty ? _salaryController.text.trim() : null,
          targetDepartments: _targetDepartments,
        );

    final isImmediate = user.isAdmin;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isImmediate
            ? 'Opportunity published immediately by Admin!'
            : 'Opportunity submitted! It will appear on the job board once approved by KASU Admin.'),
        backgroundColor: AppColors.success,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Opportunity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Scam protection banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.blue, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'To protect KASU students from fraudulent jobs or registration fee scams, all alumni postings are vetted by KASU Administration before publication.',
                        style: TextStyle(fontSize: 12, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job / Internship Title',
                  hintText: 'e.g. Intern needed at Kaduna',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (v) => Validators.validateRequired(v, 'Job Title'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company / Organization Name',
                  hintText: 'e.g. Kaduna Tech Labs',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (v) => Validators.validateRequired(v, 'Company Name'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. Barnawa, Kaduna',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => Validators.validateRequired(v, 'Location'),
              ),
              const SizedBox(height: 16),

              // Job Type & Arrangement dropdowns
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedJobType,
                      decoration: const InputDecoration(labelText: 'Job Type'),
                      items: AppConstants.jobTypes.entries.map((e) {
                        return DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedJobType = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedArrangement,
                      decoration: const InputDecoration(labelText: 'Work Mode'),
                      items: AppConstants.workArrangements.entries.map((e) {
                        return DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedArrangement = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary / Stipend (Optional)',
                  hintText: 'e.g. ₦60,000 / month',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'Detail the role, tasks, learning outcomes, and day-to-day responsibilities...',
                ),
                validator: (v) => Validators.validateRequired(v, 'Description'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _requirementsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Requirements & Qualifications',
                  hintText: 'e.g. KASU student in 300L/400L, knowledge of Flutter, good communication...',
                ),
                validator: (v) => Validators.validateRequired(v, 'Requirements'),
              ),
              const SizedBox(height: 28),

              FilledButton(
                onPressed: _isLoading ? null : _submitJob,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        user?.isAdmin == true ? 'Publish Job (Admin)' : 'Submit Opportunity for Review',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
