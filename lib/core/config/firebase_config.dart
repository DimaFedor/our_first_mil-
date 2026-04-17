import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const String webGoogleSignInClientId =
      '86155501303-irjm5tk28rrif9thhev61uinio025hor.apps.googleusercontent.com';

  static Future<void> initialize() async {
    await Firebase.initializeApp(options: _getFirebaseOptions());
  }

  static FirebaseOptions _getFirebaseOptions() {
    // Firebase Configuration for CodeLearn
    // Project: courses-3d6bf

    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: "AIzaSyBGLPmmfL8rYjoinmR2yM0l_qxYW_NFxW0",
        authDomain: "courses-3d6bf.firebaseapp.com",
        projectId: "courses-3d6bf",
        storageBucket: "courses-3d6bf.firebasestorage.app",
        messagingSenderId: "86155501303",
        appId: "1:86155501303:web:269d4d4665500897573df2",
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return const FirebaseOptions(
        apiKey: "AIzaSyBGLPmmfL8rYjoinmR2yM0l_qxYW_NFxW0",
        appId: "1:86155501303:android:269d4d4665500897573df2",
        messagingSenderId: "86155501303",
        projectId: "courses-3d6bf",
        storageBucket: "courses-3d6bf.firebasestorage.app",
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const FirebaseOptions(
        apiKey: "AIzaSyAtQUlu5FkW3wx8Ncf5KZi2E8wCDDtNXfk",
        appId: "1:86155501303:ios:a346361a385344ed573df2",
        messagingSenderId: "86155501303",
        projectId: "courses-3d6bf",
        storageBucket: "courses-3d6bf.firebasestorage.app",
        iosBundleId: "com.example.untitled",
      );
    }

    throw UnsupportedError('Unsupported platform');
  }
}
