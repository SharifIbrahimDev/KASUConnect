import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'data/services/messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Uses android/app/google-services.json (added by `flutterfire configure`).
    await Firebase.initializeApp();
    await Env.connectEmulatorsIfEnabled();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase initialization bypassed or not configured yet: $e');
  }

  runApp(const ProviderScope(child: KasuConnectApp()));
}
