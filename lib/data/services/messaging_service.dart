import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService();
});

final messagingBootstrapProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(messagingServiceProvider);
  await service.initialize();
});

class MessagingService {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted notification permissions');
        final token = await messaging.getToken();
        debugPrint('FCM Device Token: $token');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message received: ${message.notification?.title}');
      });

      _initialized = true;
    } catch (e) {
      debugPrint('FCM not initialized or running in mock mode: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return null;
    }
  }
}
