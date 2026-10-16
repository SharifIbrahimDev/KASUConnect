import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _bioController;
  late TextEditingController _companyController;
  late TextEditingController _jobTitleController;
  late TextEditingController _cvFileNameController;
  final _skillInputController = TextEditingController();
  List<String> _skills = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _bioController = TextEditingController(text: user?.bio ?? '');
    _companyController = TextEditingController(text: user?.currentCompany ?? '');
    _jobTitleController = TextEditingController(text: user?.jobTitle ?? '');
    _cvFileNameController = TextEditingController(text: user?.cvFileName ?? '');
    _skills = List.from(user?.skills ?? []);
  }

  @override
  void dispose() {
    _bioController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _cvFileNameController.dispose();
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

  void _removeSkill(String s) {
    setState(() => _skills.remove(s));
  }

  void _saveProfile() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    final updated = user.copyWith(
      bio: _bioController.text.trim(),
      currentCompany: _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : null,
      jobTitle: _jobTitleController.text.trim().isNotEmpty ? _jobTitleController.text.trim() : null,
      cvFileName: _cvFileNameController.text.trim().isNotEmpty ? _cvFileNameController.text.trim() : null,
      skills: _skills,
    );

    ref.read(currentUserProvider.notifier).updateProfile(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );

    context.pop();
  }

  void _simulateUploadCv() {
    final user = ref.read(currentUserProvider);
    final simulatedName = '${user?.fullName.replaceAll(' ', '_') ?? 'KASU'}_CV_2026.pdf';
    setState(() {
      _cvFileNameController.text = simulatedName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attached $simulatedName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bio
            const Text('About You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write a short bio describing your passions, academic focus, or career goals...',
              ),
            ),
            const SizedBox(height: 20),

            if (user?.isAlumni ?? false) ...[
              const Text('Career & Company', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Current Workplace / Organization'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jobTitleController,
                decoration: const InputDecoration(labelText: 'Job Title / Position'),
              ),
              const SizedBox(height: 20),
            ],

            if (user?.isStudent ?? false) ...[
              const Text('In-App CV / Resume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _cvFileNameController,
                      decoration: const InputDecoration(
                        labelText: 'CV File Name',
                        prefixIcon: Icon(Icons.picture_as_pdf, color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _simulateUploadCv,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Select / Upload CV PDF'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Skills
            const Text('Skills & Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillInputController,
                    decoration: const InputDecoration(hintText: 'Add a skill (e.g. Graphic Designer, Flutter)'),
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
              children: _skills.map((s) {
                return Chip(
                  label: Text(s),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeSkill(s),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
