import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/firebase_config.dart';
import '../services/firestore_service.dart';
import 'auth_flow_exception.dart';
import 'auth_token_storage_service.dart';
import 'logger_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirestoreService _firestoreService;
  final GoogleSignIn _googleSignIn;
  final AuthTokenStorageService _tokenStorage;

  bool _googleInitialized = false;

  AuthService({
    FirebaseAuth? auth,
    FirestoreService? firestoreService,
    GoogleSignIn? googleSignIn,
    AuthTokenStorageService? tokenStorage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestoreService = firestoreService ?? FirestoreService(),
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _tokenStorage = tokenStorage ?? AuthTokenStorageService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _firestoreService.updateStreak(credential.user!.uid);
        await _persistSessionTokens(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await _firestoreService.createUserDocument(
          credential.user!,
          displayName: displayName,
          skillLevel: skillLevel,
          preferredLanguage: preferredLanguage,
          authMethod: 'email',
        );
        await _persistSessionTokens(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithGoogle({
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
  }) async {
    try {
      await _ensureGoogleInitialized();
      AppLogger.info('Starting Google Sign-In...');

      final account = await _googleSignIn.authenticate();

      AppLogger.info('Got Google account: ${account.email}');

      final authentication = account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        AppLogger.error('Google returned null or empty idToken', null);
        throw const AuthFlowException(
          code: 'missing-google-token',
          message: 'Google не повернув токен авторизації.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      AppLogger.info('Created GoogleAuthProvider credential');

      final userCredential = await _auth.signInWithCredential(credential);
      AppLogger.info(
        'Firebase sign-in successful for: ${userCredential.user?.email}',
      );

      if (userCredential.user != null) {
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          AppLogger.info('Creating new user document...');
          await _firestoreService.createUserDocument(
            userCredential.user!,
            displayName:
                userCredential.user!.displayName ??
                userCredential.user!.email?.split('@').first ??
                'User',
            skillLevel: skillLevel,
            preferredLanguage: preferredLanguage,
            authMethod: 'google',
          );
        }
        await _firestoreService.updateStreak(userCredential.user!.uid);
        await _persistSessionTokens(userCredential.user!);
      }

      return userCredential;
    } on AuthFlowException {
      rethrow;
    } on GoogleSignInException catch (error, stackTrace) {
      AppLogger.error(
        'GoogleSignInException in Google Sign-In',
        error,
        stackTrace,
      );
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
          throw const AuthFlowException(
            code: 'google-sign-in-cancelled',
            message: 'Google sign-in was cancelled.',
          );
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw AuthFlowException(
            code: 'google-sign-in-misconfigured',
            message:
                'Google Sign-In is not configured correctly. ${error.description ?? ''}'
                    .trim(),
          );
        default:
          throw AuthFlowException(
            code: 'google-sign-in-error',
            message:
                'Google Sign-In failed: ${error.description ?? error.code.name}',
          );
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error('FirebaseAuthException in Google Sign-In: ${e.code}', e);
      throw _handleAuthException(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error in Google Sign-In: $e', e, stackTrace);
      throw AuthFlowException(
        code: 'google-sign-in-error',
        message: 'Google Sign-In failed: $e',
      );
    }
  }

  Future<void> sendMagicLink(String email) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw const AuthFlowException(
        code: 'invalid-email',
        message: 'Вкажіть валідний email для magic link.',
      );
    }

    try {
      await _auth.sendSignInLinkToEmail(
        email: trimmedEmail,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://codelearn.app/auth/magic',
          handleCodeInApp: true,
          iOSBundleId: 'com.example.untitled',
          androidPackageName: 'com.example.untitled',
          androidInstallApp: true,
          androidMinimumVersion: '21',
        ),
      );
      await _tokenStorage.savePendingMagicEmail(trimmedEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithMagicLink({
    required String emailLink,
    String? email,
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
  }) async {
    if (!_auth.isSignInWithEmailLink(emailLink)) {
      throw const AuthFlowException(
        code: 'invalid-magic-link',
        message: 'Magic link невалідний або пошкоджений.',
      );
    }

    final providedEmail = email?.trim().toLowerCase();
    final pendingEmail = await _tokenStorage.readPendingMagicEmail();
    final targetEmail = (providedEmail?.isNotEmpty ?? false)
        ? providedEmail!
        : pendingEmail;

    if (targetEmail == null || targetEmail.isEmpty) {
      throw const AuthFlowException(
        code: 'missing-magic-email',
        message:
            'Email для magic link не знайдено. Введіть email повторно і відправте новий link.',
      );
    }

    try {
      final credential = await _auth.signInWithEmailLink(
        email: targetEmail,
        emailLink: emailLink,
      );

      if (credential.user != null) {
        if (credential.additionalUserInfo?.isNewUser ?? false) {
          await _firestoreService.createUserDocument(
            credential.user!,
            displayName:
                credential.user!.displayName ?? targetEmail.split('@').first,
            skillLevel: skillLevel,
            preferredLanguage: preferredLanguage,
            authMethod: 'magic-link',
          );
        }
        await _firestoreService.updateStreak(credential.user!.uid);
        await _persistSessionTokens(credential.user!);
      }

      await _tokenStorage.clearPendingMagicEmail();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateProfile({
    required String displayName,
    required String email,
    required String skillLevel,
    required String preferredLanguage,
    String bio = '',
    int dailyGoalMinutes = 20,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFlowException(
        code: 'not-authenticated',
        message: 'Користувач не автентифікований.',
      );
    }

    final normalizedName = displayName.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedName.length < 2) {
      throw const AuthFlowException(
        code: 'invalid-display-name',
        message: 'Імʼя має бути щонайменше 2 символи.',
      );
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const AuthFlowException(
        code: 'invalid-email',
        message: 'Вкажіть валідний email.',
      );
    }

    try {
      if (user.displayName != normalizedName) {
        await user.updateDisplayName(normalizedName);
      }
      if ((user.email ?? '').trim().toLowerCase() != normalizedEmail) {
        // ignore: deprecated_member_use
        await user.updateEmail(normalizedEmail);
      }
      await _firestoreService.updateUserProfile(
        userId: user.uid,
        displayName: normalizedName,
        email: normalizedEmail,
        skillLevel: skillLevel,
        preferredLanguage: preferredLanguage,
        bio: bio,
        dailyGoalMinutes: dailyGoalMinutes,
      );
      await _persistSessionTokens(user, forceRefresh: true);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFlowException(
        code: 'not-authenticated',
        message: 'Користувач не автентифікований.',
      );
    }

    final email = user.email?.trim().toLowerCase();
    final hasPasswordProvider = user.providerData.any(
      (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );
    if (email == null || email.isEmpty || !hasPasswordProvider) {
      throw const AuthFlowException(
        code: 'password-provider-not-linked',
        message: 'Password change is unavailable for this account.',
      );
    }

    final trimmedCurrent = currentPassword.trim();
    final trimmedNew = newPassword.trim();
    if (trimmedCurrent.isEmpty) {
      throw const AuthFlowException(
        code: 'invalid-current-password',
        message: 'Enter your current password.',
      );
    }
    if (trimmedNew.length < 6) {
      throw const AuthFlowException(
        code: 'invalid-new-password',
        message: 'The new password must be at least 6 characters.',
      );
    }
    if (trimmedCurrent == trimmedNew) {
      throw const AuthFlowException(
        code: 'same-password',
        message:
            'The new password must be different from the current password.',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: trimmedCurrent,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(trimmedNew);
      await _persistSessionTokens(user, forceRefresh: true);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _tokenStorage.clearTokenBundle();
    await _tokenStorage.clearPendingMagicEmail();
  }

  Future<UserCredential> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();

      if (credential.user != null) {
        await _firestoreService.createUserDocument(
          credential.user!,
          displayName: 'Guest User',
          authMethod: 'anonymous',
        );
        await _persistSessionTokens(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<AuthTokenBundle> refreshJwtToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthFlowException(
        code: 'expired-token',
        message: 'Сесія завершилась. Увійдіть знову.',
      );
    }
    return _persistSessionTokens(user, forceRefresh: true);
  }

  Future<AuthTokenBundle?> getStoredTokenBundle() {
    return _tokenStorage.readTokenBundle();
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    try {
      if (kIsWeb) {
        await _googleSignIn.initialize(
          clientId: FirebaseConfig.webGoogleSignInClientId,
        );
      } else {
        await _googleSignIn.initialize();
      }
      _googleInitialized = true;
    } on AssertionError catch (error, stackTrace) {
      AppLogger.error(
        'Google Sign-In initialization assertion failed',
        error,
        stackTrace,
      );
      throw const AuthFlowException(
        code: 'google-web-client-id-missing',
        message:
            'Google Sign-In for web is not configured. Missing OAuth client ID.',
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'Google Sign-In initialization failed',
        error,
        stackTrace,
      );
      throw AuthFlowException(
        code: 'google-initialize-failed',
        message: 'Google Sign-In initialization failed: $error',
      );
    }
  }

  Future<AuthTokenBundle> _persistSessionTokens(
    User user, {
    bool forceRefresh = false,
  }) async {
    final accessToken = await user.getIdToken(forceRefresh);
    final liveRefreshToken = user.refreshToken?.trim();
    final idTokenResult = await user.getIdTokenResult(forceRefresh);
    final expiresAt = idTokenResult.expirationTime;

    if (accessToken == null || accessToken.isEmpty) {
      throw const AuthFlowException(
        code: 'missing-access-token',
        message: 'Не вдалося отримати access token.',
      );
    }
    if (expiresAt == null) {
      throw const AuthFlowException(
        code: 'missing-token-expiry',
        message: 'Не вдалося визначити термін дії токена.',
      );
    }

    String? refreshToken;
    if (liveRefreshToken != null && liveRefreshToken.isNotEmpty) {
      refreshToken = liveRefreshToken;
    } else {
      final storedBundle = await _tokenStorage.readTokenBundle();
      refreshToken = storedBundle?.refreshToken;
      AppLogger.info(
        'FirebaseAuth user.refreshToken is unavailable; using stored token when present.',
      );
    }

    final bundle = AuthTokenBundle(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
    await _tokenStorage.saveTokenBundle(bundle);
    return bundle;
  }

  String _handleAuthException(FirebaseAuthException e) {
    AppLogger.error('Firebase Auth Error: ${e.code}', e);
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak (minimum 6 characters).';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-action-code':
        return 'Magic link is invalid or expired.';
      case 'expired-action-code':
        return 'Magic link expired. Request a new one.';
      case 'requires-recent-login':
        return 'Please sign in again before changing sensitive profile fields.';
      default:
        return 'Auth error (${e.code}): ${e.message ?? "Please try again."}';
    }
  }
}
