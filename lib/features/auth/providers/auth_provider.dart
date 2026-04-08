import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/local_auth_service.dart';
import '../../../core/services/firestore_service.dart';
import '../models/user_model.dart';

// Use local auth mode (set to false to use Firebase)
final useLocalAuthProvider = StateProvider<bool>((ref) => false);

// Local Auth Service Provider
final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthService();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Firestore Service Provider
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

// Auth State Provider - supports both Firebase and Local auth
final authStateProvider = StreamProvider<dynamic>((ref) {
  final useLocal = ref.watch(useLocalAuthProvider);
  
  if (useLocal) {
    final localAuth = ref.watch(localAuthServiceProvider);
    return localAuth.authStateChanges;
  } else {
    final authService = ref.watch(authServiceProvider);
    return authService.authStateChanges;
  }
});

// Current User Provider - unified interface
final currentUserProvider = Provider<dynamic>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

// Current User UID Provider - works with both auth types
final currentUserUidProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  if (user is User) {
    return user.uid;
  } else if (user is LocalUser) {
    return user.uid;
  }
  return null;
});

// Current User Display Name Provider
final currentUserNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 'Guest';
  
  if (user is User) {
    return user.displayName ?? 'User';
  } else if (user is LocalUser) {
    return user.displayName;
  }
  return 'User';
});

// User Data Provider
final userDataProvider = StreamProvider.family<UserModel?, String>((ref, uid) {
  final useLocal = ref.watch(useLocalAuthProvider);
  
  if (useLocal) {
    // For local mode, create a simple UserModel from local data
    final user = ref.watch(currentUserProvider);
    if (user is LocalUser && user.uid == uid) {
      return Stream.value(UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        totalXP: 0,
        currentStreak: 0,
        longestStreak: 0,
        createdAt: user.createdAt,
        lastActive: DateTime.now(),
      ));
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
      createdAt: data['createdAt']?.toDate(),
      lastActive: data['lastActive']?.toDate(),
    );
  });
});

// Auth Actions Provider
final authActionsProvider = Provider<AuthActions>((ref) {
  final useLocal = ref.watch(useLocalAuthProvider);
  final localAuth = ref.watch(localAuthServiceProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthActions(authService, localAuth, useLocal);
});

class AuthActions {
  final AuthService _authService;
  final LocalAuthService _localAuthService;
  final bool _useLocal;

  AuthActions(this._authService, this._localAuthService, this._useLocal);

  Future<void> signIn(String email, String password) async {
    if (_useLocal) {
      await _localAuthService.signIn(email: email, password: password);
    } else {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    if (_useLocal) {
      await _localAuthService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
    } else {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
    }
  }

  Future<void> signOut() async {
    if (_useLocal) {
      await _localAuthService.signOut();
    } else {
      await _authService.signOut();
    }
  }

  Future<void> signInAnonymously() async {
    if (_useLocal) {
      await _localAuthService.signInAnonymously();
    } else {
      await _authService.signInAnonymously();
    }
  }

  Future<void> resetPassword(String email) async {
    if (_useLocal) {
      throw 'Password reset is not available in offline mode.';
    } else {
      await _authService.resetPassword(email);
    }
  }
}
