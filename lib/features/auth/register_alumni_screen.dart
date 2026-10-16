import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterAlumniScreen extends ConsumerStatefulWidget {
  const RegisterAlumniScreen({super.key});

  @override
  ConsumerState<RegisterAlumniScreen> createState() => _RegisterAlumniScreenState();
}

class _RegisterAlumniScreenState extends ConsumerState<RegisterAlumniScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _alumniIdController = TextEditingController();
  final _gradYearController = TextEditingController(text: '2020');
  final _passwordController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _mentorBioController = TextEditingController();
  final _skillInputController = TextEditingController();

  String _selectedFaculty = AppConstants.fallbackFaculties.keys.first;
  late String _selectedDepartment;
  bool _isMentor = true;
  final List<String> _skills = ['Software Architecture', 'Career Coaching', 'Leadership'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDepartment = AppConstants.fallbackFaculties[_selectedFaculty]!.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _alumniIdController.dispose();
    _gradYearController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _mentorBioController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillInputController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(currentUserProvider.notifier).registerAlumni(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            alumniId: _alumniIdController.text.trim().toUpperCase(),
            graduationYear: _gradYearController.text.trim(),
            faculty: _selectedFaculty,
            department: _selectedDepartment,
            currentCompany: _companyController.text.trim(),
            jobTitle: _jobTitleController.text.trim(),
            skills: _skills,
            isMentor: _isMentor,
            mentorBio: _mentorBioController.text.trim(),
          );

      if (mounted) {
        context.go('/pending-verification');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final depts = AppConstants.fallbackFaculties[_selectedFaculty] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // KASU Alumni Banner Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  AppAssets.kasuAlumni,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),

              // Blue tick banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: AppColors.blue, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Verified KASU Alumni receive the official Blue Tick badge, can post jobs, and mentor undergraduate students.',
                        style: TextStyle(fontSize: 12, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Engr. Aminu Garba',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => Validators.validateRequired(v, 'Full Name'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. aminu@company.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _alumniIdController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Alumni ID / Cert. No.',
                        hintText: 'e.g. ALM-2018-021',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: Validators.validateAlumniId,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _gradYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Grad Year',
                        hintText: '2020',
                      ),
                      validator: (v) => Validators.validateRequired(v, 'Year'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Create Password',
                  hintText: '••••••••',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: Validators.validatePassword,
              ),
              const SizedBox(height: 20),

              // Faculty Dropdown
              DropdownButtonFormField<String>(
                value: _selectedFaculty,
                decoration: const InputDecoration(
                  labelText: 'Faculty Graduated From',
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                isExpanded: true,
                items: AppConstants.fallbackFaculties.keys.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedFaculty = val;
                      _selectedDepartment =
                          AppConstants.fallbackFaculties[val]!.first;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Department',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                isExpanded: true,
                items: depts.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Text(d, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedDepartment = val);
                },
              ),
              const SizedBox(height: 20),

              // Career Info
              const Text(
                'Current Career / Workplace',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Current Company / Organization',
                  hintText: 'e.g. Kaduna Tech Labs / Stanbic IBTC',
                  prefixIcon: Icon(Icons.business_center_outlined),
                ),
                validator: (v) => Validators.validateRequired(v, 'Company'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _jobTitleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title / Role',
                  hintText: 'e.g. Lead Software Architect',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                validator: (v) => Validators.validateRequired(v, 'Job Title'),
              ),
              const SizedBox(height: 20),

              // Mentorship Option
              SwitchListTile(
                value: _isMentor,
                onChanged: (v) => setState(() => _isMentor = v),
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Open to Mentor KASU Students',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Allows undergraduate students to send you mentorship inquiries.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                activeColor: AppColors.blue,
              ),

              if (_isMentor) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mentorBioController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mentorship Focus / Topics',
                    hintText: 'e.g. Guiding final year students in coding, portfolio review, and job interviews...',
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Skills & Expertise
              const Text(
                'Areas of Expertise',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillInputController,
                      decoration: const InputDecoration(
                        hintText: 'Add an area (e.g. Cloud, Banking)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addSkill,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeSkill(skill),
                    backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                    side: BorderSide(color: AppColors.blue.withValues(alpha: 0.2)),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              FilledButton(
                onPressed: _isLoading ? null : _handleRegister,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Register as Alumni',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
