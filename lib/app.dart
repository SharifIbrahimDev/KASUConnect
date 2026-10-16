import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/messaging_service.dart';
import 'features/settings/theme_controller.dart';

class KasuConnectApp extends ConsumerWidget {
  const KasuConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final mode = ref.watch(themeModeProvider);
    // Registers the FCM token once a user is signed in.
    ref.watch(messagingBootstrapProvider);
    return MaterialApp.router(
      title: 'KASUConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
