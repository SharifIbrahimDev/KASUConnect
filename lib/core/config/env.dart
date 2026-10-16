import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Non-secret build configuration.
///
/// Run against the local Emulator Suite with:
/// `flutter run --dart-define=USE_EMULATOR=true --dart-define=EMULATOR_HOST=10.0.2.2`
class Env {
  static const useEmulator = bool.fromEnvironment('USE_EMULATOR');
  static const emulatorHost =
      String.fromEnvironment('EMULATOR_HOST', defaultValue: '10.0.2.2');
  static const functionsRegion =
      String.fromEnvironment('FUNCTIONS_REGION', defaultValue: 'us-central1');

  static Future<void> connectEmulatorsIfEnabled() async {
    if (!useEmulator) return;
    debugPrint('KASUConnect: using Firebase emulators at $emulatorHost');
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
    await FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
    FirebaseFunctions.instanceFor(region: functionsRegion)
        .useFunctionsEmulator(emulatorHost, 5001);
  }
}
