import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/mentorship_repository.dart';

class MentorshipRequestDialog extends ConsumerStatefulWidget {
  final UserModel alumni;

  const MentorshipRequestDialog({super.key, required this.alumni});

  static Future<void> show(BuildContext context, UserModel alumni) {
    return showDialog(
      context: context,
      builder: (ctx) => MentorshipRequestDialog(alumni: alumni),
    );
  }

  @override
  ConsumerState<MentorshipRequestDialog> createState() => _MentorshipRequestDialogState();
}

class _MentorshipRequestDialogState extends ConsumerState<MentorshipRequestDialog> {
  final _messageController = TextEditingController(
    text: 'Sir/Ma, please mentor me on building my career and transitioning from KASU to the professional industry.',
  );
  String _fieldOfInterest = 'Software & Technology';
  bool _isLoading = false;

  final List<String> _topics = [
    'Software & Technology',
    'Career Advisory & CV Review',
    'Finance & Accounting',
    'Media, Public Relations & Journalism',
    'Graduate School & Scholarships',
    'Entrepreneurship in Kaduna',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    final student = ref.read(currentUserProvider);
    if (student == null) return;

    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a message to your mentor')),
      );
      return;
    }

    setState(() => _isLoading = true);

    ref.read(mentorshipListProvider.notifier).sendRequest(
          student: student,
          alumni: widget.alumni,
          message: _messageController.text.trim(),
          fieldOfInterest: _fieldOfInterest,
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mentorship request sent to ${widget.alumni.fullName}!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.alumni.avatarUrl != null
                ? NetworkImage(widget.alumni.avatarUrl!)
                : null,
            child: widget.alumni.avatarUrl == null
                ? Text(widget.alumni.fullName[0], style: const TextStyle(fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.alumni.fullName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: AppColors.blue, size: 16),
                  ],
                ),
                Text(
                  widget.alumni.subtitleInfo,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mentorship Focus Area',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _fieldOfInterest,
              isExpanded: true,
              items: _topics.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text(t, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _fieldOfInterest = val);
              },
            ),
            const SizedBox(height: 14),

            const Text(
              'Your Message to Mentor',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. "Sir, please mentor me on building scalable projects and landing remote roles."',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitRequest,
          style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Send Request'),
        ),
      ],
    );
  }
}
