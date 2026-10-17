import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../feed/feed_screen.dart';
import '../networking/peer_search_screen.dart';
import '../jobs/jobs_screen.dart';
import '../alumni/alumni_hub_screen.dart';
import '../alumni/mentorship_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/verification_queue_screen.dart';
import '../admin/job_approval_screen.dart';
import '../admin/user_moderation_screen.dart';
import '../settings/settings_screen.dart';

class HomeNavScreen extends ConsumerStatefulWidget {
  const HomeNavScreen({super.key});

  @override
  ConsumerState<HomeNavScreen> createState() => _HomeNavScreenState();
}

class _HomeNavScreenState extends ConsumerState<HomeNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final role = currentUser?.role ?? UserRole.student;

    final List<Widget> screens;
    final List<NavigationDestination> destinations;

    if (role == UserRole.admin) {
      screens = const [
        AdminDashboardScreen(),
        VerificationQueueScreen(),
        JobApprovalScreen(),
        UserModerationScreen(),
        SettingsScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Overview',
        ),
        NavigationDestination(
          icon: Icon(Icons.verified_user_outlined),
          selectedIcon: Icon(Icons.verified_user),
          label: 'Verify IDs',
        ),
        NavigationDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: 'Vet Jobs',
        ),
        NavigationDestination(
          icon: Icon(Icons.manage_accounts_outlined),
          selectedIcon: Icon(Icons.manage_accounts),
          label: 'Moderation',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    } else if (role == UserRole.alumni) {
      screens = const [
        FeedScreen(),
        PeerSearchScreen(),
        JobsScreen(),
        MentorshipDashboardScreen(),
        SettingsScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.dynamic_feed_outlined),
          selectedIcon: Icon(Icons.dynamic_feed),
          label: 'Feed',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_search_outlined),
          selectedIcon: Icon(Icons.person_search),
          label: 'Network',
        ),
        NavigationDestination(
          icon: Icon(Icons.work_outline),
          selectedIcon: Icon(Icons.work),
          label: 'Jobs',
        ),
        NavigationDestination(
          icon: Icon(Icons.handshake_outlined),
          selectedIcon: Icon(Icons.handshake),
          label: 'Mentorship',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    } else {
      // Student View
      screens = const [
        FeedScreen(),
        PeerSearchScreen(),
        JobsScreen(),
        AlumniHubScreen(),
        SettingsScreen(),
      ];
      destinations = const [
        NavigationDestination(
          icon: Icon(Icons.dynamic_feed_outlined),
          selectedIcon: Icon(Icons.dynamic_feed),
          label: 'Feed',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_search_outlined),
          selectedIcon: Icon(Icons.person_search),
          label: 'Peers',
        ),
        NavigationDestination(
          icon: Icon(Icons.work_outline),
          selectedIcon: Icon(Icons.work),
          label: 'Jobs',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: 'Alumni',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ];
    }

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: destinations,
      ),
    );
  }
}
