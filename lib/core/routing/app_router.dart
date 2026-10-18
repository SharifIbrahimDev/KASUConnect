import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repository.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_student_screen.dart';
import '../../features/auth/register_alumni_screen.dart';
import '../../features/auth/pending_verification_screen.dart';
import '../../features/home/home_nav_screen.dart';
import '../../features/feed/create_post_screen.dart';
import '../../features/feed/post_detail_screen.dart';
import '../../features/networking/peer_search_screen.dart';
import '../../features/networking/user_profile_screen.dart';
import '../../features/networking/edit_profile_screen.dart';
import '../../features/alumni/alumni_hub_screen.dart';
import '../../features/alumni/mentorship_dashboard_screen.dart';
import '../../features/jobs/jobs_screen.dart';
import '../../features/jobs/job_detail_screen.dart';
import '../../features/jobs/post_job_screen.dart';
import '../../features/jobs/my_applications_screen.dart';
import '../../features/jobs/manage_job_applicants_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_conversation_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/verification_queue_screen.dart';
import '../../features/admin/job_approval_screen.dart';
import '../../features/admin/user_moderation_screen.dart';
import '../../features/admin/report_moderation_screen.dart';
import '../../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: authRepo.currentUser != null ? '/home' : '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-student',
        builder: (context, state) => const RegisterStudentScreen(),
      ),
      GoRoute(
        path: '/register-alumni',
        builder: (context, state) => const RegisterAlumniScreen(),
      ),
      GoRoute(
        path: '/pending-verification',
        builder: (context, state) => const PendingVerificationScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeNavScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PostDetailScreen(postId: id);
        },
      ),
      GoRoute(
        path: '/peer-search',
        builder: (context, state) => const PeerSearchScreen(),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return UserProfileScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/alumni',
        builder: (context, state) => const AlumniHubScreen(),
      ),
      GoRoute(
        path: '/mentorship-dashboard',
        builder: (context, state) => const MentorshipDashboardScreen(),
      ),
      GoRoute(
        path: '/jobs',
        builder: (context, state) => const JobsScreen(),
      ),
      GoRoute(
        path: '/job/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return JobDetailScreen(jobId: id);
        },
      ),
      GoRoute(
        path: '/post-job',
        builder: (context, state) => const PostJobScreen(),
      ),
      GoRoute(
        path: '/my-applications',
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: '/manage-job-applicants/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ManageJobApplicantsScreen(jobId: id);
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChatConversationScreen(chatId: id);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/verification-queue',
        builder: (context, state) => const VerificationQueueScreen(),
      ),
      GoRoute(
        path: '/admin/job-approvals',
        builder: (context, state) => const JobApprovalScreen(),
      ),
      GoRoute(
        path: '/admin/user-moderation',
        builder: (context, state) => const UserModerationScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const ReportModerationScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
