import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local authentication service for offline/demo mode
/// Works without Firebase - stores users locally
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
    if (userData != null) {
      _currentUser = LocalUser.fromJson(jsonDecode(userData));
      _authStateController.add(_currentUser);
    }
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
  
  /// Register new user
  Future<LocalUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final users = await _getUsers();
    
    // Check if email exists
    if (users.containsKey(email)) {
      throw 'An account already exists with this email.';
    }
    
    // Validate
    if (email.isEmpty || !email.contains('@')) {
      throw 'Please enter a valid email address.';
    }
    if (password.length < 3) {
      throw 'Password must be at least 3 characters.';
    }
    if (displayName.isEmpty) {
      throw 'Please enter your name.';
    }
    
    // Create user
    final uid = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final user = LocalUser(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    
    // Save user with password
    users[email] = {
      'password': password,
      'user': user.toJson(),
    };
    await _saveUsers(users);
    await _saveCurrentUser(user);
    
    return user;
  }
  
  /// Sign in with email and password
  Future<LocalUser> signIn({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    
    if (!users.containsKey(email)) {
      throw 'No user found with this email.';
    }
    
    final userData = users[email] as Map<String, dynamic>;
    if (userData['password'] != password) {
      throw 'Wrong password provided.';
    }
    
    final user = LocalUser.fromJson(userData['user'] as Map<String, dynamic>);
    await _saveCurrentUser(user);
    
    return user;
  }
  
  /// Sign in anonymously (guest mode)
  Future<LocalUser> signInAnonymously() async {
    final uid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    final user = LocalUser(
      uid: uid,
      email: 'guest@local',
      displayName: 'Guest User',
      isAnonymous: true,
      createdAt: DateTime.now(),
    );
    
    await _saveCurrentUser(user);
    return user;
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _saveCurrentUser(null);
  }
  
  void dispose() {
    _authStateController.close();
  }
}

/// Local user model
class LocalUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isAnonymous;
  final DateTime createdAt;
  
  LocalUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.isAnonymous = false,
    required this.createdAt,
  });
  
  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      isAnonymous: json['isAnonymous'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
