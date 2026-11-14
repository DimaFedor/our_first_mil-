import '../../foundation/json.dart';

class AuthIdentity {
  final String uid;
  final String? email;
  const AuthIdentity({required this.uid, this.email});
}

class AuthResult {
  final AuthIdentity? user;
  const AuthResult(this.user);
}

abstract interface class AuthService {
  bool get available;
  Stream<AuthIdentity?> get changes;
  Future<AuthResult> signIn(
    String email,
    String password, {
    bool register = false,
  });
  Future<AuthResult> google();
  Future<void> reset(String email);
  Future<void> sendLink(String email);
  Future<AuthResult> finishLink(String email, String link);
  Future<void> signOut();
}

class GuestAuthService implements AuthService {
  const GuestAuthService();
  @override
  bool get available => false;
  @override
  Stream<AuthIdentity?> get changes => Stream.value(null);
  @override
  Future<AuthResult> signIn(
    String email,
    String password, {
    bool register = false,
  }) async => throw const AppFailure('authUnavailable');
  @override
  Future<AuthResult> google() async =>
      throw const AppFailure('authUnavailable');
  @override
  Future<void> reset(String email) async =>
      throw const AppFailure('authUnavailable');
  @override
  Future<void> sendLink(String email) async =>
      throw const AppFailure('authUnavailable');
  @override
  Future<AuthResult> finishLink(String email, String link) async =>
      throw const AppFailure('authUnavailable');
  @override
  Future<void> signOut() async {}
}
