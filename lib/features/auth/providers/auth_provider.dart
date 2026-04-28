import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_challenge_service.dart';
import '../../../core/services/auth_flow_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/local_auth_service.dart';
import '../models/auth_challenge.dart';
import '../models/user_model.dart';

final useLocalAuthProvider = StateProvider<bool>((ref) => false);

final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthService();
});

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authChallengeServiceProvider = Provider<AuthChallengeService>((ref) {
  return AuthChallengeService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Initialize session on app start - checks token validity and updates streak
final sessionInitializationProvider = FutureProvider<bool>((ref) async {
  final useLocal = ref.watch(useLocalAuthProvider);
  if (useLocal) {
    return false;
  }
  
  final authService = ref.watch(authServiceProvider);
  return authService.initializeSessionOnAppStart();
});

final authStateProvider = StreamProvider<dynamic>((ref) {
  final useLocal = ref.watch(useLocalAuthProvider);
  if (useLocal) {
    return ref.watch(localAuthServiceProvider).authStateChanges;
  }
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<dynamic>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user, orElse: () => null);
});

final currentUserUidProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  if (user is User) return user.uid;
  if (user is LocalUser) return user.uid;
  return null;
});

final currentUserNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 'Guest';

  if (user is User) return user.displayName ?? 'User';
  if (user is LocalUser) return user.displayName;
  return 'User';
});

final userDataProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  final useLocal = ref.watch(useLocalAuthProvider);

  if (useLocal) {
    final user = ref.watch(currentUserProvider);
    if (user is LocalUser && user.uid == uid) {
      return Stream.value(
        UserModel(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          skillLevel: user.skillLevel,
          preferredLanguage: user.preferredLanguage,
          authMethod: user.authMethod,
          bio: user.bio,
          dailyGoalMinutes: user.dailyGoalMinutes,
          totalXP: 0,
          currentStreak: 0,
          longestStreak: 0,
          createdAt: user.createdAt,
          lastActive: DateTime.now(),
        ),
      );
    }
    return Stream.value(null);
  }

  final firestoreService = ref.watch(firestoreServiceProvider);

  return firestoreService.usersCollection.doc(uid).snapshots().map((snapshot) {
    if (!snapshot.exists) return null;
    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      totalXP: data['totalXP'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      skillLevel: data['skillLevel'] ?? 'beginner',
      preferredLanguage: data['preferredLanguage'] ?? 'python',
      authMethod: data['authMethod'] ?? 'email',
      bio: data['bio'] ?? '',
      dailyGoalMinutes: data['dailyGoalMinutes'] ?? 20,
      createdAt: data['createdAt']?.toDate(),
      lastActive: data['lastActive']?.toDate(),
    );
  });
});

final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(
    ref: ref,
    authService: ref.watch(authServiceProvider),
    localAuthService: ref.watch(localAuthServiceProvider),
    challengeService: ref.watch(authChallengeServiceProvider),
    useLocal: ref.watch(useLocalAuthProvider),
  );
});

class AuthActions {
  final Ref _ref;
  final AuthService _authService;
  final LocalAuthService _localAuthService;
  final AuthChallengeService _challengeService;
  final bool _useLocal;

  AuthActions({
    required Ref ref,
    required AuthService authService,
    required LocalAuthService localAuthService,
    required AuthChallengeService challengeService,
    required bool useLocal,
  }) : _ref = ref,
       _authService = authService,
       _localAuthService = localAuthService,
       _challengeService = challengeService,
       _useLocal = useLocal;

  Future<void> signIn(String email, String password) async {
    if (_useLocal) {
      await _localAuthService.signIn(email: email, password: password);
      return;
    }
    await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(
    String email,
    String password,
    String displayName, {
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
  }) async {
    if (_useLocal) {
      await _localAuthService.register(
        email: email,
        password: password,
        displayName: displayName,
        skillLevel: skillLevel,
        preferredLanguage: preferredLanguage,
        authMethod: 'email',
      );
      return;
    }
    await _authService.registerWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
      skillLevel: skillLevel,
      preferredLanguage: preferredLanguage,
    );
  }

  Future<void> signOut() async {
    if (_useLocal) {
      await _localAuthService.signOut();
      return;
    }
    await _authService.signOut();
  }

  Future<void> signInAnonymously() async {
    if (_useLocal) {
      await _localAuthService.signInAnonymously();
      return;
    }
    try {
      await _authService.signInAnonymously();
    } on AuthFlowException catch (error) {
      if (error.code == 'anonymous-sign-in-disabled') {
        _ref.read(useLocalAuthProvider.notifier).state = true;
        await _localAuthService.signInAnonymously();
        return;
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    if (_useLocal) {
      throw 'Password reset is not available in offline mode.';
    }
    await _authService.resetPassword(email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_useLocal) {
      await _localAuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return;
    }
    await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> signInWithGoogle({
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
  }) async {
    if (_useLocal) {
      throw 'Google sign-in is not available in offline mode.';
    }
    await _authService.signInWithGoogle(
      skillLevel: skillLevel,
      preferredLanguage: preferredLanguage,
    );
  }

  Future<void> sendMagicLink(String email) async {
    if (_useLocal) {
      throw 'Magic link is not available in offline mode.';
    }
    await _authService.sendMagicLink(email);
  }

  Future<void> signInWithMagicLink({
    required String emailLink,
    String? email,
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
  }) async {
    if (_useLocal) {
      throw 'Magic link is not available in offline mode.';
    }
    await _authService.signInWithMagicLink(
      emailLink: emailLink,
      email: email,
      skillLevel: skillLevel,
      preferredLanguage: preferredLanguage,
    );
  }

  AuthChallenge createCodingChallenge(String email) {
    return _challengeService.issueChallenge(email: email);
  }

  Future<void> signInWithCodingChallenge({
    required String email,
    required String password,
    required String answer,
  }) async {
    _challengeService.verifyAnswer(email: email, answer: answer);
    await signIn(email, password);
  }

  Future<void> refreshSessionTokens() async {
    if (_useLocal) {
      throw 'Token refresh is not available in offline mode.';
    }
    await _authService.refreshJwtToken();
  }

  /// Switch Google Account
  /// Signs out from Google to force account selection on next login
  Future<void> switchGoogleAccount() async {
    if (_useLocal) {
      throw 'Google account switching is not available in offline mode.';
    }
    await _authService.googleSignOutForAccountSwitch();
  }

  Future<void> updateProfile({
    required String displayName,
    required String email,
    required String skillLevel,
    required String preferredLanguage,
    String? photoURL,
    String bio = '',
    int dailyGoalMinutes = 20,
  }) async {
    if (_useLocal) {
      final uid = _localAuthService.currentUser?.uid;
      if (uid == null) throw 'User not authenticated.';
      await _localAuthService.updateProfile(
        uid: uid,
        displayName: displayName,
        email: email,
        skillLevel: skillLevel,
        preferredLanguage: preferredLanguage,
        photoURL: photoURL,
        bio: bio,
        dailyGoalMinutes: dailyGoalMinutes,
      );
      return;
    }

    await _authService.updateProfile(
      displayName: displayName,
      email: email,
      skillLevel: skillLevel,
      preferredLanguage: preferredLanguage,
      photoURL: photoURL,
      bio: bio,
      dailyGoalMinutes: dailyGoalMinutes,
    );
  }
}
