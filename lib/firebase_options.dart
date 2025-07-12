// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyB_nAKQ7T1pZurvtxTyCjvm5ZShatdT0bc',
        appId: '1:1020228850371:ios:f89e6fe15a8829a26ac876',
        messagingSenderId: '1020228850371',
        projectId: 'decont-a44e8',
        iosBundleId: 'com.decont.android',
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyCdSkvWZc9c7iIRb5k016KLpHBvh7yisgk',
        appId: '1:1020228850371:android:8c3c28d8e0bb21886ac876',
        messagingSenderId: 'decont-a44e8.appspot.com',
        projectId: 'decont-a44e8',
      );
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
