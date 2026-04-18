import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local authentication service for offline/demo mode.
class LocalAuthService {
  static const _usersKey = 'local_users';
  static const _currentUserKey = 'current_user';

  final _authStateController = StreamController<LocalUser?>.broadcast();
  LocalUser? _currentUser;

  Stream<LocalUser?> get authStateChanges => _authStateController.stream;
  LocalUser? get currentUser => _currentUser;

  LocalAuthService() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_currentUserKey);
    if (userData == null) return;

    _currentUser = LocalUser.fromJson(jsonDecode(userData));
    _authStateController.add(_currentUser);
  }

  Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      return Map<String, dynamic>.from(jsonDecode(usersJson));
    }
    return {};
  }

  Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> _saveCurrentUser(LocalUser? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(_currentUserKey);
    }

    _currentUser = user;
    _authStateController.add(user);
  }

  Future<LocalUser> register({
    required String email,
    required String password,
    required String displayName,
    String skillLevel = 'beginner',
    String preferredLanguage = 'python',
    String authMethod = 'email',
    String bio = '',
    int dailyGoalMinutes = 20,
  }) async {
    final users = await _getUsers();
    final normalizedEmail = email.trim().toLowerCase();

    if (users.containsKey(normalizedEmail)) {
      throw 'An account already exists with this email.';
    }
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw 'Please enter a valid email address.';
    }
    if (password.length < 6) {
      throw 'Password must be at least 6 characters.';
    }
    if (displayName.trim().length < 2) {
      throw 'Please enter your name.';
    }

    final uid = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final user = LocalUser(
      uid: uid,
      email: normalizedEmail,
      displayName: displayName.trim(),
      skillLevel: skillLevel,
      preferredLanguage: preferredLanguage,
      authMethod: authMethod,
      bio: bio.trim(),
      dailyGoalMinutes: dailyGoalMinutes,
      createdAt: DateTime.now(),
    );

    users[normalizedEmail] = {'password': password, 'user': user.toJson()};
    await _saveUsers(users);
    await _saveCurrentUser(user);

    return user;
  }

  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    final normalizedEmail = email.trim().toLowerCase();

    if (!users.containsKey(normalizedEmail)) {
      throw 'No user found with this email.';
    }

    final userData = users[normalizedEmail] as Map<String, dynamic>;
    if (userData['password'] != password) {
      throw 'Wrong password provided.';
    }

    final user = LocalUser.fromJson(userData['user'] as Map<String, dynamic>);
    await _saveCurrentUser(user);
    return user;
  }

  Future<LocalUser> signInAnonymously() async {
    final uid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final user = LocalUser(
      uid: uid,
      email: 'guest@local',
      displayName: 'Guest User',
      isAnonymous: true,
      authMethod: 'anonymous',
      bio: '',
      dailyGoalMinutes: 15,
      createdAt: DateTime.now(),
    );
    await _saveCurrentUser(user);
    return user;
  }

  Future<LocalUser> updateProfile({
    required String uid,
    required String displayName,
    required String email,
    required String skillLevel,
    required String preferredLanguage,
    String? photoURL,
    String bio = '',
    int dailyGoalMinutes = 20,
  }) async {
    final users = await _getUsers();
    String? existingEmailKey;
    Map<String, dynamic>? storedEntry;

    for (final entry in users.entries) {
      final entryUser = LocalUser.fromJson(
        (entry.value as Map<String, dynamic>)['user'] as Map<String, dynamic>,
      );
      if (entryUser.uid == uid) {
        existingEmailKey = entry.key;
        storedEntry = entry.value as Map<String, dynamic>;
        break;
      }
    }

    if (existingEmailKey == null || storedEntry == null) {
      throw 'Local user was not found.';
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw 'Please enter a valid email address.';
    }
    if (displayName.trim().length < 2) {
      throw 'Name must be at least 2 characters.';
    }
    if (normalizedEmail != existingEmailKey.toLowerCase() &&
        users.containsKey(normalizedEmail)) {
      throw 'An account already exists with this email.';
    }

    final previousUser = LocalUser.fromJson(
      storedEntry['user'] as Map<String, dynamic>,
    );
    final updatedUser = previousUser.copyWith(
      displayName: displayName.trim(),
      email: normalizedEmail,
      skillLevel: skillLevel,
      preferredLanguage: preferredLanguage,
      photoURL: photoURL,
      bio: bio.trim(),
      dailyGoalMinutes: dailyGoalMinutes,
    );

    final password = storedEntry['password'];
    users.remove(existingEmailKey);
    users[normalizedEmail] = {
      'password': password,
      'user': updatedUser.toJson(),
    };
    await _saveUsers(users);

    if (_currentUser?.uid == uid) {
      await _saveCurrentUser(updatedUser);
    }

    return updatedUser;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw 'User not authenticated.';
    }
    if (user.isAnonymous) {
      throw 'Password change is unavailable for guest accounts.';
    }

    final trimmedCurrent = currentPassword.trim();
    final trimmedNew = newPassword.trim();
    if (trimmedCurrent.isEmpty) {
      throw 'Please enter your current password.';
    }
    if (trimmedNew.length < 6) {
      throw 'Password must be at least 6 characters.';
    }
    if (trimmedCurrent == trimmedNew) {
      throw 'New password must be different from current password.';
    }

    final users = await _getUsers();
    final emailKey = user.email.trim().toLowerCase();
    final userEntry = users[emailKey];
    if (userEntry is! Map<String, dynamic>) {
      throw 'Local user was not found.';
    }

    if (userEntry['password'] != trimmedCurrent) {
      throw 'Wrong password provided.';
    }

    users[emailKey] = {'password': trimmedNew, 'user': userEntry['user']};
    await _saveUsers(users);
  }

  Future<void> signOut() async {
    await _saveCurrentUser(null);
  }

  void dispose() {
    _authStateController.close();
  }
}

class LocalUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isAnonymous;
  final String skillLevel;
  final String preferredLanguage;
  final String authMethod;
  final String bio;
  final int dailyGoalMinutes;
  final DateTime createdAt;

  LocalUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.isAnonymous = false,
    this.skillLevel = 'beginner',
    this.preferredLanguage = 'python',
    this.authMethod = 'email',
    this.bio = '',
    this.dailyGoalMinutes = 20,
    required this.createdAt,
  });

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      isAnonymous: json['isAnonymous'] ?? false,
      skillLevel: json['skillLevel'] ?? 'beginner',
      preferredLanguage: json['preferredLanguage'] ?? 'python',
      authMethod: json['authMethod'] ?? 'email',
      bio: json['bio'] ?? '',
      dailyGoalMinutes: json['dailyGoalMinutes'] ?? 20,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  LocalUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isAnonymous,
    String? skillLevel,
    String? preferredLanguage,
    String? authMethod,
    String? bio,
    int? dailyGoalMinutes,
    DateTime? createdAt,
  }) {
    return LocalUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      skillLevel: skillLevel ?? this.skillLevel,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      authMethod: authMethod ?? this.authMethod,
      bio: bio ?? this.bio,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isAnonymous': isAnonymous,
      'skillLevel': skillLevel,
      'preferredLanguage': preferredLanguage,
      'authMethod': authMethod,
      'bio': bio,
      'dailyGoalMinutes': dailyGoalMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
