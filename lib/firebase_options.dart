import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAXO4yQsazD23pImDbkVmnofGrwmCMt59w',
    appId: '1:252575324051:android:9f9a0c074b950edfbb3a66',
    messagingSenderId: '252575324051',
    projectId: 'pls-wrya',
    databaseURL: 'https://pls-wrya-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'pls-wrya.firebasestorage.app',
  );
}
