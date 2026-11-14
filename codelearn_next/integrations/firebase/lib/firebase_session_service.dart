import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:codelearn_next/foundation/json.dart';
import 'package:codelearn_next/features/auth/auth_service.dart';

const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
const firebaseSenderId = String.fromEnvironment('FIREBASE_SENDER_ID');
const signInLinkUrl = String.fromEnvironment('SIGN_IN_LINK_URL');

class FirebaseSessionService implements AuthService {
  final FirebaseAuth? auth;
  const FirebaseSessionService(this.auth);
  @override
  bool get available => auth != null;
  @override
  Stream<AuthIdentity?> get changes =>
      auth?.authStateChanges().map(
        (user) => user == null
            ? null
            : AuthIdentity(uid: user.uid, email: user.email),
      ) ??
      Stream.value(null);

  static Future<FirebaseSessionService> initialize() async {
    if (firebaseApiKey.isEmpty ||
        firebaseAppId.isEmpty ||
        firebaseProjectId.isEmpty ||
        firebaseSenderId.isEmpty) {
      return const FirebaseSessionService(null);
    }
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: firebaseApiKey,
        appId: firebaseAppId,
        messagingSenderId: firebaseSenderId,
        projectId: firebaseProjectId,
        authDomain: '$firebaseProjectId.firebaseapp.com',
      ),
    );
    return FirebaseSessionService(FirebaseAuth.instance);
  }

  @override
  Future<AuthResult> signIn(
    String email,
    String password, {
    bool register = false,
  }) async {
    final client = auth;
    if (client == null) throw const AppFailure('authUnavailable');
    final credential = register
        ? await client.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
        : await client.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
    return authResult(credential);
  }

  @override
  Future<AuthResult> google() async {
    final client = auth;
    if (client == null) throw const AppFailure('authUnavailable');
    final provider = GoogleAuthProvider();
    return authResult(
      kIsWeb
          ? await client.signInWithPopup(provider)
          : await client.signInWithProvider(provider),
    );
  }

  @override
  Future<void> reset(String email) async {
    final client = auth;
    if (client == null) throw const AppFailure('authUnavailable');
    await client.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendLink(String email) async {
    final client = auth;
    if (client == null || signInLinkUrl.isEmpty) {
      throw const AppFailure('authUnavailable');
    }
    await client.sendSignInLinkToEmail(
      email: email.trim(),
      actionCodeSettings: ActionCodeSettings(
        url: signInLinkUrl,
        handleCodeInApp: true,
        iOSBundleId: 'app.codelearn.codelearnNext',
        androidPackageName: 'app.codelearn.codelearn_next',
        androidInstallApp: true,
      ),
    );
  }

  @override
  Future<AuthResult> finishLink(String email, String link) async {
    final client = auth;
    if (client == null || !client.isSignInWithEmailLink(link)) {
      throw const AppFailure('authError');
    }
    return authResult(
      await client.signInWithEmailLink(
        email: email.trim(),
        emailLink: link.trim(),
      ),
    );
  }

  @override
  Future<void> signOut() async {
    await auth?.signOut();
  }
}

AuthResult authResult(UserCredential credential) => AuthResult(
  credential.user == null
      ? null
      : AuthIdentity(uid: credential.user!.uid, email: credential.user!.email),
);
