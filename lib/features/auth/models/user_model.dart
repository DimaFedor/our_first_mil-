import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final String skillLevel;
  final String preferredLanguage;
  final String authMethod;
  final String bio;
  final int dailyGoalMinutes;
  final DateTime? createdAt;
  final DateTime? lastActive;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.skillLevel = 'beginner',
    this.preferredLanguage = 'python',
    this.authMethod = 'email',
    this.bio = '',
    this.dailyGoalMinutes = 20,
    this.createdAt,
    this.lastActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      photoURL: json['photoURL'],
      totalXP: json['totalXP'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      skillLevel: json['skillLevel'] ?? 'beginner',
      preferredLanguage: json['preferredLanguage'] ?? 'python',
      authMethod: json['authMethod'] ?? 'email',
      bio: json['bio'] ?? '',
      dailyGoalMinutes: json['dailyGoalMinutes'] ?? 20,
      createdAt: _parseDate(json['createdAt']),
      lastActive: _parseDate(json['lastActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'totalXP': totalXP,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'skillLevel': skillLevel,
      'preferredLanguage': preferredLanguage,
      'authMethod': authMethod,
      'bio': bio,
      'dailyGoalMinutes': dailyGoalMinutes,
      'createdAt': createdAt,
      'lastActive': lastActive,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
