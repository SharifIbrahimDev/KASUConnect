import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterStudentScreen extends ConsumerStatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  ConsumerState<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends ConsumerState<RegisterStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _matricController = TextEditingController();
  final _passwordController = TextEditingController();
  final _skillInputController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedFaculty = AppConstants.fallbackFaculties.keys.first;
  late String _selectedDepartment;
  String _selectedLevel = '300L';
  final List<String> _skills = ['Flutter', 'Graphic Design', 'Python'];
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
    _matricController.dispose();
    _passwordController.dispose();
    _skillInputController.dispose();
    _bioController.dispose();
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
      await ref.read(currentUserProvider.notifier).registerStudent(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            matricNumber: _matricController.text.trim().toUpperCase(),
            faculty: _selectedFaculty,
            department: _selectedDepartment,
            level: _selectedLevel,
            skills: _skills,
            bio: _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : 'KASU Student in $_selectedDepartment',
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
        title: const Text('Student Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Verification banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.blue.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
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
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'To prevent impersonation, all registrations require a valid KASU matric number verified by the school admin.',
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
                  hintText: 'e.g. Fatima Bello',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => Validators.validateRequired(v, 'Full Name'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'KASU Email / Active Email',
                  hintText: 'e.g. fatima.bello@kasu.edu.ng',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _matricController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'KASU Matriculation Number',
                  hintText: 'e.g. KASU/20/CSC/1042',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: Validators.validateMatricNumber,
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
                  labelText: 'Faculty',
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

              // Department Dropdown
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
                  if (val != null) {
                    setState(() => _selectedDepartment = val);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Level Dropdown
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Academic Level',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: AppConstants.levels.map((lvl) {
                  return DropdownMenuItem(value: lvl, child: Text(lvl));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLevel = val);
                },
              ),
              const SizedBox(height: 20),

              // Skills for Peer Discovery
              const Text(
                'Your Skills (For Peer & Job Matching)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Peers and alumni will find you based on these skills (e.g., Graphic Designer, Flutter, Excel).',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _skillInputController,
                      decoration: const InputDecoration(
                        hintText: 'Add a skill (e.g. Figma, Python)',
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

              const SizedBox(height: 16),

              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Short Bio',
                  hintText: 'Introduce yourself and what you are passionate about...',
                ),
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
                        'Submit for Verification',
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
